# 리링크 지크프리트의 메시와 모션을 클래식 워크래프트 MDX로 변환합니다.
import argparse
import importlib
import json
import math
import struct
import sys
import types
from pathlib import Path

import bpy
import numpy as np
from mathutils import Euler, Matrix, Quaternion, Vector


def package(name, path):
    module = types.ModuleType(name)
    module.__path__ = [str(path)]
    sys.modules[name] = module


def field(data, table, index):
    vtable = table - struct.unpack_from('<i', data, table)[0]
    size = struct.unpack_from('<H', data, vtable)[0]
    offset = struct.unpack_from('<H', data, vtable + 4 + index * 2)[0] if 4 + index * 2 < size else 0
    return table + offset if offset else None


def pointer(data, position):
    return position + struct.unpack_from('<I', data, position)[0]


def vector(data, position):
    if position is None:
        return []
    start = pointer(data, position)
    return [pointer(data, start + 4 + i * 4) for i in range(struct.unpack_from('<I', data, start)[0])]


def text_string(data, position):
    start = pointer(data, position)
    length = struct.unpack_from('<I', data, start)[0]
    return data[start + 4:start + 4 + length].decode()


def materials(path):
    data = path.read_bytes()
    root = struct.unpack_from('<I', data)[0]
    result = []
    for mat in vector(data, field(data, root, 1)):
        maps = vector(data, field(data, mat, 1))
        albedo = [text_string(data, field(data, item, 1)) for item in maps
                  if struct.unpack_from('<I', data, field(data, item, 0))[0] == 0x3f2b4d59]
        if not albedo and path.parent.parent.name == 'fp1100':
            iris = [text_string(data, field(data, item, 1)) for item in maps
                    if struct.unpack_from('<I', data, field(data, item, 0))[0] == 0x637a19f3]
            albedo = [name.replace('_iris', '_warcraft_albd') for name in iris]
        if len(albedo) != 1:
            raise ValueError('Expected one albedo texture per material')
        result.append((struct.unpack_from('<I', data, field(data, mat, 4))[0], albedo[0]))
    return result


def trs(position, rotation, scale):
    return np.array(Matrix.LocRotScale(Vector(position), Quaternion(rotation), Vector(scale)), dtype=np.float64)


def read_entity(reader, raw, entity, lod_number, bones, parent, material_offset, merge_face=False, source_entity=None):
    source_entity = source_entity or entity
    base = raw / 'model' / entity[:2] / source_entity
    info = reader.parse_mesh_info_file(str(base / (source_entity + '.minfo')))
    skel = reader.parse_skeleton_file(str(base / (source_entity + '.skeleton')))
    bone_offset = len(bones)
    remap, source_worlds = [], []
    shared = {bone['source']:i for i, bone in enumerate(bones) if bone['entity'] == 'pl1100'}
    for i in range(skel.BodyLength()):
        source = skel.Body(i)
        position = [source.Position().X(), source.Position().Y(), source.Position().Z()]
        rotation = [source.Quat().W(), source.Quat().X(), source.Quat().Y(), source.Quat().Z()]
        scale = [source.Scale().X(), source.Scale().Y(), source.Scale().Z()]
        local = trs(position, rotation, scale)
        if merge_face:
            source_world = local if source.ParentId() == 65535 else source_worlds[source.ParentId()] @ local
            source_worlds.append(source_world)
            if source.Name().decode() in shared:
                target = shared[source.Name().decode()]
                if np.max(np.abs(bones[target]['bind'] - source_world)) > 0.001:
                    raise ValueError('Shared face/body bind poses differ')
                remap.append(target)
                continue
            parent_id = parent if source.ParentId() == 65535 else remap[source.ParentId()]
            world = source_world
            local = np.linalg.inv(bones[parent_id]['bind']) @ world
            location, quaternion, scaling = Matrix(local).decompose()
            position, rotation, scale = list(location), list(quaternion), list(scaling)
        else:
            parent_id = parent if source.ParentId() == 65535 else bone_offset + source.ParentId()
            world = bones[parent_id]['bind'] @ local if parent_id >= 0 else local
        remap.append(len(bones))
        bones.append({'name':entity + source.Name().decode(), 'source':source.Name().decode(),
                      'parent':parent_id, 'position':position, 'rotation':rotation, 'scale':scale,
                      'local':local, 'bind':world, 'entity':entity})
    lod = info.Lods(lod_number)
    flags = reader.vertex_flags_to_bools(lod.BufferTypes())
    deform = [remap[info.DeformBoneToBoneIndexTable(i)]
              for i in range(info.DeformBoneToBoneIndexTableLength())]
    with (raw / 'model_streaming' / ('lod' + str(lod_number)) / (source_entity + '.mmesh')).open('rb') as stream:
        positions, normals, uv = reader.get_mesh_vertex_data(stream, lod.VertexCount())
        faces = reader.get_mesh_face_data(stream, lod.Buffers(lod.BuffersLength() - 1).Offset(), lod.IndexCount() // 3)
        count = 2 if 'BLENDINDICES_2' in flags else 1
        indices = reader.get_vertex_weight_indices(stream, lod, deform, count, flags.index('BLENDINDICES'))
        weights = np.array(reader.get_vertex_weight_values(stream, lod, count, flags.index('BLENDWEIGHT')), dtype=float)
    weights /= weights.sum(axis=1, keepdims=True)
    positions = np.array(positions, dtype=float)
    normals = np.array(normals, dtype=float)
    uv = np.array(uv, dtype=float)
    if parent >= 0 and not merge_face:
        transform = bones[parent]['bind']
        positions = (transform[:3, :3] @ positions.T).T + transform[:3, 3]
        normals = (transform[:3, :3] @ normals.T).T
    normal_lengths = np.linalg.norm(normals, axis=1, keepdims=True)
    normals /= np.maximum(normal_lengths, 1e-10)
    if info.MaterialsLength() != len(materials(base / 'vars' / '0.mmat')):
        raise ValueError('Model/material slot counts differ')
    parts = []
    for i in range(lod.ChunksLength()):
        chunk = lod.Chunks(i)
        parts.append({'material':material_offset + chunk.MaterialId(),
                      'faces':np.array(faces[chunk.Offset() // 3:(chunk.Offset() + chunk.Count()) // 3])[:, ::-1]})
    return {'positions':positions, 'normals':normals, 'uv':uv, 'indices':np.array(indices),
            'weights':weights, 'parts':parts, 'entity':entity}


def evaluate(keys, frames):
    if len(keys) == 1:
        return np.full(len(frames), keys[0].value)
    source_frames = np.array([key.frame for key in keys])
    values = np.array([key.value for key in keys])
    if keys[0].interpolationType != 'BEZIER':
        return np.interp(frames, source_frames, values)
    left = np.clip(np.searchsorted(source_frames, frames, side='right') - 1, 0, len(keys) - 2)
    distance = source_frames[left + 1] - source_frames[left]
    t = np.clip((frames - source_frames[left]) / np.maximum(distance, 1), 0, 1)
    # Importer converts MOT Hermite slopes into Bezier handles with frame distance on X only.
    slopes_out = np.array([key.m1 for key in keys])[left]
    slopes_in = np.array([key.m0 for key in keys])[left + 1]
    return ((2*t**3 - 3*t**2 + 1) * values[left] + (t**3 - 2*t**2 + t) * slopes_out
            + (-2*t**3 + 3*t**2) * values[left + 1] + (t**3 - t**2) * slopes_in)


def reduce_keys(values, frames, tolerance, rotation=False):
    if len(values) < 3:
        return list(range(len(values)))
    keep = {0, len(values) - 1}
    pending = [(0, len(values) - 1)]
    while pending:
        first, last = pending.pop()
        if last - first < 2:
            continue
        t = ((frames[first + 1:last] - frames[first]) / (frames[last] - frames[first]))[:, None]
        if rotation:
            a, b = values[first], values[last]
            dot = np.clip(np.dot(a, b), -1, 1)
            if dot < 0:
                b, dot = -b, -dot
            angle = math.acos(dot)
            if angle < 1e-7:
                predicted = (1-t)*a + t*b
            else:
                predicted = np.sin((1-t)*angle)/math.sin(angle)*a + np.sin(t*angle)/math.sin(angle)*b
            predicted /= np.linalg.norm(predicted, axis=1, keepdims=True)
            dots = np.abs(np.sum(predicted * values[first + 1:last], axis=1))
            error = 2*np.arccos(np.clip(dots, -1, 1))
        else:
            predicted = (1-t)*values[first] + t*values[last]
            error = np.linalg.norm(predicted - values[first + 1:last], axis=1)
        worst = int(np.argmax(error))
        if error[worst] > tolerance:
            index = first + 1 + worst
            keep.add(index)
            pending.extend([(first, index), (index, last)])
    return sorted(keep)


def chunk(tag, data):
    return tag.encode() + struct.pack('<I', len(data)) + data


def array_chunk(tag, values, dtype):
    values = np.asarray(values, dtype=dtype)
    count = len(values)
    return tag.encode() + struct.pack('<I', count) + values.tobytes()


def padded(text, size):
    data = text.encode('ascii')
    if len(data) >= size:
        raise ValueError('MDX name too long')
    return data.ljust(size, b'\0')


def extent(vertices):
    low, high = vertices.min(axis=0), vertices.max(axis=0)
    radius = float(np.max(np.linalg.norm(vertices, axis=1)))
    return struct.pack('<7f', radius, *low, *high)


def quantize(indices, weights):
    order = np.argsort(weights)[::-1][:4]
    chosen = [(int(indices[i]), float(weights[i])) for i in order if weights[i] > 1e-7]
    total = sum(weight for _, weight in chosen)
    target = np.array([weight/total for _, weight in chosen]) * 4
    counts = np.floor(target).astype(int)
    for i in np.argsort(target - counts)[::-1][:4 - int(counts.sum())]:
        counts[i] += 1
    group = sorted(bone for (bone, _), count in zip(chosen, counts) for _ in range(int(count)))
    return tuple(group)


def make_geosets(entity, coordinate, sequence_extents, node_ids=None):
    positions = (coordinate[:3, :3] @ entity['positions'].T).T
    normals = (coordinate[:3, :3] @ entity['normals'].T).T
    normals /= np.linalg.norm(normals, axis=1, keepdims=True)
    groups = [quantize(indices, weights) for indices, weights in zip(entity['indices'], entity['weights'])]
    entity['quantized'] = groups
    entity['geoset_vertices'] = []
    result = []
    for part in entity['parts']:
        group_map, vertex_map, source_vertices, faces = {}, {}, [], []
        def flush():
            if not faces:
                return
            selected = np.array(source_vertices)
            vertex_groups = [group_map[groups[i]] for i in source_vertices]
            matrix_groups = list(group_map)
            uv = entity['uv'][selected].copy()
            uv[:, 1] = 1 - uv[:, 1]
            data = (array_chunk('VRTX', positions[selected], '<f4') + array_chunk('NRMS', normals[selected], '<f4')
                    + array_chunk('PTYP', [4], '<u4') + array_chunk('PCNT', [len(faces)*3], '<u4')
                    + array_chunk('PVTX', np.array(faces).flatten(), '<u2')
                    + array_chunk('GNDX', vertex_groups, 'u1')
                    + array_chunk('MTGC', [len(group) for group in matrix_groups], '<u4')
                    + array_chunk('MATS', [node_ids[index] if node_ids is not None else index
                                          for group in matrix_groups for index in group], '<u4')
                    + struct.pack('<III', part['material'], 0, 0) + extent(positions[selected])
                    + struct.pack('<I', len(sequence_extents)) + b''.join(sequence_extents)
                    + b'UVAS' + struct.pack('<I', 1) + array_chunk('UVBS', uv, '<f4'))
            result.append(struct.pack('<I', len(data)+4) + data)
            entity['geoset_vertices'].append(source_vertices[:])
        for face in part['faces']:
            new_groups = {groups[int(index)] for index in face} - group_map.keys()
            if len(group_map) + len(new_groups) > 256 or len(vertex_map) + 3 > 4096:
                flush()
                group_map, vertex_map, source_vertices, faces = {}, {}, [], []
            mapped = []
            for source_index in face:
                source_index = int(source_index)
                group = groups[source_index]
                if group not in group_map:
                    group_map[group] = len(group_map)
                if source_index not in vertex_map:
                    vertex_map[source_index] = len(source_vertices)
                    source_vertices.append(source_index)
                mapped.append(vertex_map[source_index])
            faces.append(mapped)
        flush()
    return result


def sample_motion(mot, bones, coordinate, selected_frames=None, in_place=False):
    frames = np.arange(mot.header.frameCount) if selected_frames is None else np.array(selected_frames)
    count = len(frames)
    channels = {}
    lookup = {int(bone['source'][-3:], 16):i for i, bone in enumerate(bones) if bone['entity'] == 'pl1100'}
    for i, bone in enumerate(bones):
        if bone['entity'] == 'wp1100' and bone['source'] != '_000':
            lookup.setdefault(int(bone['source'][-3:],16),i)
    missing = set()
    for record in mot.records:
        index = 0 if record.boneIndex == -1 else lookup.get(record.boneIndex)
        if index is None:
            missing.add(record.boneIndex)
            continue
        channels[index, record.propertyIndex] = evaluate(record.interpolation.toKeyFrames(), frames)
    local_pose = []
    tracks = []
    cinv = np.linalg.inv(coordinate)
    for index, bone in enumerate(bones):
        position = np.tile(bone['position'], (count, 1))
        angles = np.tile(Quaternion(bone['rotation']).to_euler('XYZ'), (count, 1))
        scale = np.tile(bone['scale'], (count, 1))
        for component in range(3):
            for prop, array in [(component, position), (component+3, angles), (component+7, scale)]:
                if (index, prop) in channels:
                    array[:, component] = channels[index, prop]
        parent_bind = bones[bone['parent']]['bind'] if bone['parent'] >= 0 else np.eye(4)
        left = coordinate @ parent_bind
        right = np.linalg.inv(bone['bind']) @ cinv
        pivot = (coordinate @ np.r_[bone['bind'][:3, 3], 1])[:3]
        translations, rotations, scales, local_matrices = [], [], [], []
        for frame in range(count):
            pose = np.array(Matrix.LocRotScale(Vector(position[frame]), Euler(angles[frame], 'XYZ').to_quaternion(), Vector(scale[frame])))
            local_matrices.append(pose)
            delta = left @ pose @ right
            location, rotation, scaling = Matrix(delta).decompose()
            decomposed = np.array(Matrix.LocRotScale(location, rotation, scaling))
            if np.max(np.abs(delta - decomposed)) > 0.02:
                raise ValueError(f'Unsupported shear in {mot.header.animationName}, {bone["name"]}, frame {frame}')
            translation = np.array(location) - pivot + decomposed[:3, :3] @ pivot
            quaternion = np.array([rotation.x, rotation.y, rotation.z, rotation.w])
            if rotations and np.dot(rotations[-1], quaternion) < 0:
                quaternion *= -1
            translations.append(translation)
            rotations.append(quaternion)
            scales.append(scaling)
        local_pose.append(np.array(local_matrices))
        tracks.append([np.array(translations), np.array(rotations), np.array(scales)])
    if in_place:
        hips = next(i for i, bone in enumerate(bones) if bone['name'] == 'pl1100_000')
        chain, index = [], hips
        while index >= 0:
            chain.append(index)
            index = bones[index]['parent']
        world = np.tile(np.eye(4), (count, 1, 1))
        for index in reversed(chain):
            world = world @ local_pose[index]
        shift = -world[:, :3, 3]
        shift[:, 1] = 0
        local_pose[0][:, :3, 3] += shift
        tracks[0][0] += (coordinate[:3, :3] @ shift.T).T
    return frames, tracks, local_pose, sorted(missing)


def skin(entity, bones, local_pose, frame, quantized=False):
    worlds = []
    for bone, poses in zip(bones, local_pose):
        world = poses[frame]
        if bone['parent'] >= 0:
            world = worlds[bone['parent']] @ world
        worlds.append(world)
    matrices = np.array([world @ np.linalg.inv(bone['bind']) for world, bone in zip(worlds, bones)])
    homogeneous = np.c_[entity['positions'], np.ones(len(entity['positions']))]
    output = np.zeros_like(entity['positions'])
    indices = np.array(entity['quantized']) if quantized else entity['indices']
    weights = np.full(indices.shape, 0.25) if quantized else entity['weights']
    for slot in range(indices.shape[1]):
        transforms = matrices[indices[:, slot]]
        transformed = np.einsum('nij,nj->ni', transforms, homogeneous)[:, :3]
        output += transformed * weights[:, slot, None]
    return output


def influence_bounds(entities, bone_count):
    points = [[] for _ in range(bone_count)]
    for entity in entities:
        for index in np.unique(entity['indices']):
            mask = np.any((entity['indices'] == index) & (entity['weights'] > 1e-7), axis=1)
            if np.any(mask):
                points[index].append(entity['positions'][mask])
    bounds = {}
    for index, sets in enumerate(points):
        if sets:
            vertices = np.concatenate(sets)
            low, high = vertices.min(axis=0), vertices.max(axis=0)
            bounds[index] = np.array([[x,y,z,1] for x in [low[0],high[0]]
                                     for y in [low[1],high[1]] for z in [low[2],high[2]]])
    return bounds


def motion_extent(bones, local_pose, coordinate, bounds):
    worlds = []
    low, high, radius = np.full(3, np.inf), np.full(3, -np.inf), 0
    for index, (bone, poses) in enumerate(zip(bones, local_pose)):
        world = poses if bone['parent'] < 0 else worlds[bone['parent']] @ poses
        worlds.append(world)
        if index in bounds:
            transforms = coordinate @ world @ np.linalg.inv(bone['bind'])
            points = (transforms @ bounds[index].T).transpose(0,2,1)[:,:,:3].reshape(-1,3)
            low, high = np.minimum(low, points.min(axis=0)), np.maximum(high, points.max(axis=0))
            radius = max(radius, float(np.max(np.linalg.norm(points,axis=1))))
    return struct.pack('<7f', radius, *low, *high)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--raw', type=Path, required=True)
    parser.add_argument('--dependencies', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--lod', type=int, default=2, choices=range(4))
    parser.add_argument('--body-variant', choices=['pl1100', 'pl1101', 'pl1102'], default='pl1100')
    parser.add_argument('--motions', nargs='*')
    parser.add_argument('--combat-only', action='store_true')
    parser.add_argument('--in-place', action='store_true')
    args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
    if args.output.exists() and any(args.output.iterdir()):
        raise ValueError('Output directory must be empty; existing versions are preserved')
    args.output.mkdir(parents=True, exist_ok=True)
    package('gbfr', args.dependencies / 'GBFRBlenderTools-main')
    package('mot_tools', args.dependencies / 'GBFR2Blender2GBFR-custom_bones')
    reader = importlib.import_module('gbfr.gbfr_import')
    motlib = importlib.import_module('mot_tools.mot.common.mot')
    bones = [{'name':'RelinkRoot', 'source':'root', 'parent':-1, 'position':[0,0,0],
              'rotation':[1,0,0,0], 'scale':[1,1,1], 'local':np.eye(4), 'bind':np.eye(4), 'entity':'root'}]
    body_materials = materials(args.raw/'model/pl'/args.body_variant/'vars/0.mmat')
    body = read_entity(reader, args.raw, 'pl1100', args.lod, bones, 0, 0, source_entity=args.body_variant)
    if args.body_variant != 'pl1100':
        # Helmet variants reuse the complete PL1100 MOT skeleton without remapping.
        reference = (args.raw/'model/pl/pl1100/pl1100.skeleton').read_bytes()
        variant = (args.raw/'model/pl'/args.body_variant/(args.body_variant+'.skeleton')).read_bytes()
        if reference != variant:
            raise ValueError('Helmet/body skeletons must be byte-identical')
    socket = next(i for i, bone in enumerate(bones) if bone['name'] == 'pl1100_400')
    weapon_materials = materials(args.raw/'model/wp/wp1100/vars/0.mmat')
    weapon = read_entity(reader, args.raw, 'wp1100', args.lod, bones, socket, len(body_materials))
    head = next(i for i, bone in enumerate(bones) if bone['name'] == 'pl1100_005')
    face_materials = materials(args.raw/'model/fp/fp1100/vars/0.mmat')
    face = read_entity(reader, args.raw, 'fp1100', args.lod, bones, head, len(body_materials)+len(weapon_materials), merge_face=True)
    entities = [body, weapon, face]
    coordinate = np.eye(4)
    coordinate[:3, :3] = np.array([[0,0,60],[60,0,0],[0,60,0]])
    files = sorted((args.raw/'pl/pl1100').glob('*.mot'))
    removed = []
    if args.combat_only:
        # Combat locomotion, avoidance, guard, damage/recovery, link/SBA and attacks/skills.
        def combat_file(file):
            value = int(file.stem[-4:], 16)
            return (value in [0x0000,0x0010,0x0520,0x0060,0x0065,0x0066,0x0067]
                    or 0x0030 <= value <= 0x0052 or 0x0080 <= value <= 0x00a2
                    or 0x0500 <= value <= 0x067f or 0x1800 <= value <= 0x1820
                    or 0x3000 <= value < 0x3b00)
        removed = [file.name for file in files if not combat_file(file)]
        files = [file for file in files if combat_file(file)]
    if args.motions:
        missing_files = set(args.motions) - {file.stem[-4:] for file in files}
        if missing_files:
            raise ValueError('Requested MOT files are missing: ' + ', '.join(sorted(missing_files)))
        files = [file for file in files if file.stem[-4:] in args.motions]
    if not files:
        raise ValueError('No pl1100 MOT files were found')
    # Quantized source weights are also retained for independent pose comparisons.
    for entity in entities:
        make_geosets(entity, coordinate, [])
    bounds = influence_bounds(entities, len(bones))
    all_materials = body_materials + weapon_materials + face_materials
    texture_names = list(dict.fromkeys(name for _, name in all_materials))
    material_bytes = b''
    for _, name in all_materials:
        mode = 2 if 'hair' in name else 1 if 'face' in name else 0
        layer = struct.pack('<IIIiii f', 28, mode, 16, texture_names.index(name), -1, 0, 1.0)
        material_bytes += struct.pack('<Iii', 48, 0, 0) + b'LAYS' + struct.pack('<I', 1) + layer
    texture_bytes = b''.join(struct.pack('<I', 0) + padded('Siegfried\\' + name + '.blp', 260) + struct.pack('<I', 0) for name in texture_names)
    combined = np.concatenate([entity['positions'] for entity in entities])
    model_extent = extent((coordinate[:3, :3] @ combined.T).T)
    sequence_bytes = b''
    sequence_extents = []
    node_tracks = [[[], [], []] for _ in bones]
    hips = next(i for i, bone in enumerate(bones) if bone['name'] == 'pl1100_000')
    lock_chain, index = set(), hips
    while index >= 0:
        lock_chain.add(index)
        index = bones[index]['parent']
    report = {'lod':args.lod, 'body_variant':args.body_variant, 'bones':len(bones), 'textures':texture_names,
              'triangles':sum(len(part['faces']) for entity in entities for part in entity['parts']),
              'entities':[entity['entity'] for entity in entities], 'in_place':args.in_place,
              'combat_only':args.combat_only, 'removed_motions':removed, 'motions':[]}
    next_start = 1000
    spell_number = 0
    for number, file in enumerate(files):
        mot = motlib.MotFile()
        with file.open('rb') as stream:
            mot.fromFile(stream)
        frames, tracks, local_pose, missing = sample_motion(mot, bones, coordinate, in_place=args.in_place)
        times = next_start + np.rint(frames*1000/60).astype(int)
        standard_names = {'0000':'Stand', '0001':'Stand Alternate', '0010':'Walk',
                          '3000':'Attack - 1', '3001':'Attack - 2', '3002':'Attack - 3',
                          '3003':'Attack - 4', '3004':'Attack - 5', '3400':'Spell', '0520':'Death'}
        name = standard_names.get(file.stem[-4:], 'Relink ' + file.stem[-4:])
        if args.combat_only:
            name = {'0000':'Stand','0010':'Walk','0520':'Death'}.get(file.stem[-4:])
            if name is None:
                spell_number += 1
                name = 'Spell - ' + str(spell_number)
        clip_extent = motion_extent(bones, local_pose, coordinate, bounds)
        sequence_extents.append(clip_extent)
        loop = name.startswith('Stand') or name == 'Walk'
        sequence_bytes += padded(name,80) + struct.pack('<II f I f I', int(times[0]), int(times[-1]), 270 if name == 'Walk' else 0, 0 if loop else 1, 0, 0) + clip_extent
        for index, track in enumerate(tracks):
            for component, (values, tolerance) in enumerate(zip(track, [0.02, math.radians(0.1), 0.0002])):
                keep = list(range(len(values))) if args.in_place and index in lock_chain else reduce_keys(values, times, tolerance, component == 1)
                node_tracks[index][component].extend((int(times[i]), values[i]) for i in keep)
        world = np.tile(np.eye(4), (len(frames), 1, 1))
        for index in sorted(lock_chain):
            world = world @ local_pose[index]
        anchor = (coordinate @ world)[:, :3, 3]
        entry = {'source':file.name, 'name':name, 'frames':mot.header.frameCount,
                 'start':int(times[0]), 'end':int(times[-1]), 'missing_bones':missing,
                 'anchor_height':anchor[:,2].tolist(), 'anchor_xy_max':float(np.max(np.abs(anchor[:,:2])))}
        report['motions'].append(entry)
        if args.motions or args.combat_only or file.stem[-4:] in ['0000','0010','0020','0030','0500','0520','3000','3011','3200','3400','0b00','c000']:
            for frame in [0, mot.header.frameCount//2, mot.header.frameCount-1]:
                data = {}
                for entity in entities:
                    prefix = entity['entity']
                    data[prefix+'_vertices'] = skin(entity,bones,local_pose,frame)
                    quantized = skin(entity,bones,local_pose,frame,True)
                    data[prefix+'_quantized'] = (coordinate[:3,:3] @ quantized.T).T
                    original = data[prefix+'_vertices']
                    data[prefix+'_original'] = (coordinate[:3,:3] @ original.T).T
                    data[prefix+'_uv'] = entity['uv']
                    for part_index, part in enumerate(entity['parts']):
                        data[prefix+'_faces_'+str(part_index)] = part['faces']
                        data[prefix+'_material_'+str(part_index)] = np.array(part['material'])
                np.savez_compressed(args.output/(file.stem+'_'+str(frame)+'.npz'), **data)
        next_start = int(times[-1]) + 1000
        print('MOTION', number+1, len(files), file.name, 'unmapped', missing, flush=True)
    bone_bytes, helper_bytes = b'', b''
    weighted_nodes = set(index for entity in entities for group in entity['quantized'] for index in group)
    # Legacy readers index nodes in chunk order: bones first, then helpers.
    export_order = ([index for index in range(len(bones)) if index in weighted_nodes]
                    + [index for index in range(len(bones)) if index not in weighted_nodes])
    node_ids = {index:position for position,index in enumerate(export_order)}
    for index, bone in enumerate(bones):
        animation = b''
        for tag, entries in zip(['KGTR','KGRT','KGSC'], node_tracks[index]):
            if not entries:
                continue
            identity = {'KGTR':[0,0,0], 'KGRT':[0,0,0,1], 'KGSC':[1,1,1]}[tag]
            if np.max(np.abs(np.array([values for time,values in entries]) - identity)) < 1e-5:
                continue
            data = b''.join(struct.pack('<I', time) + np.asarray(values,dtype='<f4').tobytes() for time,values in entries)
            animation += tag.encode() + struct.pack('<IIi', len(entries), 1, -1) + data
        parent = node_ids[bone['parent']] if bone['parent'] >= 0 else -1
        node = struct.pack('<I',96+len(animation)) + padded(bone['name'],80) + struct.pack('<iiI',node_ids[index],parent,256 if index in weighted_nodes else 0) + animation
        if index in weighted_nodes:
            bone_bytes += node + struct.pack('<ii',-1,-1)
        else:
            helper_bytes += node
    pivots = np.array([(coordinate @ np.r_[bones[index]['bind'][:3,3],1])[:3] for index in export_order],dtype='<f4')
    geosets = sum([make_geosets(entity, coordinate, sequence_extents, node_ids) for entity in entities], [])
    report['geosets'] = len(geosets)
    report['weighted_bones'] = len(weighted_nodes)
    report['helpers'] = len(bones) - len(weighted_nodes)
    origin = (struct.pack('<I',364) + struct.pack('<I',96) + padded('Origin Ref',80)
              + struct.pack('<iiI',len(bones),node_ids[0],2048) + bytes(260) + struct.pack('<I',0))
    pivots = np.vstack([pivots,[0,0,0]]).astype('<f4')
    report['skin_maps'] = [{'entity':entity['entity'], 'vertices':vertices}
                           for entity in entities for vertices in entity['geoset_vertices']]
    model = (b'MDLX' + chunk('VERS',struct.pack('<I',800))
             + chunk('MODL',padded('Siegfried Relink',80)+bytes(260)+model_extent+struct.pack('<I',150))
             + chunk('SEQS',sequence_bytes) + chunk('MTLS',material_bytes) + chunk('TEXS',texture_bytes)
             + chunk('GEOS',b''.join(geosets)) + chunk('BONE',bone_bytes) + chunk('HELP',helper_bytes)
             + chunk('ATCH',origin) + chunk('PIVT',pivots.tobytes()))
    (args.output/'Siegfried.mdx').write_bytes(model)
    (args.output/'conversion.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print('MDX_SAVED', len(model), flush=True)


if __name__ == '__main__':
    main()

# PMX 메시와 골격을 읽어 클래식 워크래프트 변환 자료 및 BLP1을 만듭니다.
import argparse
import hashlib
import importlib.util
import json
import struct
import sys
from pathlib import Path

import bpy
import numpy as np
from PIL import Image


def read_pmx(parser_path, source):
    spec = importlib.util.spec_from_file_location('pmx_reader', parser_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.load(str(source))


def weights(vertex):
    source = vertex.weight
    if source.type == 0:
        values = [1.0]
    elif source.type in [1, 3]:
        first = source.weights[0] if source.type == 1 else source.weights.weight
        values = [first, 1-first]
    elif source.type == 2:
        values = source.weights
    else:
        raise ValueError('Unsupported PMX skinning type')
    result = {}
    for bone, weight in zip(source.bones, values):
        if bone >= 0 and weight > 1e-7:
            result[bone] = result.get(bone, 0) + float(weight)
    total = sum(result.values())
    if total <= 0:
        raise ValueError('Vertex has no valid skin weight')
    return {bone:weight/total for bone, weight in result.items()}


def quantize(influences):
    selected = sorted(influences.items(), key=lambda x:x[1], reverse=True)[:4]
    target = np.array([weight for _, weight in selected])
    target = target/target.sum()*4
    counts = np.floor(target).astype(int)
    for i in np.argsort(target-counts)[::-1][:4-int(counts.sum())]:
        counts[i] += 1
    return sorted(bone for (bone, _), count in zip(selected, counts) for _ in range(int(count)))


def save_blp(image, path, maximum):
    image = image.convert('RGBA')
    image.thumbnail((maximum, maximum), Image.Resampling.LANCZOS)
    width, height = image.size
    if width & (width-1) or height & (height-1):
        raise ValueError('BLP dimensions must be powers of two')
    indexed = image.convert('RGB').quantize(colors=256)
    palette = indexed.getpalette()
    palette.extend([0]*(768-len(palette)))
    palette_bytes = b''.join(bytes([palette[i+2],palette[i+1],palette[i],255]) for i in range(0,768,3))
    offsets, sizes, payload = [0]*16, [0]*16, bytearray()
    level = 0
    while True:
        data = image.convert('RGB').quantize(palette=indexed).tobytes() + image.getchannel('A').tobytes()
        offsets[level] = 1180+len(payload)
        sizes[level] = len(data)
        payload.extend(data)
        level += 1
        if image.size == (1,1):
            break
        image = image.resize((max(1,image.width//2),max(1,image.height//2)),Image.Resampling.LANCZOS)
    path.parent.mkdir(parents=True,exist_ok=True)
    if path.exists():
        raise FileExistsError(path)
    path.write_bytes(b'BLP1'+struct.pack('<6I',1,8,width,height,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*sizes)+palette_bytes+payload)
    return {'width':width,'height':height,'mipmaps':level,'alpha_bits':8}


def surface(model, source_faces, material, positions, normals, vertex_weights, ratio):
    selected = sorted(set(int(i) for face in source_faces for i in face))
    remap = {source:i for i, source in enumerate(selected)}
    faces = np.array([[remap[int(i)] for i in face] for face in source_faces])
    points = positions[selected]
    face_normals = np.cross(points[faces[:,1]]-points[faces[:,0]],points[faces[:,2]]-points[faces[:,0]])
    expected = normals[selected][faces].mean(axis=1)
    if np.median(np.sum(face_normals*expected,axis=1)) < 0:
        faces = faces[:,::-1]
    mesh = bpy.data.meshes.new('PMXSurface')
    mesh.from_pydata(points.tolist(),[],faces.tolist())
    mesh.update()
    uv = mesh.uv_layers.new(name='UV0')
    for poly in mesh.polygons:
        poly.use_smooth = True
        for loop_index in poly.loop_indices:
            original = model.vertices[selected[mesh.loops[loop_index].vertex_index]].uv
            uv.data[loop_index].uv = (original[0],1-original[1])
    mesh.use_auto_smooth = True
    mesh.normals_split_custom_set_from_vertices(normals[selected].tolist())
    obj = bpy.data.objects.new('PMXSurface',mesh)
    bpy.context.scene.collection.objects.link(obj)
    groups = {}
    for vertex, original in enumerate(selected):
        for bone, weight in vertex_weights[original].items():
            if bone not in groups:
                groups[bone] = obj.vertex_groups.new(name='PMX_'+str(bone))
            groups[bone].add([vertex],weight,'REPLACE')
    if ratio < 1 and len(faces)>64:
        bpy.context.view_layer.objects.active = obj
        modifier = obj.modifiers.new('WarcraftLOD','DECIMATE')
        modifier.ratio = ratio
        modifier.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    mesh = obj.data
    mesh.calc_loop_triangles()
    mesh.calc_normals_split()
    bone_ids = {group.index:int(group.name.split('_')[1]) for group in obj.vertex_groups}
    vertex_map, vertices, output_normals, output_uv, output_groups, output_faces = {}, [], [], [], [], []
    for triangle in mesh.loop_triangles:
        face = []
        for loop_index in triangle.loops:
            loop = mesh.loops[loop_index]
            texcoord = mesh.uv_layers.active.data[loop_index].uv
            key = (loop.vertex_index,tuple(round(x,7) for x in texcoord),tuple(round(x,6) for x in loop.normal))
            if key not in vertex_map:
                vertex_map[key] = len(vertices)
                vertex = mesh.vertices[loop.vertex_index]
                influences = {bone_ids[g.group]:g.weight for g in vertex.groups if g.weight>1e-7}
                vertices.append(list(vertex.co))
                output_normals.append(list(loop.normal))
                output_uv.append([texcoord.x,1-texcoord.y])
                output_groups.append(quantize(influences))
            face.append(vertex_map[key])
        output_faces.append(face)
    bpy.data.objects.remove(obj,do_unlink=True)
    return {'material':material,'vertices':vertices,'normals':output_normals,'uv':output_uv,'groups':output_groups,'faces':output_faces}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input',type=Path,required=True)
    parser.add_argument('--parser',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--name',required=True)
    parser.add_argument('--target-triangles',type=int,default=20000)
    parser.add_argument('--texture-max',type=int,default=1024,choices=[256,512,1024,2048])
    args = parser.parse_args(sys.argv[sys.argv.index('--')+1:])
    if not args.name.isascii() or len(args.name)>=60 or not args.name.replace('_','').isalnum():
        raise ValueError('Use a short ASCII model name')
    if args.output.exists() and any(args.output.iterdir()):
        raise FileExistsError('Existing output is preserved')
    model = read_pmx(args.parser,args.input)
    if sum(m.vertex_count for m in model.materials) != len(model.faces)*3:
        raise ValueError('PMX material face counts do not match')
    args.output.mkdir(parents=True,exist_ok=True)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    positions = np.array([v.co for v in model.vertices],dtype=float)
    normals = np.array([v.normal for v in model.vertices],dtype=float)
    # PMX Y up becomes Warcraft Z up. The visible model is 120 Warcraft units tall.
    visible_parts, cursor = [], 0
    hidden = []
    for i, material in enumerate(model.materials):
        count = material.vertex_count//3
        faces = model.faces[cursor:cursor+count]
        cursor += count
        if material.diffuse[3] <= 1e-6:
            hidden.append({'name':material.name,'triangles':count})
        elif count:
            visible_parts.append((i,material,faces))
    visible_indices = sorted(set(int(i) for _,_,faces in visible_parts for face in faces for i in face))
    points = positions[visible_indices]
    scale = 120/(points[:,1].max()-points[:,1].min())
    center = np.array([(points[:,0].min()+points[:,0].max())/2,points[:,1].min(),(points[:,2].min()+points[:,2].max())/2])
    coordinate = np.array([[0,0,1],[1,0,0],[0,1,0]],dtype=float)*scale
    positions = (coordinate @ (positions-center).T).T
    normals = (coordinate @ normals.T).T
    normals /= np.maximum(np.linalg.norm(normals,axis=1,keepdims=True),1e-10)
    vertex_weights = [weights(v) for v in model.vertices]
    if any(bone>=len(model.bones) for influence in vertex_weights for bone in influence):
        raise ValueError('PMX skin references a missing bone')
    visible_triangles = sum(len(faces) for _,_,faces in visible_parts)
    protected = sum(len(faces) for i,_,faces in visible_parts if i<=6)
    ratio = 1 if args.target_triangles<=0 else min(1,max(0.02,(args.target_triangles-protected)/max(1,visible_triangles-protected)))
    geometry, material_report, textures, texture_map, missing = [], [], [], {}, []
    for original_index, material, faces in visible_parts:
        texture_path = Path(model.textures[material.texture].path).resolve() if material.texture>=0 else None
        if texture_path and not texture_path.is_relative_to(args.input.parent.resolve()):
            raise ValueError('Texture path leaves the provided model directory')
        if texture_path and not texture_path.exists():
            if any(abs(x)>1e-6 for x in material.diffuse[:3]):
                raise FileNotFoundError(texture_path)
            missing.append({'material':material.name,'source':str(texture_path),'fallback':'original constant black shadow color'})
            texture_path = None
        key = str(texture_path) if texture_path else 'solid_white'
        if key not in texture_map:
            image = Image.open(texture_path).convert('RGBA') if texture_path else Image.new('RGBA',(1,1),(255,255,255,255))
            minimum_alpha = image.getchannel('A').getextrema()[0]
            texture_id = len(textures)
            relative = args.name+'\\Texture_'+str(texture_id).zfill(2)+'.blp'
            details = save_blp(image,args.output/relative.replace('\\','/'),args.texture_max)
            textures.append({'path':relative,'source':str(texture_path) if texture_path else None,'minimum_alpha':minimum_alpha,**details})
            texture_map[key] = texture_id
        texture_id = texture_map[key]
        mode = 2 if material.diffuse[3]<0.9999 else 1 if textures[texture_id]['minimum_alpha']<128 else 0
        index = len(material_report)
        part = surface(model,faces,index,positions,normals,vertex_weights,1 if original_index<=6 else ratio)
        geometry.append(part)
        material_report.append({'source_index':original_index,'name':material.name,'texture':texture_id,'diffuse':material.diffuse,'filter_mode':mode,'two_sided':material.is_double_sided,'source_triangles':len(faces),'triangles':len(part['faces'])})
        print('MATERIAL',original_index,'TRIANGLES',len(faces),'TO',len(part['faces']),flush=True)
    bones = [{'name':'PMX_'+str(i).zfill(4),'source_name':b.name,'parent':b.parent,'pivot':(coordinate @ (np.array(b.location)-center)).tolist()} for i,b in enumerate(model.bones)]
    report = {'model':args.name,'source_file':args.input.name,'source_sha256':hashlib.sha256(args.input.read_bytes()).hexdigest(),'source_triangles':len(model.faces),'visible_source_triangles':visible_triangles,'triangles':sum(len(p['faces']) for p in geometry),'target_triangles':args.target_triangles,'source_vertices':len(model.vertices),'source_bones':len(bones),'source_morphs':len(model.morphs),'hidden_materials':hidden,'missing_textures':missing,'materials':material_report,'textures':textures,'height_units':120,'coordinate_scale':scale,'sequences':['Stand'],'animation_source_files':[]}
    payload = {'model':args.name,'bones':bones,'materials':material_report,'textures':textures,'surfaces':geometry}
    (args.output/'geometry.json').write_text(json.dumps(payload,separators=(',',':')),encoding='utf-8')
    (args.output/'conversion.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print('CONVERTED_TRIANGLES',report['triangles'],flush=True)


if __name__ == '__main__':
    main()

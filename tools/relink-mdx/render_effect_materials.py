# 독립 파서로 재읽은 MDX 메시와 디코딩 BLP를 Blender에서 렌더해 이펙트 소재를 확인합니다.
import json
import sys
from pathlib import Path

import bpy
from mathutils import Vector


root = Path(sys.argv[sys.argv.index('--') + 1])
manifest = json.loads((root / 'Info/effects-manifest.json').read_text(encoding='utf8'))
models = json.loads((root / 'Info/render-input.json').read_text(encoding='utf8'))
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.eevee.taa_render_samples = 8
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'Medium High Contrast'
scene.world.color = (.008, .012, .02)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.object.camera_add(location=(400, 0, 0))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 0)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 270
scene.camera = camera
previews = root / 'Info/previews'
previews.mkdir(exist_ok=True)
image_cache = {}
for page in manifest['atlases']:
    name = Path(page['path']).name
    file = root / 'Info/decoded-atlases' / (name + '.rgba')
    import numpy as np
    pixels = np.frombuffer(file.read_bytes(), dtype=np.uint8).reshape(page['height'], page['width'], 4)
    image = bpy.data.images.new(name, width=page['width'], height=page['height'], alpha=True)
    image.colorspace_settings.name = 'sRGB'
    image.pixels.foreach_set((pixels[::-1].astype('float32') / 255).ravel())
    image_cache[page['path'].replace('/', '\\')] = image

rendered = []
for model in models:
    objects = []
    for index, geometry in enumerate(model['geosets']):
        mesh = bpy.data.meshes.new(model['name'] + str(index))
        points = [geometry['vertices'][i:i+3] for i in range(0, len(geometry['vertices']), 3)]
        faces = [geometry['faces'][i:i+3] for i in range(0, len(geometry['faces']), 3)]
        mesh.from_pydata(points, [], faces)
        uv = mesh.uv_layers.new()
        for polygon in mesh.polygons:
            for loop in polygon.loop_indices:
                vertex = mesh.loops[loop].vertex_index
                uv.data[loop].uv = (geometry['uv'][vertex * 2], 1 - geometry['uv'][vertex * 2 + 1])
        obj = bpy.data.objects.new(model['name'] + str(index), mesh)
        scene.collection.objects.link(obj)
        material = bpy.data.materials.new(model['name'] + str(index))
        material.use_nodes = True
        material.blend_method = 'BLEND'
        nodes = material.node_tree.nodes
        nodes.clear()
        output = nodes.new('ShaderNodeOutputMaterial')
        transparent = nodes.new('ShaderNodeBsdfTransparent')
        emission = nodes.new('ShaderNodeEmission')
        texture = nodes.new('ShaderNodeTexImage')
        texture.image = image_cache[geometry['texture']]
        color = nodes.new('ShaderNodeVectorMath')
        color.operation = 'SCALE'
        add = nodes.new('ShaderNodeAddShader')
        material.node_tree.links.new(texture.outputs['Color'], color.inputs[0])
        material.node_tree.links.new(texture.outputs['Alpha'], color.inputs['Scale'])
        material.node_tree.links.new(color.outputs['Vector'], emission.inputs['Color'])
        material.node_tree.links.new(transparent.outputs[0], add.inputs[0])
        material.node_tree.links.new(emission.outputs[0], add.inputs[1])
        material.node_tree.links.new(add.outputs[0], output.inputs['Surface'])
        obj.data.materials.append(material)
        objects.append((obj, geometry))
    times = [round((i + .5) * model['duration'] / 6) for i in range(6)]
    files = []
    for frame, time in enumerate(times):
        for obj, geometry in objects:
            key = 0
            while key + 1 < len(geometry['alpha_frames']) and geometry['alpha_frames'][key + 1] <= time:
                key += 1
            obj.hide_render = geometry['alpha_values'][key] == 0
        file = previews / (model['name'] + f'_{frame}.png')
        scene.render.filepath = str(file)
        bpy.ops.render.render(write_still=True)
        files.append(file.name)
    rendered.append({'model': model['name'], 'sampled_times_ms': times, 'files': files,
                     'preview_uses_source_texture_alpha': True, 'additive_shader_approximation': True,
                     'warcraft_addalpha_blending_billboard_runtime_not_tested': True})
    for obj, geometry in objects:
        bpy.data.objects.remove(obj, do_unlink=True)
    print(json.dumps({'rendered_models': len(rendered), 'total': len(models)}), flush=True)
(root / 'Info/render-validation.json').write_text(json.dumps(rendered, indent=2), encoding='utf8')

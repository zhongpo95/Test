# 사의 대기 동작을 MDX 재읽기 좌표와 디코딩 텍스처로 렌더하여 팔과 소매를 확인합니다.
import bpy,json,sys,bisect
import numpy as np
from pathlib import Path
from mathutils import Vector,Quaternion
texture_root=Path(sys.argv[sys.argv.index('--')+1]);folder=Path(sys.argv[sys.argv.index('--')+2])
scene=bpy.context.scene;scene.render.engine='BLENDER_EEVEE';scene.eevee.taa_render_samples=24
scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(0.13,0.15,0.19,1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value=0.8
scene.view_settings.view_transform='Standard';scene.view_settings.look='Medium High Contrast'
scene.render.resolution_x=640;scene.render.resolution_y=800;scene.render.resolution_percentage=100
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
pose=json.loads((folder/'cross-0.json').read_text());materials=[]
for i,m in enumerate(pose['materials']):
 mat=bpy.data.materials.new('Material_'+str(i));mat.use_nodes=True
 shader=mat.node_tree.nodes.get('Principled BSDF');shader.inputs['Roughness'].default_value=1
 tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(texture_root/pose['textures'][m['texture']]['path'].replace('\\','/'))+'.png')
 multiply=mat.node_tree.nodes.new('ShaderNodeMixRGB');multiply.blend_type='MULTIPLY';multiply.inputs[0].default_value=1;multiply.inputs[2].default_value=(*m['diffuse'][:3],1)
 mat.node_tree.links.new(tex.outputs['Color'],multiply.inputs[1]);mat.node_tree.links.new(multiply.outputs[0],shader.inputs['Base Color'])
 if m['filter_mode'] in [1,2]:
  alpha=mat.node_tree.nodes.new('ShaderNodeMath');alpha.operation='MULTIPLY';alpha.inputs[1].default_value=m['diffuse'][3]
  mat.node_tree.links.new(tex.outputs['Alpha'],alpha.inputs[0]);mat.node_tree.links.new(alpha.outputs[0],shader.inputs['Alpha'])
  mat.blend_method='BLEND' if m['filter_mode']==2 else 'CLIP';mat.use_screen_refraction=False;mat.show_transparent_back=False
 materials.append(mat)
objects=[]
for i,g in enumerate(pose['geosets']):
 mesh=bpy.data.meshes.new('Geo_'+str(i));mesh.from_pydata(g['vertices'],[],g['faces']);mesh.update();uv=mesh.uv_layers.new(name='UV0')
 for p in mesh.polygons:
  p.use_smooth=True
  for li in p.loop_indices:uv.data[li].uv=g['uv'][mesh.loops[li].vertex_index]
 mesh.use_auto_smooth=True;mesh.normals_split_custom_set_from_vertices(g['normals'])
 obj=bpy.data.objects.new('Geo_'+str(i),mesh);scene.collection.objects.link(obj);mesh.materials.append(materials[g['material']]);objects.append(obj)
for location,energy in [((-220,180,270),2.0),((-100,-250,200),0.65),((-250,0,120),0.65)]:
 light=bpy.data.lights.new('Studio','SUN');light.energy=energy;light.angle=0.5
 obj=bpy.data.objects.new('Studio',light);scene.collection.objects.link(obj);obj.location=location;obj.rotation_euler=(Vector((-27,-3,75))-obj.location).to_track_quat('-Z','Y').to_euler()
camera=bpy.data.cameras.new('Camera');cam=bpy.data.objects.new('Camera',camera);scene.collection.objects.link(cam);scene.camera=cam;camera.type='ORTHO'
for filename in ['cross-0','hmm-0','hmm-1.8','hmm-2.2','hmm-3.2','hmm-4.2']:
 pose=json.loads((folder/(filename+'.json')).read_text())
 for obj,g in zip(objects,pose['geosets']):
  obj.data.vertices.foreach_set('co',[x for v in g['vertices'] for x in v]);obj.data.update();obj.data.normals_split_custom_set_from_vertices(g['normals'])
 for label,scale,target,offset in [('front',142,(-20,-3,61),(-260,30,50)),('close',64,(-28,-3,89),(-180,25,8))]:
  camera.ortho_scale=scale;target=Vector(target);cam.location=target+Vector(offset);cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler()
  scene.render.filepath=str(folder/(filename+'-'+label+'.png'));bpy.ops.render.render(write_still=True)
 print('RENDERED',filename,flush=True)
if '--animate' in sys.argv:
 data=json.loads((folder/'render-motion.json').read_text());nodes=data['nodes'];cached=[]
 for g in data['geosets']:
  points=np.array(g['vertices']).reshape(-1,3);normals=np.array(g['normals']).reshape(-1,3);groups=[];offset=0
  for count in g['matrixGroups']:
   groups.append(g['matrixIndices'][offset:offset+count]);offset+=count
  cached.append((points,normals,groups,np.array(g['vertexGroups'])))
 def sampled(time):
  matrices=[None]*len(nodes)
  def resolve(i):
   if matrices[i] is not None:return
   node=nodes[i];parent=node['parent']
   if parent>=0:resolve(parent)
   a=node['rotation'];rotation=Quaternion((1,0,0,0))
   if a:
    j=max(0,bisect.bisect_right(a['frames'],time)-1);q=a['values'][j];rotation=Quaternion((q[3],q[0],q[1],q[2]))
    if j+1<len(a['frames']) and time>a['frames'][j]:
     q=a['values'][j+1];rotation=rotation.slerp(Quaternion((q[3],q[0],q[1],q[2])),(time-a['frames'][j])/(a['frames'][j+1]-a['frames'][j]))
   translation=np.zeros(3);a=node.get('translation')
   if a:
    j=max(0,bisect.bisect_right(a['frames'],time)-1);translation=np.array(a['values'][j])
    if j+1<len(a['frames']) and time>a['frames'][j]:
     fraction=(time-a['frames'][j])/(a['frames'][j+1]-a['frames'][j]);translation=translation*(1-fraction)+np.array(a['values'][j+1])*fraction
   local=np.eye(4);local[:3,:3]=np.array(rotation.to_matrix());p=np.array(node['pivot']);local[:3,3]=p-local[:3,:3]@p+translation
   matrices[i]=matrices[parent]@local if parent>=0 else local
  for i in range(len(nodes)):resolve(i)
  return np.array(matrices)
 for clip in data['clips']:
  frame_folder=folder/(clip['kind']+'-frames');frame_folder.mkdir(exist_ok=False)
  target=Vector((-24,-3,61));cam.location=target+Vector((-260,30,32));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();camera.ortho_scale=142
  scene.render.resolution_x=480;scene.render.resolution_y=600;scene.eevee.taa_render_samples=16
  for frame in range(round(clip['duration']/1000*20)):
   matrices=sampled(clip['start']+frame*50)
   for obj,(points,normals,groups,indices) in zip(objects,cached):
    grouped=np.array([matrices[g].mean(axis=0) for g in groups])[indices]
    positions=np.einsum('nij,nj->ni',grouped[:,:3,:3],points)+grouped[:,:3,3]
    n=np.einsum('nij,nj->ni',grouped[:,:3,:3],normals);n/=np.maximum(np.linalg.norm(n,axis=1,keepdims=True),1e-8)
    obj.data.vertices.foreach_set('co',positions.ravel());obj.data.update();obj.data.normals_split_custom_set_from_vertices(n.tolist())
   scene.render.filepath=str(frame_folder/('%04d.png'%frame));bpy.ops.render.render(write_still=True)
  print('ANIMATED',clip['name'],flush=True)

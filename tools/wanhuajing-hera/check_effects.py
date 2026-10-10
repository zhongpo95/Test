# 효과 숨김, 공유 부착 효과 재표시 및 해제 후 핸들 재사용을 검증한다.
import argparse,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--lua-deps',type=Path,required=True);a=p.parse_args();sys.path.insert(0,str(a.lua_deps))
from lupa.lua53 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
actual, created, refs, removed = {}, {}, {}, {}
local counter=0
common={}
function common.AddSpecialEffect(path,x,y) counter=counter+1;actual[counter]=1;created[counter]=path;return counter end
local native_add=common.AddSpecialEffect
function common.AddSpecialEffectTarget(path,unit,socket) return native_add(path,0,0) end
function common.DestroyEffect(h) removed[h]=true;actual[h]=nil end
japi={EXSetEffectSize=function(h,s) actual[h]=s end,EXGetEffectSize=function(h) return actual[h] end}
local dbg={handle_ref=function(h) refs[h]=(refs[h] or 0)+1 end,handle_unref=function(h) refs[h]=refs[h]-1 end}
function require(name) if name=='jass.common' then return common elseif name=='jass.japi' then return japi elseif name=='jass.debug' then return dbg end;error(name) end
env={game={}};notes={}
''')
root=Path(__file__).parent
lua.execute((root/'hera_effect_visibility.lua').read_text('utf8'))(lua.globals().common,lua.globals().japi)
lua.execute((root/'hera_effects.lua').read_text('utf8'))(lua.globals().env,lua.eval('function(s) notes[#notes+1]=s end'))
lua.execute('''
local h=common.AddSpecialEffectTarget('a.mdx',9,'origin',nil,'nullmodel.mdx')
assert(created[h]=='a.mdx' and actual[h]==0 and refs[h]==1)
japi.EXSetEffectSize(h,2.5)
assert(actual[h]==0 and japi.EXGetEffectSize(h)==2.5)
env.game.set_target_effect_display(h,'a.mdx')
assert(actual[h]==2.5)
env.game.set_target_effect_display(h,'nullmodel.mdx')
env.game.set_target_effect_display(h,'nullmodel.mdx')
assert(actual[h]==0 and japi.EXGetEffectSize(h)==2.5)
env.game.set_target_effect_display(h,'other.mdx')
assert(actual[h]==0 and #notes==1)
japi.EXSetEffectSize(h,0)
env.game.set_target_effect_display(h,'a.mdx')
assert(actual[h]==0 and japi.EXGetEffectSize(h)==0)
japi.EXSetEffectSize(h,3)
assert(actual[h]==3)
japi.EXSetEffectVisible(h,false)
common.DestroyEffect(h)
assert(removed[h] and refs[h]==0)
actual[h]=7
assert(japi.EXGetEffectSize(h)==7)
local made,dead,live=env.game.get_effect_pool_data()
assert(made==1 and dead==1 and live==0)
''')
print('PASS: hidden attachment, shared visibility, hidden resize, zero size, cleanup, reused handle')

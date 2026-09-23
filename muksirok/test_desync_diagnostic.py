# 이탈 진단이 선택 해제된 영웅도 기록하고 기록 실패를 게임 콜백에 전파하지 않는지 검사한다.
import pathlib
from lupa import LuaRuntime

root = pathlib.Path(__file__).parent / 'hera-port'
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().source_path = str(root / 'hera_desync_diagnostic.lua')
lua.execute(r'''
records, notes = {}, {}
package.preload.hera_build_info = function() return {revision='177 MP', title='test'} end
package.preload.hera_trace_ring = function()
  return {new=function(path)
    assert(path == 'Logs/Hera_RPG_Desync_v177_MP_p3.txt' or
      path == 'Logs/Hera_RPG_UISync_v177_MP_p3.txt')
    return {write=function(text) records[#records+1]=text; return true end}
  end}
end
package.preload.hera_boot = function()
  return {note=function(text, important)
    assert(important == true)
    notes[#notes+1]=text
  end}
end
ac={clock=function() return 3114160 end}
GetLocalPlayer=function() return 2 end
GetPlayerId=function(p) return p end
Player=function(p) return p end
GetPlayerSlotState=function(p) return p==0 and 'LEFT' or 'PLAYING' end
Hero={[1]=101,[2]=0,[3]=103}
Xuanze={[1]=false,[2]=false,[3]=true}
Stage=12; PlayerCount=2; AllNumofMonster=2; LeftNumofMonster=148
GetUnitTypeId=function(h) assert(h==101 or h==103); return h+1000 end
GetWidgetLife=function(h) return 100 end
GetUnitState=function(h, state) return 50 end
GetUnitX=function(h) return 10 end
GetUnitY=function(h) return 20 end
GetUnitCurrentOrder=function(h) return 0 end
UnitItemInSlot=function(h, slot) return slot==0 and 201 or 0 end
GetItemTypeId=function(h) assert(h==201); return 1234 end
GetItemCharges=function(h) assert(h==201); return 2 end
local m=dofile(source_path)
m.install()
assert(#records==2 and #notes==1)
assert(records[2]:find('slot=1 selected=false',1,true))
assert(records[2]:find('slot=2 selected=false',1,true))
assert(records[2]:find('item0=1234/2',1,true))
assert(records[1]:find('revision=177 MP',1,true))
assert(m.ui_receive('BEGIN',1,'abc\nxyz'))
assert(records[#records]:find('sender=2 payload=abc\\nxyz',1,true))
GetWidgetLife=function() error('simulated unavailable unit') end
assert(m.snapshot('FAILURE')==false)
assert(m.event('PLAYER_LEAVE_BEGIN','slot=1')==true)
assert(notes[#notes]:find('PLAYER_LEAVE_BEGIN',1,true))
package.loaded.hera_boot.note=function() error('simulated disk error') end
assert(m.event('DISK_FAILURE','')==false)
''')
for relative in ('hera_desync_diagnostic.lua', 'hera_gameplay_diagnostic.lua',
                 'scripts/jh/ac/player.lua', 'scripts/gameplay/hero/death/end.lua',
                 'scripts/jh/ui/server/trigger.lua'):
    lua.execute('assert(load(...))', (root / relative).read_text(encoding='utf-8'))
print('PASS: missing/unselected heroes, version identity, important events, protected failure, Lua syntax')

# 야에 E 해제 입력의 동기화 경계와 기존 A1S0 콜백을 두 Lua 환경에서 검증한다.
from pathlib import Path
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'analysis-deps'))
from lupa.lua53 import LuaRuntime

PORT = ROOT / 'hera-port'
EXTRACTED = ROOT / 'hera-rpg-validation-v149'
release_source = (PORT / 'scripts/gameplay/feature/shot/yae_release.lua').read_text(encoding='utf-8')
act_source = (PORT / 'scripts/gameplay/feature/shot/act.lua').read_text(encoding='utf-8')
basic_source = (EXTRACTED / 'scripts/gameplay/hero/heroskill/八重樱/basicskill.lua').read_text(encoding='utf-8')
loader_source = (EXTRACTED / 'scripts/system/bootstrap/module_loader.lua').read_text(encoding='utf-8')

FIXTURE = r'''
local charged = '八重樱拔刀斩蓄力'
local canceled = '八重樱拔刀斩蓄力取消'
registered, sent, orders, notes, units = {}, {}, {}, {}, {}
settimedata_calls = 0
HeroType = {['八重樱']=12345}
Hero, Xuanze, CheXuanze = {}, {}, {}
KEY = {T=84}
BQBInfo = {panel={}}
selected = 1001
for sy=1,6 do
  local h = 1000+sy
  Hero[sy], Xuanze[sy] = h, true
  units[h] = {handle=h, ownerid=sy, owner=sy-1, type=12345,
    valid=true, alive=true, ability=1, data={[charged]=true}}
  local u = units[h]
  function u:isvalid() return self.valid end
  function u:isalive() return self.alive end
  function u:hasdata(key) return self.data[key] ~= nil and self.data[key] ~= false end
  function u:settimedata(key, seconds)
    settimedata_calls = settimedata_calls + 1
    assert(key == canceled and seconds == 0.1)
    self.data[key] = true
  end
end
function S2ID(s)
  local n=0
  for i=1,#s do n=n*256+s:byte(i) end
  return n
end
function CreateTrigger() return {} end
function CreateGroup() return {} end
function TriggerAddAction(t, action) t.action=action end
function GetConvertedPlayerId(p) return p+1 end
function GetUnitTypeId(h) return units[h] and units[h].type or 0 end
function GetOwningPlayer(h) return units[h].owner end
function GetUnitAbilityLevel(h, ability)
  assert(ability == S2ID('A1S0'))
  return units[h].ability
end
function getunit(h) return units[h] end
local japi = {}
function japi.DzTriggerRegisterSyncData(t, prefix, server)
  assert(prefix=='HeraYaeRelease' and server==false)
  assert(registered[prefix]==nil)
  registered[prefix]=t
end
function japi.DzSyncData(prefix, data)
  sent[#sent+1] = {prefix=prefix,data=data}
end
function japi.DzGetTriggerSyncData() return incoming_data end
function japi.DzGetTriggerSyncPlayer() return incoming_sender end
function japi.GetRealSelectUnit() return selected end
package.loaded['jass.japi']=japi
package.loaded['hera_boot']={note=function(text) notes[#notes+1]=text end}
message={keyboard={}}
function message.order_immediate() error('unsafe message native was called') end
function message.mouse() return 0,0 end
package.loaded['jass.message']=message
package.loaded['jh.ac.player']={}
package.loaded['jass.slk']={}
package.loaded['jass.common']={}
package.loaded['hera_gameplay_diagnostic']={local_input=function()end}
package.loaded['gameplay.hero.heroskill.八重樱.skill']={}
function IssueImmediateOrderById(h, order)
  orders[#orders+1]={hero=h,order=order}
  assert(order==852138)
  -- 엔진 전송은 모의하되 해제 상태 변경은 추출된 원본 A1S0 콜백을 실행한다.
  release_callback:func({unit=h})
  return true
end
function deliver(sender, data)
  incoming_sender, incoming_data = sender, data
  registered.HeraYaeRelease.action()
end
'''


def client(local_slot=1):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(FIXTURE)
    lua.globals().LocalPlayerID = local_slot
    lua.globals().basic = lua.execute(basic_source)
    lua.execute("for _,entry in ipairs(basic) do if entry.skill=='A1S0' then release_callback=entry end end; assert(release_callback)")
    lua.globals().release = lua.execute(release_source)
    lua.execute("package.loaded['gameplay.feature.shot.yae_release']=release")
    lua.execute(act_source)
    return lua


checks = 0


def checked():
    global checks
    checks += 1


# Two separate clients initialize the receiver regardless of local player slot.
clients = [client(1), client(2)]
for lua in clients:
    lua.execute("assert(registered.HeraYaeRelease and registered.HeraYaeRelease.action); assert(#sent==0 and #orders==0)")
    checked()

# Actual E-keyup hook may send only; no gameplay callback runs until sync delivery.
clients[0].execute("assert(message.hook({type='key_up',code=69,state=0})==true); assert(#sent==1 and #orders==0 and settimedata_calls==0); assert(sent[1].prefix=='HeraYaeRelease' and sent[1].data=='E_UP'); assert(not units[1001]:hasdata('八重樱拔刀斩蓄力取消'))")
checked()
for lua in clients:
    # Different local selection/local slot must not affect the synchronized hero.
    lua.execute("selected=1006; deliver(0,'E_UP'); assert(#orders==1 and orders[1].hero==1001 and orders[1].order==852138); assert(settimedata_calls==1); assert(units[1001]:hasdata('八重樱拔刀斩蓄力取消')); assert(not units[1002]:hasdata('八重樱拔刀斩蓄力取消'))")
    checked()
    lua.execute("deliver(0,'E_UP'); assert(#orders==1 and settimedata_calls==1)")
    checked()

# Sender 2 owns hero 2 even when local selection is hero 1.
lua = client(1)
lua.execute("deliver(1,'E_UP'); assert(#orders==1 and orders[1].hero==1002); assert(not units[1001]:hasdata('八重樱拔刀斩蓄力取消'))")
checked()

invalid = {
    'forged payload owner': "deliver(0,'E_UP|2')",
    'forged payload unit': "deliver(0,'E_UP|1002')",
    'empty payload': "deliver(0,'')",
    'nil payload': "deliver(0,nil)",
    'nonstring payload': "deliver(0,852138)",
    'wrong owner': "units[1001].owner=1; deliver(0,'E_UP')",
    'non Yae': "units[1001].type=999; deliver(0,'E_UP')",
    'dead': "units[1001].alive=false; deliver(0,'E_UP')",
    'invalid unit wrapper': "units[1001].valid=false; deliver(0,'E_UP')",
    'not charging': "units[1001].data['八重樱拔刀斩蓄力']=nil; deliver(0,'E_UP')",
    'already canceled': "units[1001].data['八重樱拔刀斩蓄力取消']=true; deliver(0,'E_UP')",
    'no A1S0': "units[1001].ability=0; deliver(0,'E_UP')",
    'not selected': "Xuanze[1]=false; deliver(0,'E_UP')",
    'nil selected table': "Xuanze=nil; deliver(0,'E_UP')",
    'nil hero table': "Hero=nil; deliver(0,'E_UP')",
    'missing hero': "Hero[1]=nil; deliver(0,'E_UP')",
    'zero hero': "Hero[1]=0; deliver(0,'E_UP')",
    'low sender': "deliver(-1,'E_UP')",
    'high sender': "deliver(6,'E_UP')",
}
for name, action in invalid.items():
    lua = client()
    try:
        lua.execute(action)
        lua.execute("assert(#orders==0 and settimedata_calls==0)")
    except Exception as error:
        raise AssertionError(name) from error
    checked()

# All valid slots register locally but synchronized input targets the sender.
for slot in range(1, 7):
    lua = client(slot)
    lua.execute(f"deliver({slot-1},'E_UP'); assert(#orders==1 and orders[1].hero=={1000+slot}); assert(settimedata_calls==1)")
    checked()

# Unrelated key-up / non-Yae / already-cancelled local hook does not send release.
for setup, code in [('', 82), ('units[1001].type=999', 69), ("units[1001].data['八重樱拔刀斩蓄力取消']=true", 69)]:
    lua = client()
    if setup:
        lua.execute(setup)
    lua.execute(f"message.hook({{type='key_up',code={code},state=0}}); assert(#sent==0 and #orders==0)")
    checked()

assert 'message.order_immediate(852138)' not in act_source
assert 'local yae_release = require("gameplay.feature.shot.yae_release")' in act_source
assert 'require("gameplay.feature.shot.act")' in loader_source
assert 'return' not in act_source[:act_source.index('local yae_release = require')]
checked()

print(f'PASS {checks} scenarios: actual E-keyup hook sends sync only; two isolated Lua clients issue identical sender-derived A1S0 orders; original A1S0 callback sets the 0.1s cancellation flag; duplicate/invalid requests ignored; six player slots and unconditional registration covered.')
print('LIMITS: mocked native calls and sync transport only; not Warcraft execution, engine order acceptance, real network ordering/latency, multiplayer desync, animation, sound, damage, or visual validation.')

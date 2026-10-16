# 실제 수정 Lua의 송수신 콜백을 실행해 입력 잠금 회귀를 검사한다.
import sys
from pathlib import Path
from lupa import LuaRuntime
from fix import patch, STATE

text = patch(Path(sys.argv[1]).read_bytes()).decode('utf-8')
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute('assert(load(...))', text)
start = text.index('    on_button_clicked = function(self)')
end = text.index('\n    end\n  })', start)
send = text[start:end + len('\n    end')].strip().replace('on_button_clicked =', 'send =', 1)
start = text.index('TriggerAddAction(trg, function()')
end = text.index('\nend)', start)
receive = text[start:end + len('\nend)')].replace('TriggerAddAction(trg, function()', 'receive = function()', 1)[:-1]
lua.execute('''
LocalPlayerID = 3
Local_IsRunAliveVar = false
Local_AliceVarName = "alice"
timers = {}; sent = {}; handled = 0; sender = 3; mode = "immediate"
hero = {}; Hero = {[3]=hero}; current = ""
function getunit(u) return u end
function GetConvertedPlayerId(p) return p end
function Alice_Action(u, action, varid) handled = handled + 1 end
function uiy_hide() end
panel = {hide=function() end}
ac = {wait=function(ms, fn) assert(ms == 10000); table.insert(timers, fn) end}
japi = {
 DzGetTriggerSyncData=function() return current end,
 DzGetTriggerSyncPlayer=function() return sender end,
 DzSyncData=function(key, data)
   assert(key == "AliceUI")
   if mode == "throw" then error("send failure") end
   table.insert(sent, data)
   if mode == "immediate" then current=data; receive() end
 end
}
button={__cfg={id=1}}
''')
lua.execute(STATE + '\n' + send + '\n' + receive)
lua.execute('''
send(button); assert(not Local_IsRunAliveVar and handled == 1)
Local_AliceVarName = "rabbit"; send(button)
assert(not Local_IsRunAliveVar and handled == 2)
mode="deferred"; send(button); assert(Local_IsRunAliveVar)
local count=#sent; send(button); assert(#sent == count)
current=sent[#sent]; receive(); assert(not Local_IsRunAliveVar and handled == 3)
mode="throw"; send(button); assert(not Local_IsRunAliveVar)
mode="deferred"; send(button); local old=sent[#sent]
timers[#timers](); assert(not Local_IsRunAliveVar)
Local_AliceVarName="other"
send(button); local new=sent[#sent]; assert(Local_IsRunAliveVar)
current=old; receive(); assert(Local_IsRunAliveVar)
current=new; receive(); assert(not Local_IsRunAliveVar)
send(button); Hero[3]=nil; current=sent[#sent]; receive()
assert(not Local_IsRunAliveVar); Hero[3]=hero
send(button); current="invalid"; receive(); assert(Local_IsRunAliveVar)
timers[#timers](); assert(not Local_IsRunAliveVar)
send(button); current=sent[#sent]; sender=2; receive(); assert(Local_IsRunAliveVar)
sender=3; receive(); assert(not Local_IsRunAliveVar)
send(button); local first=sent[#sent]; timers[#timers]()
send(button); assert(sent[#sent] == first)
local before=handled; current=first; receive(); receive()
assert(handled == before + 1 and not Local_IsRunAliveVar)
send(button); assert(sent[#sent] ~= first)
''')
print('PASS: full Lua syntax; immediate, deferred, duplicate click, send failure, timeout, late reply, missing hero, malformed reply, other player')

original = Path(sys.argv[1]).read_text(encoding='utf-8')
start = original.index('    on_button_clicked = function(self)')
end = original.index('\n    end\n  })', start)
original_send = original[start:end + len('\n    end')].strip()
race = LuaRuntime()
race.execute('''
Local_IsRunAliveVar = false; Local_AliceVarName = "alice"
panel = {hide=function() end}; function uiy_hide() end
japi = {DzSyncData=function() Local_IsRunAliveVar=false end}
''')
race.execute(original_send)
race.execute('on_button_clicked({__cfg={id=1}}); assert(Local_IsRunAliveVar)')
print('PASS: original callback reproduces stuck lock with an immediate response')

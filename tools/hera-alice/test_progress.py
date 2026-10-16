# 실제 앨리스 이벤트 함수의 비용과 진행 결과 및 재시도 중복 방지를 검사한다.
import sys
from pathlib import Path
from lupa import LuaRuntime
from fix import patch, STATE

original = Path(sys.argv[1]).read_text(encoding='utf-8')
changed = patch(Path(sys.argv[1]).read_bytes()).decode('utf-8')

def actions(text):
    start = text.index('local function senchange(')
    end = text.index('\nlocal trg = CreateTrigger()', start)
    return text[start:end]

old_actions = actions(original)
new_actions = actions(changed)
assert old_actions.replace('  if u:islocal() then\n    Local_IsRunAliveVar = false\n  end\n', '') == new_actions

MOCK = '''
ALICE_ACTION={TALK=1,VOW=2,VIOLATE=3,KILL=4,LOVE=5,HIT=6}
LocalPlayerID=3; Local_IsRunAliveVar=false; sender=3; current=""
Local_AliceVarName="睡鼠"; timers={}; sent={}; notes={}; war=0
function print() end
function noop() end
Local_AliceKuaijietubiao={set_alpha=noop,show2={set_alpha=noop}}
class={panel={builder=function() return {destroy=noop} end}}
hero={ownerid=3,data={},gold=2000,items={},effects=0,advanced=0,changes=0}
function hero:islocal() return true end
function hero:getdata(k) return self.data[k] or 0 end
function hero:hasdata(k) return self.data[k] ~= nil and self.data[k] ~= false and self.data[k] ~= 0 end
function hero:setdata(k,v) self.data[k]=v==nil and true or v end
function hero:changedata(k,v) self.data[k]=self:getdata(k)+v end
function hero:sendmessage(s) table.insert(notes,s) end
function hero:getgold() return self.gold end
function hero:addgold(v) self.gold=self.gold+v end
function hero:ishasitem(k) return self.items[k]~=nil end
function hero:getitem(k) return self.items[k] end
function hero:additem(k) self.items[k]={charges=1} end
function hero:uivar_get(k)
 return {get_width=function() return 1 end,get_height=function() return 1 end,
 vardata={effectname=k,effectsytext="effect",effectsy=function(u) u.effects=u.effects+1 end}}
end
function hero:uivar_change() self.changes=self.changes+1 end
function hero:playselfsound() self.sounds=(self.sounds or 0)+1 end
function ChangeZhanzhengqiyue(n) war=war+n end
function GetItemCharges(i) return i.charges end
function ChangeItemCount(i,n) i.charges=i.charges+n end
function ChangeValue(t,k,n) t[k]=t[k]+n end
KillCount={[3]=600}
AdvanceGet={['罗丽娜']=function(u) u.advanced=u.advanced+1 end}
Hero={[3]=hero,[2]=hero}
function getunit(u) return u end
function GetConvertedPlayerId(p) return p end
panel={hide=noop}; uiy_hide=noop
ac={wait=function(_,fn) table.insert(timers,fn) end}
japi={DzGetTriggerSyncData=function() return current end,
 DzGetTriggerSyncPlayer=function() return sender end,
 DzSyncData=function(_,data) table.insert(sent,data) end}
button={__cfg={id=2}}
hero.data['梦游仙境-冒险点']=20
hero.data['梦游仙境-sen值']=50
hero.data['童话变异数量']=9
'''

def make(text, network=False):
    lua = LuaRuntime(unpack_returned_tuples=True)
    body = MOCK + STATE + actions(text)
    if network:
        start = text.index('    on_button_clicked = function(self)')
        end = text.index('\n    end\n  })', start)
        body += '\n' + text[start:end + len('\n    end')].strip().replace('on_button_clicked =', 'send =', 1)
        start = text.index('TriggerAddAction(trg, function()')
        end = text.index('\nend)', start)
        body += '\n' + text[start:end + len('\nend)')].replace('TriggerAddAction(trg, function()', 'receive = function()', 1)[:-1]
    body += '\nact=Alice_Action'
    lua.execute(body)
    return lua

def snapshot(lua):
    return lua.execute('''
      local result={}
      for k,v in pairs(hero.data) do table.insert(result,k.."="..tostring(v)) end
      for _,k in ipairs({'gold','effects','advanced','changes','sounds'}) do
        table.insert(result,k.."="..tostring(hero[k]))
      end
      for k,v in pairs(hero.items) do table.insert(result,k.."="..v.charges) end
      table.insert(result,"kills="..KillCount[3]);table.insert(result,"war="..war)
      for i,v in ipairs(notes) do table.insert(result,"note"..i.."="..v) end
      table.sort(result);return table.concat(result,"\\n")
    ''')

cases = {
    'talk': 'act(hero,1,"睡鼠")',
    'vow': 'act(hero,2,"睡鼠"); assert(hero.gold==1500 and hero.effects==1 and hero:getdata("梦游仙境-冒险点")==19)',
    'no adventure points': 'hero.data["梦游仙境-冒险点"]=0;act(hero,2,"睡鼠");assert(hero.gold==2000 and hero.effects==0)',
    'insufficient gold': 'hero.gold=499;act(hero,2,"睡鼠");assert(hero.effects==0)',
    'love': 'act(hero,5,"睡鼠");assert(hero:getdata("梦游仙境-sen值")==60)',
    'hostile actions': 'act(hero,3,"睡鼠");act(hero,3,"睡鼠");assert(war==1)',
    'kill penalty': 'act(hero,4,"蜥蜴比尔");assert(hero:getdata("幸运")==-5)',
    'kill item': 'act(hero,4,"贾布加布");assert(hero:ishasitem("I0P7"))',
    'hit': 'act(hero,6,"莉耶芙");assert(hero.sounds==1)',
    'queen advance': 'hero:setdata("特殊判定-爱丽丝初始");hero:setdata("梦游仙境-红心女王已誓约");hero.items.I09P={charges=5};act(hero,1,"红心女王");assert(hero.advanced==1 and KillCount[3]==300 and hero.items.I09P.charges==0)',
    'queen missing vow': 'hero:setdata("特殊判定-爱丽丝初始");hero.items.I09P={charges=5};act(hero,1,"红心女王");assert(hero.advanced==0)',
    'tenth event': 'hero:setdata("梦游仙境-累积消耗冒险点",9);hero:setdata("变异判定-贾布加布");hero:setdata("变异判定-睡鼠");act(hero,5,"睡鼠");assert(hero:hasdata("梦游仙境-睡鼠已杀害") and hero:hasdata("梦游仙境-贾布加布已杀害"))',
}
for name, case in cases.items():
    before, after = make(original), make(changed)
    before.execute(case); after.execute(case)
    assert snapshot(before) == snapshot(after), name
    print('PASS original/new progression:', name)

lua = make(changed, True)
lua.execute('''
send(button); local first=sent[#sent]; timers[#timers]()
send(button); assert(first==sent[#sent])
current=first; receive(); receive()
assert(hero.gold==1500 and hero.effects==1 and hero:getdata("梦游仙境-冒险点")==19)
Local_AliceVarName="三月兔";send(button);current=sent[#sent];receive()
assert(hero.gold==1000 and hero.effects==2 and hero:getdata("梦游仙境-冒险点")==18)
''')
print('PASS actual VOW: timeout + retry + delayed duplicate charges once; another card still works')

lua = make(changed, True)
lua.execute('''
button.__cfg.id=5;send(button);local request=sent[#sent]
sender=2;current=request;receive();sender=3;receive()
assert(hero:getdata("梦游仙境-相爱次数")==2)
receive();assert(hero:getdata("梦游仙境-相爱次数")==2)
send(button);current=sent[#sent];receive()
assert(hero:getdata("梦游仙境-相爱次数")==3)
''')
print('PASS per-player request identity and intentional repeated action after acknowledgement')

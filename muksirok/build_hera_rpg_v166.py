# 복원 지형과 리소스 및 Lua를 원래 파일 해시로 재포장한 헤라 초기화 검증 맵을 만든다.
import pathlib,struct,json,hashlib,re,zlib,os
WORK=pathlib.Path(__file__).parent
ROOT=pathlib.Path(os.environ['HERA_ASSET_ROOT'])
PORT=WORK/'hera-port'
OUT=pathlib.Path(os.environ.get('HERA_MAP_OUT',str(WORK/'Hera_RPG_Init_v166.w3x')))
OUT.parent.mkdir(parents=True,exist_ok=True)
SRC=WORK/'build-artifacts';SRC.mkdir(exist_ok=True)
TITLE='Hera RPG initialization v166'
TABLE=[0]*1280;seed=0x100001
for i in range(256):
    for j in range(5):
        seed=(seed*125+3)%0x2aaaab;a=(seed&65535)<<16
        seed=(seed*125+3)%0x2aaaab;TABLE[i+j*256]=a|(seed&65535)
def pack(fmt,*args):return struct.pack('<'+fmt,*args)
def nh(name,kind):
    a,b=0x7fed7fed,0xeeeeeeee
    for c in name.replace('/','\\').upper().encode('utf-8'):
        a=TABLE[kind*256+c]^((a+b)&0xffffffff)
        b=(c+a+b+(b<<5)+3)&0xffffffff
    return a
def key(name):return (nh(name,1),nh(name,2))
def encrypt(data,k):
    out=bytearray();s=0xeeeeeeee
    for (v,) in struct.iter_unpack('<I',data):
        s=(s+TABLE[0x400+(k&255)])&0xffffffff
        out+=pack('I',v^((k+s)&0xffffffff))
        k=((((~k&0xffffffff)<<21)+0x11111111)|(k>>11))&0xffffffff
        s=(v+s+(s<<5)+3)&0xffffffff
    return out
def compress(data):
    if not data:return data,0x80000000
    chunks=[]
    for start in range(0,len(data),4096):
        raw=data[start:start+4096];encoded=b'\x02'+zlib.compress(raw,6)
        chunks.append(encoded if len(encoded)<len(raw) else raw)
    offsets=[4*(len(chunks)+1)]
    for c in chunks:offsets.append(offsets[-1]+len(c))
    blob=pack(str(len(offsets))+'I',*offsets)+b''.join(chunks)
    return (blob,0x80000200) if len(blob)<len(data) else (data,0x80000000)

outer=json.loads((ROOT/'all-payload-decryption.json').read_text())['files']
jrp={x['id']:x for x in json.loads((ROOT/'jrp-decryption-report.json').read_text())['files']}
names={}
for x in outer:
    if x.get('name'):names[(x['hash_a'],x['hash_b'])]=x['name']
for report in ['recovered-reference-names.json','lua-resource-name-matches.json']:
    for x in json.loads((ROOT/report).read_text(encoding='utf-8')):
        k=tuple(int(v,16) for v in x['id'].split('_'))
        assert key(x['name'])==k,(report,x['name'])
        names.setdefault(k,x['name'])
for n in ['common.j','scripts/common.j','blizzard.j','scripts/blizzard.j','common.ai','callback','new_callback','Kkmap.jc','war3map.jc','jass_loader.dll']:
    if any((x['hash_a'],x['hash_b'])==key(n) for x in outer):names[key(n)]=n

forbidden={key(n) for n in ['callback','new_callback','Kkmap.jc','war3map.jc','jass_loader.dll']}
files={};excluded=[]
for x in outer:
    k=(x['hash_a'],x['hash_b'])
    if x['type']=='PE' or x['magic'] in ['45485441','4d484542'] or k in forbidden:
        excluded.append({'id':x['id'],'name':names.get(k),'magic':x['magic'],'reason':'Chinese executable/loader or unresolved encrypted code container'})
        continue
    asset=jrp.get(x['id'],x)
    p=ROOT/asset['output']
    files[k]={'name':names.get(k),'path':p,'expected_sha256':asset['sha256'],'origin':'restored JRP asset' if x['id'] in jrp else 'authenticated outer file'}

def add(name,data,origin):
    files[key(name)]={'name':name,'data':data,'origin':origin}

ability_name='Units/AbilityData.slk'
ability_old=files[key(ability_name)]['path'].read_bytes()
assert hashlib.sha256(ability_old).hexdigest()=='7cfc9fcc4f0828589e5ef2b1e9ae80e905a30b0be1f54b7a1ca1e420ce5a20ca'
before=b'C;X22;K0.0\r\nC;X23;K-0.25\r\nC;X24;K-0.25\r\nC;X33;K"B0AC"'
after=b'C;X22;K0.0\r\nC;X23;K-0.5\r\nC;X24;K-0.5\r\nC;X33;K"B0AC"'
assert ability_old.count(before)==1
ability_new=ability_old.replace(before,after)
assert hashlib.sha256(ability_new).hexdigest()=='0671870a8de2c17b175c2414d2aa74e95e4a9fa91bdbfb15a53b10e0ec8171bc'
add(ability_name,ability_new,'authenticated official 0.1.6b ability data delta')

original=(ROOT/'decrypted-map-files/war3map.j').read_text(encoding='utf-8')
assert original.count('DzGetUnitNeededXP')==1
original=re.sub(r'(?m)^([ \t]*native DzGetUnitNeededXP[^\r\n]*)',r'// 헤라 JN 선언과 설치 DLL에서 찾지 못한 미호출 중국 전용 선언이다.\n//\1',original,count=1)
bridge=(PORT/'hera_ui_bridge.j').read_text(encoding='utf-8')
bg=re.search(r'\bglobals\s*\n(.*?)\bendglobals\b',bridge,re.S);assert bg
natives=bridge[:bg.start()]
functions=bridge[bg.end():]
bridge_names=set(re.findall(r'(?m)^native\s+(\w+)',natives))
# 원래 지도에 있던 동일 네이티브 선언만 제거해 추가 선언과 중복되지 않게 한다.
original=re.sub(r'(?m)^[ \t]*native\s+(\w+)[^\r\n]*\r?\n',lambda m:'' if m[1] in bridge_names else m[0],original)
original=re.sub(r'\bglobals\s*\n',lambda m:m[0]+bg[1]+'    boolean HeraBootScheduled = false\n    integer HeraDiagnosticPanel = 0\n    integer HeraDiagnosticText = 0\n',original,count=1)
boot_jass='''
// 메시지 프레임이 이동되거나 숨겨져도 읽을 수 있는 진단 전용 UI다.
function HeraBootDisplay takes string result returns nothing
    if HeraDiagnosticText == 0 then
        call DzLoadToc("HeraDiagnostic.toc")
        set HeraDiagnosticPanel = DzCreateFrameByTagName("BACKDROP", "HeraDiagnosticPanel", DzGetGameUI(), "HeraDiagnosticBackground", 0)
        set HeraDiagnosticText = DzCreateFrameByTagName("TEXT", "HeraDiagnosticText", HeraDiagnosticPanel, "HeraDiagnosticText", 0)
    endif
    if HeraDiagnosticPanel != 0 and HeraDiagnosticText != 0 then
        call DzFrameClearAllPoints(HeraDiagnosticPanel)
        call DzFrameSetAbsolutePoint(HeraDiagnosticPanel, 0, 0.025, 0.48)
        call DzFrameSetSize(HeraDiagnosticPanel, 0.75, 0.285)
        call DzFrameSetPriority(HeraDiagnosticPanel, 1000)
        call DzFrameClearAllPoints(HeraDiagnosticText)
        call DzFrameSetPoint(HeraDiagnosticText, 0, HeraDiagnosticPanel, 0, 0.008, -0.008)
        call DzFrameSetSize(HeraDiagnosticText, 0.734, 0.269)
        call DzFrameSetPriority(HeraDiagnosticText, 1001)
        call DzFrameSetAlpha(HeraDiagnosticPanel, 255)
        call DzFrameSetAlpha(HeraDiagnosticText, 255)
        call DzFrameSetText(HeraDiagnosticText, result)
        call DzFrameShow(HeraDiagnosticPanel, true)
        call DzFrameShow(HeraDiagnosticText, true)
    else
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 180.0, result)
    endif
endfunction

function HeraBootShow takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_boot').summary()")
    call HeraBootDisplay(result)
endfunction

function HeraBootHide takes nothing returns nothing
    if HeraSceneTestText != 0 then
        call DzFrameShow(HeraSceneTestText, false)
    endif
    if HeraDiagnosticPanel != 0 then
        call DzFrameShow(HeraDiagnosticPanel, false)
    endif
endfunction

function HeraBootRefresh takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call HeraBootShow()
endfunction

function HeraBootLightTest takes nothing returns nothing
    local string result
    if GetLocalPlayer() == GetTriggerPlayer() then
        call HeraBootHide()
        set result = EXExecuteScript("require('hera_scene_diagnostic').test_lighting()")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 15.0, result)
    endif
endfunction

// 시야 비교는 다른 사람과 진행 중인 게임에서 실행하지 않는다.
function HeraBootSceneTest takes nothing returns nothing
    local integer i = 0
    local integer humans = 0
    local string result
    loop
        exitwhen i >= 12
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
            set humans = humans + 1
        endif
        set i = i + 1
    endloop
    if GetLocalPlayer() == GetTriggerPlayer() then
        if humans == 1 then
            call HeraBootHide()
            set result = EXExecuteScript("require('hera_scene_diagnostic').test_scene()")
        else
            set result = "Scene comparison requires a single human player."
        endif
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 10.0, result)
    endif
endfunction

function HeraBootRun takes nothing returns nothing
    local string result
    local trigger chat = CreateTrigger()
    local trigger hideChat = CreateTrigger()
    local trigger lightChat = CreateTrigger()
    local trigger sceneChat = CreateTrigger()
    call HeraUIBridgeInitialize()
    call DestroyTimer(GetExpiredTimer())
    call TriggerRegisterPlayerChatEvent(chat, Player(0), "-hera", true)
    call TriggerAddAction(chat, function HeraBootShow)
    call TriggerRegisterPlayerChatEvent(hideChat, Player(0), "-hera-hide", true)
    call TriggerAddAction(hideChat, function HeraBootHide)
    call TriggerRegisterPlayerChatEvent(lightChat, Player(0), "-hera-light", true)
    call TriggerAddAction(lightChat, function HeraBootLightTest)
    call TriggerRegisterPlayerChatEvent(sceneChat, Player(0), "-hera-scene", true)
    call TriggerAddAction(sceneChat, function HeraBootSceneTest)
    set result = EXExecuteScript("require('hera_boot').start()")
    // 진단 로그는 유지하며 패널은 -hera 명령으로만 연다.
    call HeraBootHide()
    set chat = null
    set hideChat = null
    set lightChat = null
    set sceneChat = null
endfunction
'''
original=re.sub(r'(?m)^function ',lambda m:functions+'\n'+boot_jass+'\nfunction ',original,count=1)
replacement='''function initializePlugin takes nothing returns integer
    if not HeraBootScheduled then
        set HeraBootScheduled = true
        call TimerStart(CreateTimer(), 3.0, false, function HeraBootRun)
    endif
    return 0
endfunction'''
original,n=re.subn(r'function initializePlugin takes nothing returns integer.*?endfunction',replacement,original,count=1,flags=re.S);assert n==1
original,n=re.subn(r'call SetMapName\("[^"\r\n]*"\)',f'call SetMapName("{TITLE}")',original,count=1);assert n==1
jass='// 복원 RPG의 지도 초기화 뒤 헤라 Lua 초기화 검사를 실행한다.\n'+ 'native EXExecuteScript takes string script returns string\n'+natives+'\n'+original
assert 'exec-lua:plugin_main' not in jass and '"callback"' not in jass
(SRC/'war3map.j').write_text(jass,encoding='utf-8')
add('war3map.j',jass.encode('utf-8'),'recovered JASS with Hera initialization entry')

w3i=(ROOT/'decrypted-map-files/war3map.w3i').read_bytes();assert struct.unpack_from('<I',w3i)[0]==25
end=w3i.index(b'\0',12)
w3i=w3i[:12]+TITLE.encode()+b'\0'+w3i[end+1:]
(SRC/'war3map.w3i').write_bytes(w3i)
add('war3map.w3i',w3i,'original W3I with test title')

lua_count=0
for p in sorted((ROOT/'recovered-lua-source').rglob('*.lua')):
    if p.relative_to(ROOT/'recovered-lua-source').as_posix()=='scripts/gameplay/var/pools/mwx/danwanlunpo_search_site.lua':continue
    add(p.relative_to(ROOT/'recovered-lua-source').as_posix(),p.read_bytes(),'recovered Lua source');lua_count+=1
for p in sorted(PORT.rglob('*.lua')):
    if p.name=='hera_ui_compat.lua':continue
    add(p.relative_to(PORT).as_posix(),p.read_bytes(),'Hera source overlay')
for p in sorted((ROOT/'hera-rpg-assets-v3').rglob('*')):
    if p.is_file():add(p.relative_to(ROOT/'hera-rpg-assets-v3').as_posix(),p.read_bytes(),'prepackaged UI definition with native verification template')
for p in sorted((ROOT/'hera-rpg-assets-v7').rglob('*')):
    if p.is_file():
        name=p.relative_to(ROOT/'hera-rpg-assets-v7').as_posix()
        assert key(name) not in files,('v7 asset would replace existing archive data',name)
        add(name,p.read_bytes(),'Hera diagnostic UI or missing transparent background')
for p in sorted((ROOT/'hera-rpg-assets-v12').rglob('*')):
    if p.is_file() and p.suffix.lower() in ('.mdx','.blp'):
        name=p.relative_to(ROOT/'hera-rpg-assets-v12').as_posix()
        data=p.read_bytes()
        if key(name) in files:
            previous=files[key(name)]
            old_data=previous['data'] if 'data' in previous else previous['path'].read_bytes()
            assert old_data==data,('HUD asset conflicts with original map',name)
        add(name,data,'audited HUD model or texture from installed model pack/base MPQ')
# 카드 이미지와 한국어 글꼴만 포함하며 기존 맵 리소스는 교체하지 않는다.
for directory, extensions, origin in [
    ('hera-card-assets-v46', ('.blp','.tga'), 'audited card texture from installed TLOC0.04b2'),
    ('hera-rpg-assets-v46', ('.ttf','.txt'), 'NanumGothic regular with OFL license')]:
    for p in sorted((ROOT/directory).rglob('*')):
        if p.is_file() and p.suffix.lower() in extensions:
            name=p.relative_to(ROOT/directory).as_posix()
            assert key(name) not in files,('v46 asset conflicts with existing map',name)
            add(name,p.read_bytes(),origin)
for race in ['Human','NightElf','Orc','Undead']:
    name=f'UI/Console/{race}/{race}UI-TimeIndicator.mdx'
    assert key(name) not in files,('clock override unexpectedly replaces map asset',name)
    add(name,(ROOT/'hera-empty-clock-v15.mdx').read_bytes(),'empty native clock; custom Lua clock remains')
known=sorted({v['name'] for v in files.values() if v['name']})
add('(listfile)',('\r\n'.join(known+['(listfile)'])+'\r\n').encode('utf-8'),'known-name list; opaque hashes retained separately')

# 이름을 복원하지 못한 항목도 원래 두 해시로 보존한다. 빈 칸을 삭제 표식으로
# 채우면 조회가 빈 칸에서 중단되지 않고 해시 표를 한 바퀴 검사할 수 있다.
count=1
while count<len(files)*1.25:count*=2
hashes=[None]*count
rows=sorted(files.items(),key=lambda kv:(kv[1]['name'] is None,kv[1]['name'] or str(kv[0])))
blocks=[];manifest=[]
prefix=b'HM3W'+pack('I',0)+TITLE.encode()+b'\0'+pack('2I',0x60,12)
temp=OUT.with_suffix('.building')
with temp.open('wb') as f:
    f.write(prefix.ljust(512,b'\0'));f.write(b'\0'*32)
    for index,(k,entry) in enumerate(rows):
        data=entry['data'] if 'data' in entry else entry['path'].read_bytes()
        digest=hashlib.sha256(data).hexdigest()
        if 'expected_sha256' in entry:assert digest==entry['expected_sha256'],entry
        stored,flags=compress(data)
        offset=f.tell()-512;f.write(stored)
        blocks.append(pack('4I',offset,len(stored),len(data),flags))
        slot=nh(entry['name'],0)%count if entry['name'] else index%count
        while hashes[slot] is not None:slot=(slot+1)%count
        hashes[slot]=pack('2I2HI',*k,0,0,index)
        manifest.append({'name':entry['name'],'hash_a':k[0],'hash_b':k[1],'block':index,'offset':offset,'bytes':len(data),'stored_bytes':len(stored),'flags':flags,'sha256':digest,'origin':entry['origin']})
    hpos=f.tell()-512
    deleted=pack('4I',0xffffffff,0xffffffff,0xffffffff,0xfffffffe)
    f.write(encrypt(b''.join(v or deleted for v in hashes),nh('(hash table)',3)))
    bpos=f.tell()-512;f.write(encrypt(b''.join(blocks),nh('(block table)',3)))
    size=f.tell()-512
    f.seek(512);f.write(b'MPQ\x1a'+pack('IIHH4I',32,size,0,3,hpos,bpos,count,len(blocks)))
temp.replace(OUT)
report={'revision':166,'map':str(OUT),'bytes':OUT.stat().st_size,'sha256':hashlib.sha256(OUT.read_bytes()).hexdigest(),'files':len(rows),'known_names':sum(x['name'] is not None for x in manifest),'opaque_hashes':sum(x['name'] is None for x in manifest),'recovered_lua':lua_count,'jrp_assets':len(jrp),'excluded':excluded,'hash_table_slots':count,'empty_slots':0,'deleted_slots':count-len(rows),'status':'initialization test; no v166 game runtime validation','entries':manifest}
(SRC/'hera-rpg-build.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k!='entries'}))

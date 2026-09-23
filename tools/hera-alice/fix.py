# 앨리스 대화 입력 잠금과 동기화 수신 처리를 수정한다.
import hashlib

SOURCE_HASH = '124b7c6ce63527d16a8f0999bea5ff44c6359ae71f3d02b5e75a909ebfe49eac'
STATE = '''
-- 요청 전에 잠그고 해당 요청의 수신 또는 시간 초과에서만 해제한다.
local ALICE_SYNC_KEY = "AliceUI"
local alice_sequence = 0
local alice_pending = nil
local function alice_unlock(sequence)
  if alice_pending == sequence then
    alice_pending = nil
    Local_IsRunAliveVar = false
  end
end
'''
SEND = '''      if Local_IsRunAliveVar then
        return
      end
      alice_sequence = alice_sequence + 1
      local sequence = alice_sequence
      local msg = tostring(sequence) .. "|" .. tostring(cfg.id) .. "|" .. Local_AliceVarName
      Local_UIButton = self
      alice_pending = sequence
      Local_IsRunAliveVar = true
      panel:hide()
      uiy_hide()
      ac.wait(10000, function()
        if alice_pending == sequence then
          alice_unlock(sequence)
          print("ALICE UI timeout request=" .. tostring(sequence))
        end
      end)
      local ok, err = pcall(japi.DzSyncData, ALICE_SYNC_KEY, msg)
      if not ok then
        alice_unlock(sequence)
        print("ALICE UI send failed request=" .. tostring(sequence) .. " error=" .. tostring(err))
      end
'''
RECEIVE = '''  local sequence, action, varid = data:match("^(%d+)|(%d+)|([^|]+)$")
  sequence = tonumber(sequence)
  action = tonumber(action)
  if sy == LocalPlayerID then
    alice_unlock(sequence)
  end
  local u = getunit(Hero[sy])
  if not u or not action or not varid then
    return
  end
  print("ALICE UI receive player=" .. tostring(sy) .. " request=" .. tostring(sequence))
  Alice_Action(u, action, varid)
'''

def patch(source):
    if hashlib.sha256(source).hexdigest() != SOURCE_HASH:
        raise ValueError('검증된 v177 앨리스 소스와 다릅니다.')
    text = source.decode('utf-8').replace('\r\n', '\n')
    replacements = [
        ('Local_AliceKuaijietubiao = nil\n', 'Local_AliceKuaijietubiao = nil\n' + STATE),
        ('''      local msg = tostring(cfg.id) .. "|" .. Local_AliceVarName
      japi.DzSyncData("爱丽丝UI", msg)
      Local_UIButton = self
      Local_IsRunAliveVar = true
      panel:hide()
      uiy_hide()
''', SEND),
        ('''local function Alice_Action(u, action, varid)
  if u:islocal() then
    Local_IsRunAliveVar = false
  end
''', 'local function Alice_Action(u, action, varid)\n'),
        ('japi.DzTriggerRegisterSyncData(trg, "爱丽丝UI", false)',
         'japi.DzTriggerRegisterSyncData(trg, ALICE_SYNC_KEY, false)'),
        ('''  local u = getunit(Hero[sy])
  if not u then
    return
  end
  local action, varid = data:match("^([^|]+)|([^|]+)$")
  action = tonumber(action)
  Alice_Action(u, action, varid)
''', RECEIVE),
    ]
    for old, new in replacements:
        if text.count(old) != 1:
            raise ValueError('수정 지점이 유일하지 않습니다.')
        text = text.replace(old, new, 1)
    return text.encode('utf-8')

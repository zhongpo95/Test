-- 성유 약제 사용 전후의 엔진 수량 및 보상 대기 상태를 제한된 횟수만 기록한다.
local M = {}
local count = 0
local function note(sample, phase)
  local exists = GetItemTypeId(sample.item) ~= 0
  require('hera_boot').note('MEDICINE TRACE #'..sample.id..' '..phase..
    '; item='..tostring(sample.item)..'; exists='..tostring(exists)..
    '; charges='..tostring(exists and GetItemCharges(sample.item) or 0)..
    '; choice='..tostring(sample.unit:hasdata('系统-正在选择选项')))
end
function M.begin(unit, item)
  if count >= 24 then return nil end
  count = count + 1
  local sample = {id=count,unit=unit,item=item}
  note(sample,'before')
  return sample
end
function M.finish(sample)
  note(sample,'after Lua')
  ac.wait(100, function() note(sample,'after engine') end)
end
return M

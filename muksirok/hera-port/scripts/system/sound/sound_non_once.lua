-- 헤라 난이도·공유 가방 효과음은 초기화 때 만든 사운드 핸들을 재사용한다.
local M = {}
M.names = {
  "Sound_42_Caidan",
  "Sound_Anshen_1",
  "Sound_Anshen_2",
  "Sound_Anshen_feng1",
  "Sound_BOSS_Wj",
  "Sound_Lianlian_Dianhua4",
  "Sound_Motuoche_2",
  "Sound_Yansuanbaozhu",
  "Sound_Ym_F02_2",
  "Sound_Ym_F03",
  "Sound_Ym_F03_2",
  "BOSS_Zhenhong_Shijiezhiyan",
  "BGM_Baoming_06",
  "BGM_Fangyuan_01",
  "BGM_Gesi_01",
  "BGM_Kongtaoluo_01",
  "BGM_Ktl_N02",
  "BGM_Ktl_N03",
  "BGM_Leilv_Caidan",
  "BGM_Lianlian_Shenhua2",
  "BGM_Meilizhiwu",
  "BGM_Mozi_Ly_01",
  "BGM_Mozi_Ly_02",
  "BGM_Mozi_Zhansha_01",
  "BGM_Mozi_Zhansha_02",
  "BGM_Shiki_12",
  "BGM_Shuangxing_01",
  "BGM_Shuangxing_02",
  "BGM_Tanzhilang",
  "BGM_UI_Buy",
  "BGM_Umzs",
  "BGM_Umzs2",
  "BGM_Xiyinvpu_01",
  "BGM_Yangjian_Cq",
  "BGM_YcPro_15",
  "BGM_Youmu_01",
  "BGM_Youmu_02",
  "BGM_Ysml_01",
  "Movie_Dream_49",
  "Nanaya_BGM2",
  "NanayaYinxiao__8_u",
  "Srtr_Modao",
  "Tina1",
  "UI_Start_MouseDown",
  "UI_Start_MouseEnter",
  "Sound_Beibao_Open",
  "Sound_UI_Buy",
  "WJ_BGM2",
  "Youmu_ACR_Start",
  "Youmu_DCA_Start",
  "duizhang_baojutaici",
  "zhigui_zhanji3"
}

function M.contains(name)
  if type(name) ~= "string" then
    return false
  end
  for _, item in ipairs(M.names) do
    if item == name then
      return true
    end
  end
  return false
end

return M

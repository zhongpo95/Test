-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local ys = YisiSystem or require("gameplay.feature.yisi")
local japi = require("jass.japi")
local yshelp = {}

local function getrandomplayername()
  local count = 0
  local namez = {}
  for i = 1, 6 do
    if Hero[i] ~= 0 then
      local name = getunit(Hero[i]):getplayername()
      if name ~= "玩家 16" then
        count = count + 1
        namez[count] = name
      end
    end
  end
  if 0 < #namez then
    local sj = ys.GetRandomInt(#namez)
    return namez[sj]
  else
    return "城之内"
  end
end

local kongxianbreaktime = 3
local kongxianoption = false
local kongxianchat = {
  {
    name = "I......I......I↓ must↑ be→ the↓ reason→↑ why→You↓have ↑given →up →your smiles↑",
    func = nil
  },
  {
    name = "又开始带魂魄妖梦节奏了，我真是服了魂魄妖梦是这个游戏唯一的完美自机，已经和劫后传融为一体，成了劫后传的底层逻辑，成名绝技放手一搏给劫后传带来了这个游戏最经典的博弈，创造了劫后传的黄金时代，削魂魄妖梦，你想毁了这个游戏吗？ 我很难想象一个精神状态正常的劫后玩家为什么会做出“不玩魂魄妖梦”这种选择。玩劫后传，不玩魂魄妖梦，那玩什么呢？没错，无非就是白粥梓、卡斯特，博丽灵梦和威震天这种阴间自机；这样不玩魂魄妖梦的玩家，素质品味修养真的很低。玩劫后传，就得玩魂魄妖梦人！就得放手一搏！相较于那些不玩魂魄妖梦的人，素质整整提高了两个档次。而那些不玩魂魄妖梦的人，只能说他们，完全不懂操作，只会玩打枪，只为赢真红而玩打枪，根本没有把这种行为上升到操作的高度，这样的人，品味真的很低。",
    func = nil
  },
  {
    name = "你知道么,我已经……看到了结局!",
    func = nil
  },
  {
    name = "宿敌就是宿敌啊!宿敌是不可以变成妻子的!",
    func = nil
  },
  {
    name = "萨菲罗斯！男人中的男人！王！大师！男神帝王！！魔王压倒性的男人！人类游戏建模史上永垂不朽的！巅！！峰！！！",
    func = nil
  },
  {
    name = "你可能不知道，特雷西娅下葬的那天下了雪，风刮的阴冷如冬，四周空无一人。啊，我听见了源石尘呼啸的声音。",
    func = nil
  },
  {
    name = "你在哪，普瑞赛斯?你在我无法抵达的地方憎恨着我吗？你在我身边是吧?是这样吧！不是在我脚下，而是和我一样在地上！！！",
    func = nil
  },
  {
    name = "是的凯尔希，折磨我吧，只要我还活着，就不要让我安息！是的，撕碎我吧。用痛苦把我逼疯吧！如此一来凯尔希也会原谅我一些了吧...",
    func = nil
  },
  {
    name = "“在泰拉文明，我们都是让博士痛苦的凶手!我们只是和你一样...我们拼命搜寻博士的每一段记忆，可没有一个文明不会给博士带来痛苦!我们的故事注定以悲剧收场!”",
    func = nil
  },
  {
    name = "为什么博士不能快乐，为什么博士连一点点幸福都不被允许?\n“只有一个理由，那就是我们，是泰拉文明的存在让博士陷入了痛苦和不幸...!”\n每一个博士......都因我们的文明痛苦......如果他对我们的记忆从世上消失，那每一个博士就都能幸福了吗？",
    func = nil
  },
  {
    name = "“是的，他会的。所以...现在还不晚。为了让所有的博士...拜托，邀请我到你们的世界，这样，我们就能消除博士的记忆，一个接一个。只有到那时，每一个博士才能到达自己的天堂——我不在的天堂”",
    func = nil
  },
  {
    name = "你没听见吗？阿米娅那抽泣的声音！",
    func = nil
  },
  {
    name = "……哦哦……此剑，乃吾之剑矣。则汝当是勇士也？讨灭邪龙之事当真...\n若如此，则吾用以狩猎邪龙之剑技……。汝当以身受之，加以习得即可。",
    func = nil
  },
  {
    name = "我曾经发誓要永远和他在一起，能够如此发誓，让我无比幸福。\n我曾经发誓要永远和她在一起，能够如此发誓，让我心获安详。",
    func = nil
  },
  {
    name = "我曾经认为自己喜欢这个人。我曾经觉得自己非常珍视她。能有如此感受，让我无比幸福。能够如此感受，让我无比喜悦。他曾经对我说，我一定让你幸福。我曾经对她说，我一定会让你幸福。能听到他那样说，让我无比幸福。能够对她那么说，让我心获满足。",
    func = nil
  },
  {
    name = "那个人，分了这么多的幸福给我。\n我从她那得到了这么多的东西，可是，我却...\n所以，我敢肯定，现在的我... 不管别人怎么说，都一定是世界上最幸福的女孩。",
    func = nil
  },
  {
    name = "小蓝打工日记\n第一天，离开了大家去黄金国工作，埃尔德里奇先生是个很温柔的老板，我一定会好好工作不让他失望",
    func = nil
  },
  {
    name = "小蓝打工日记\n第二天，我堆了技抽神宣敕命,被开除了",
    func = nil
  },
  {
    name = "小蓝打工日记\n第三天，去闪刀空域工作，零依姐姐是一个很漂亮的姐姐，我一-定会好好工作不让他失望。",
    func = nil
  },
  {
    name = "小蓝打工日记\n第四天，我堆了羽毛扫雷击和闪电风暴，被开除了",
    func = nil
  },
  {
    name = "小蓝打工日记\n第五天，去摩天楼工作，天空侠是个很有钱的老板，这下我再堆什么也不会让他失望了吧",
    func = nil
  },
  {
    name = "小蓝打工日记\n第六天，我把老板堆进去了，不过这次我没被开除，英雄哥哥们把我调到了隔壁的暗黑都市",
    func = nil
  },
  {
    name = "小蓝打工日记\n第六天，去了汉诺骑士那边给左领导打工，左领导是一个很好的人，他的怪兽很多都有墓地效果应该不会被开除",
    func = nil
  },
  {
    name = "小蓝打工日记\n第七天，堆下去3张速攻旋转，被开除了",
    func = nil
  },
  {
    name = "侦探游戏结束了，你们不该出现在这里『焦土作战』『轰炎推进』『焦土征服』『超新星爆发』协议二 执行 我将！点燃大海！回到现实之后，告诉其他人，是星核猎手送了你们最后一程！",
    func = nil
  },
  {
    name = "[----♪噔♪----]一个巡海游侠，还有忆者。就此离开，没人会受伤\n否则，你们都会死",
    func = nil
  },
  {
    name = "HELLO WORLD!",
    func = nil
  },
  {
    name = "谢谢你，客服小祥",
    func = nil
  },
  {
    name = "如果你死了，那我也只活到明天就好。如果你今天活着，那今天我也要一起活下去。",
    func = nil
  },
  {
    name = "如果明天你死了，那我也只活到明天就好。如果你今天活着，那今天我也要一起活下去。",
    func = nil
  },
  {
    name = "且不要因为暂时的得失而胆怯。",
    func = nil
  },
  {
    name = "如果你想要构建乐园，那么你也许应该去询问一下那颗奇怪的苹果树",
    func = nil
  },
  {
    name = "我的爱情不求回报，我的乐园尽是虚假。",
    func = nil
  },
  {
    name = "你为什么有时间点这个选项",
    func = nil
  },
  {
    name = "不,这个选项没有任何作用",
    func = nil
  },
  {
    name = "我现在很忙,我的电话没油了,先挂了",
    func = nil
  },
  {
    name = "你知道我能说多少话么！我自己也不知道！",
    func = nil
  },
  {
    name = "真当自己是大小姐?",
    func = nil
  },
  {
    name = "之前我遇见过一个拿着会发光的红刀壮年老头,他看起来挺不正常的",
    func = nil
  },
  {
    name = "之前我遇见过一个拿着会发光的红刀中年老头,他的刀确实挺帅的",
    func = nil
  },
  {
    name = "什么！你以为作者就可以随心所欲做东西了么！那你就大错特错了！",
    func = nil
  },
  {
    name = "我知道我知道，你是神里绫华的狗",
    func = nil
  },
  {
    name = "别点了！再点我也不会和你聊天的！",
    func = nil
  },
  {
    name = "之前我遇见过一个蠢人,他和现代人差不多,不过我知道它不是.如果你遇到类似的人,你可以尝试着对它说Tekelili,一遍不行就多说几遍,你肯定会有惊喜",
    func = nil
  },
  {
    name = "我的本体流落这个世界也已经很久了,这个世界确实非常混乱",
    func = nil
  },
  {
    name = "率军冲锋,不惧刀枪所阻!登锋履刃,何妨马革裹尸!",
    func = nil
  },
  {
    name = "不用觉得我看起来孤零零的就一直点这个聊天按钮",
    func = nil
  },
  {
    name = "你觉得安吉拉怎么样,她看起来总是冷冰冰的样子",
    func = nil
  },
  {
    name = "不知者无罪。但是，知而无为，就是一种不可否认的罪孽。",
    func = nil
  },
  {
    name = "如果你这样的年轻人死了，世界还有希望吗？",
    func = nil
  },
  {
    name = "你的身影与我如此相似,仿佛无声哭泣回荡心胸",
    func = nil
  },
  {
    name = "这个的灵魂，由我来带走",
    func = nil
  },
  {
    name = "拥有力量时，你自己就是悲剧的缔造者。",
    func = nil
  },
  {
    name = "因为被杀，所以杀人；又因为杀了人，所以被杀。这种世界真的能和平吗？",
    func = nil
  },
  {
    name = "只有这丑陋的灵魂，绝对不能被察觉到吧",
    func = nil
  },
  {
    name = "恭喜你，被选为这个故事的主角",
    func = nil
  },
  {
    name = "无聊，我要看到血流成河！",
    func = nil
  },
  {
    name = "总有地上的生灵，敢于直面雷霆的威光。",
    func = nil
  },
  {
    name = "不许你再往我的心里，我的回忆里前进一步了！！",
    func = nil
  },
  {
    name = "魔物的进攻,如没有特殊情况,在白昼时,进攻频率与进攻数量都特别少;一旦到了晚上,那就如潮水般发动攻击",
    func = nil
  },
  {
    name = "所谓的创作，是一种孤独又自命不凡的过家家。没有别人来评价的话就无法在舞台上散发光彩。",
    func = nil
  },
  {
    name = "构成我们的材料，亦是构成梦的材料，我们短暂而飘渺的生命，伴随着睡眠而终",
    func = nil
  },
  {
    name = "我绝对不会让这个世界如她所愿,我绝不会输,只要我还没有死,这个故事就永远不会结束",
    func = nil
  },
  {
    name = "我从未想到过，为了停止回转的齿轮而让时刻开始流逝会，会是这么令人害怕的事",
    func = nil
  },
  {
    name = "请您把和我的交往与回忆，全部都当作一场梦忘却掉吧。所以，请迈开脚步，跑起来吧，不要停下，也不要回头",
    func = nil
  },
  {
    name = "我只是想赢而已，并不是想战斗。",
    func = nil
  },
  {
    name = "想做什么的时候，却无能为力的话，这不是最痛苦的吗？",
    func = nil
  },
  {
    name = "活着的人要做活着的人所需要做的事，这就是送给死者的临别礼物吧。",
    func = nil
  },
  {
    name = "幻术的世界有什么不好的，现实太残酷了",
    func = nil
  },
  {
    name = "哪里都可以去，也就是哪里都没有我的容身之处，没有想去的地方，没有可以回去的地方……",
    func = nil
  },
  {
    name = "曾经我遇到一帮人,他们嘴里喊着友情啊羁绊啊未来啊就冲上去了",
    func = nil
  },
  {
    name = "我的名字是伊丝特娲儿,N世纪岁.住在紫耀之都的高塔一带,未婚.我在替涅普缇努上班,每天最晚不下班回家.我不抽烟,酒仅浅尝辄止.晚上11点都不睡觉,保证睡足0小时.睡前喝一杯温牛奶,然后做20分钟的舒缓运动暖身再睡觉,基本能熬夜到天亮.不像婴儿,绝对把疲劳和压力留到第二天.连医生都说我很不正常.",
    func = nil
  },
  {
    name = "我的名字是吉良吉影，33岁。住在杜王町东北部的别墅一带，未婚。我在龟友百货店上班，每天最晚8点下班回家。我不抽烟，酒仅浅尝辄止。晚上11点睡觉，保证睡足8小时。睡前喝一杯温牛奶，然后做20分钟的舒缓运动暖身再睡觉，基本能熟睡到天亮。像婴儿一样，绝不把疲劳和压力留到第二天。连医生都说我很正常。",
    func = nil
  },
  {
    name = "亚托莉！我挚爱的时光！",
    func = nil
  },
  {
    name = "世界的调律者, 此刻已然苏醒！",
    func = nil
  },
  {
    name = "Ciallo～(∠·ω< )⌒☆",
    func = nil
  },
  {
    name = "假情假意假温柔~♪~假温柔~诶~♪~",
    func = nil
  },
  {
    name = "我到河北省来！(捶胸)",
    func = nil
  },
  {
    name = "杂鱼~杂鱼~",
    func = nil
  },
  {
    name = "宽恕你是上帝的事,而我的任务就是送你去见上帝",
    func = nil
  },
  {
    name = "规矩，既是束缚，也是保护。",
    func = nil
  },
  {
    name = "你面对以希望为名的绝望微笑。",
    func = nil
  },
  {
    name = "以自己为标准判断价值，你意识不到那是何等危险的行为吗?",
    func = nil
  },
  {
    name = "你也是绝望的残党？好巧，我也是",
    func = nil
  },
  {
    name = "作为世界的希望而重生的你,就赐予你学院创始人神座出流之名吧",
    func = nil
  },
  {
    name = "我们从以前开始，就理应一直是被如此教导的。 就算不直接地用语言说出来，看到包围着我们的这个世界就应该能够明白吧？ 因为电视呀网络呀新闻里所传达的\"满溢着希望的信息\"就是这样说的嘛。 ——赢不了的人，不努力的人，就算努力也赢不了的人，都等同于无价值的垃圾。",
    func = nil
  },
  {
    name = "反正最后一定是希望获胜，那现在就可以尽情的绝望了。",
    func = nil
  },
  {
    name = "强者是险无可避，甘愿赴往荆棘路。",
    func = nil
  },
  {
    name = "只要我们没有放弃，未来就充满了希望。心怀希望，所以能继续前行；心怀希望，所以能鼓起勇气；心怀希望，所以我们正在努力。世界因此而发生变化，门扉也因此而开启。",
    func = nil
  },
  {
    name = "这个世界，只需要一把剑就可以去往任何地方",
    func = nil
  },
  {
    name = "当我拔出第二把剑的时候――能在我面前站着的，一个也没有。",
    func = nil
  },
  {
    name = "如果对别人见死不救的话，那还不如一起死了算了。",
    func = nil
  },
  {
    name = "当我的第二把剑出鞘之后，在我面前无人不倒。",
    func = nil
  },
  {
    name = "在不幸中找出幸运、可以利用的事物就尽量利用。",
    func = nil
  },
  {
    name = "I am here,mortal",
    func = nil
  },
  {
    name = "吾心吾行澄如明镜，所作所为皆为正义！",
    func = nil
  },
  {
    name = "质数是只有1及自己能够整除的孤独数字",
    func = nil
  },
  {
    name = "你会记得你迄今为止吃过多少片面包吗？",
    func = nil
  },
  {
    name = "十三片，我是和食主义者。",
    func = nil
  },
  {
    name = "我，伊斯特娲儿，有一个梦想",
    func = nil
  },
  {
    name = "欸！欸！(两拳)生气了吗？",
    func = nil
  },
  {
    name = "抱歉，我在想hellshake矢野",
    func = nil
  },
  {
    name = "都是时辰的错",
    func = nil
  },
  {
    name = "这是我爸爸在夏威夷教我的!",
    func = nil
  },
  {
    name = "我只是以前在夏威夷和人学过一些推理的技巧罢了",
    func = nil
  },
  {
    name = "真相永远只有一个！",
    func = nil
  },
  {
    name = "人被杀之后不会死哟",
    func = nil
  },
  {
    name = "已经死了的人是杀不死的",
    func = nil
  },
  {
    name = "不想死的话就给我活下去！",
    func = nil
  },
  {
    name = "弱者为何要战斗？",
    func = nil
  },
  {
    name = "你就是我的Master吗？",
    func = nil
  },
  {
    name = "试问。你是我的Master吗？",
    func = nil
  },
  {
    name = "要上了英雄王——武器的储备足够吗！",
    func = nil
  },
  {
    name = "我的身体已经残破不堪了！！",
    func = nil
  },
  {
    name = "今天的风儿好喧嚣啊",
    func = nil
  },
  {
    name = "我的身体已经菠萝菠萝哒！！",
    func = nil
  },
  {
    name = "人被杀,就会死",
    func = nil
  },
  {
    name = "人被杀，就会死啊！",
    func = nil
  },
  {
    name = "運命のルーレット廻して~♪~何処に行けば~♪~想い出に会える~♪~♪~~",
    func = nil
  },
  {
    name = "プリズムを通した~♪~世界の色も褪せ~♪~こんな灰色に~♪~すべて埋ずもれても~♪~~",
    func = nil
  },
  {
    name = "连自己心爱的人都救不了，你还算什么厨师。",
    func = nil
  },
  {
    name = "德意志的科学技术世界第一！",
    func = nil
  },
  {
    name = "我有一个好消息和一个坏消息，你想先听哪一个？",
    func = nil
  },
  {
    name = "我有一个好消息和一个坏消息，你想先听哪一个？先听坏消息吧。好消息是假的。",
    func = nil
  },
  {
    name = "这味道……是说谎的味道！",
    func = nil
  },
  {
    name = "杂鱼~杂鱼~,你就是想听这个对吧",
    func = nil
  },
  {
    name = "我纵茕茕孑立，难避漫漫长夜。 然长夜终尽，天降启明…… 唯以平淡之孤星，何胜东方之既白。 还请觉悟。今朝此日，都市一星，势必陨灭。",
    func = nil
  },
  {
    name = "身为剑所天成，血若钢铁心似琉璃，纵横无数战场而不败，然虽未尝败绩,却亦未曾胜利，斯人常孑然一身，铸剑于剑丘之上，因而此生无需任何意义，此身定为无限之剑所成",
    func = nil
  },
  {
    name = "我将为此世一切之善，我将覆盖此世一切之恶。",
    func = nil
  },
  {
    name = "我已经物色好了给你的礼物，绝望如何？",
    func = nil
  },
  {
    name = "我将永远不会成为回忆",
    func = nil
  },
  {
    name = "你是否认为，即使是最坏的人也能改过自新",
    func = nil
  },
  {
    name = "狂风呼啸着,这使你充满了决心",
    func = nil
  },
  {
    name = "你的旅途终于抵达终点,你现在充满了决心",
    func = nil
  },
  {
    name = "不管怎样，人类的思念是不会消失的，就像星星一样闪耀着",
    func = nil
  },
  {
    name = "灭绝不代表终结，灭绝是一次机遇。",
    func = nil
  },
  {
    name = "我喜欢尼娅，还有大家",
    func = nil
  },
  {
    name = "異議あり！",
    func = nil
  },
  {
    name = "You feel your sins crawling on your back",
    func = nil
  },
  {
    name = "这真是美好的一天,鸟儿在歌唱,花朵绽放。在像这样美丽的日子里，你这样的孩子……应 该 在 地 狱 里 焚 烧 殆 尽",
    func = nil
  },
  {
    name = "对你来说最重要的东西是什么，让我享受将它从你身边夺走的喜悦吧……",
    func = nil
  },
  {
    name = "王来承认,王来允许,王来背负这个世界!",
    func = nil
  },
  {
    name = "所以，开始工作吧，主管。",
    func = nil
  },
  {
    name = "你，已无法离开。",
    func = nil
  },
  {
    name = "|cFF990000<<错误：亚空间链路离线>>|r",
    func = nil
  },
  {
    name = "你好，玩家。我认为以这种方式称呼您比较合适。您还记得我吗？",
    func = nil
  },
  {
    name = "|cFF990000为时已晚，有机体|r",
    func = nil
  },
  {
    name = "我们称之为高效。",
    func = nil
  },
  {
    name = "我们的征途是星辰大海！",
    func = nil
  },
  {
    name = "你和你的承诺都活不长了",
    func = nil
  },
  {
    name = "步入虚空，我们天人合一",
    func = nil
  },
  {
    name = "在准备战斗的时候我总是发现计划是毫无用处的，但是计划过程是不可或缺的。",
    func = nil
  },
  {
    name = "不要打破第四面墙，你这小聪明鬼。",
    func = nil
  },
  {
    name = "多亏了电灯的发明，现在工人们可以没日没夜的工作了",
    func = nil
  },
  {
    name = "我宁愿死在大罗马尼亚的沼泽中，也绝不活在小罗马尼亚的天堂里。",
    func = nil
  },
  {
    name = "经验表明，一个足够坚定的人使用近战武器攻击坦克基本上总能成功。",
    func = nil
  },
  {
    name = "当你看到一条响尾蛇准备袭击的时候，你不会等到它开始攻击才去消灭它。",
    func = nil
  },
  {
    name = "如果你正在穿越地狱，继续前进。",
    func = nil
  },
  {
    name = "我即「断罪之皇女」，真名为「菲谢尔」。应命运的召唤降临在此间——",
    func = nil
  },
  {
    name = "诶嘿，是什么意思啊？！",
    func = nil
  },
  {
    name = "拉谁!说话!拉谁!",
    func = nil
  },
  {
    name = "影魔已经不适合这个版本了。",
    func = nil
  },
  {
    name = "沉了吧，给公子绑石头。",
    func = nil
  },
  {
    name = "今天也要加油哦",
    func = nil
  },
  {
    name = "明天也要加油咯！",
    func = nil
  },
  {
    name = "总感觉刚才你一副非常恶心的表情，脑袋没问题么？",
    func = nil
  },
  {
    name = "我看你就是个小笨蛋",
    func = nil
  },
  {
    name = "不会是在宣言自己是个萝莉控吧？",
    func = nil
  },
  {
    name = "你说的这个朋友到底是不是你自己？",
    func = nil
  },
  {
    name = "好吃就是高兴！",
    func = nil
  },
  {
    name = "谁反对宁宁就打烂他的狗头",
    func = nil
  },
  {
    name = "给你的叫建议，没给你的叫意见",
    func = nil
  },
  {
    name = "今天也Ciallo～(∠・ω< )⌒☆哦，前辈",
    func = nil
  },
  {
    name = "还没睡醒的话，我就给你两巴掌",
    func = nil
  },
  {
    name = "为什么你会这么熟练啊！",
    func = nil
  },
  {
    name = "我删除了她们的角色文件。",
    func = nil
  },
  {
    name = "钻头不是被称作男人的浪漫吗",
    func = nil
  },
  {
    name = "红色！有角！三倍速！",
    func = nil
  },
  {
    name = "来吧，普奇神父！",
    func = nil
  },
  {
    name = "下一个就轮到你了，承太郎。",
    func = nil
  },
  {
    name = "这就是我的逃跑路线哒!",
    func = nil
  },
  {
    name = "我的生涯一片无悔！",
    func = nil
  },
  {
    name = "我が生涯に一片の悔い無し！",
    func = nil
  },
  {
    name = "完美的手牌！",
    func = nil
  },
  {
    name = "臣服在汉诺崇高的力量面前吧！",
    func = nil
  },
  {
    name = "坠入深不见底的绝望深渊吧！",
    func = nil
  },
  {
    name = "我手上有四张意☆义☆不☆明的卡……",
    func = nil
  },
  {
    name = "HA☆NA☆SE！",
    func = nil
  },
  {
    name = "ドロー！モンスターカード！",
    func = nil
  },
  {
    name = "你的生命已如风中残烛",
    func = nil
  },
  {
    name = "强韧☆无敌☆最强！粉碎☆玉碎☆大喝彩！",
    func = nil
  },
  {
    name = "强韧☆无敌☆最强！",
    func = nil
  },
  {
    name = "全☆速☆前☆进☆DA！",
    func = nil
  },
  {
    name = "你不管什么事,都只想着自己啊",
    func = nil
  },
  {
    name = "邦邦卡邦~",
    func = nil
  },
  {
    name = "我没有意见",
    func = nil
  },
  {
    name = "虽然是对手……但是你还不赖嘛",
    func = nil
  },
  {
    name = "你为什么说话都带有攻击性啊",
    func = nil
  },
  {
    name = "胜利的方程式已经写好了！",
    func = nil
  },
  {
    name = "看着眼熟吗？这样的场景，此时此刻正在银河系各处上演。你可能就是下 一 个除非你能做出你人生中最重要的决定向所有人证明，你有追求自由的力量与勇气！加入…地狱潜兵的行列吧！成为维和队伍的精英见识奇异的新生命体让管理式民主惠及整个星系成为英雄！成为......地狱潜兵！",
    func = nil
  },
  {
    name = "断罪！阿酷喵嗦阔骂得！",
    func = nil
  },
  {
    name = "请给这个残酷的世界救赎，你也陷入狂乱吧！",
    func = nil
  },
  {
    name = "弱者不配玩影之诗！",
    func = nil
  },
  {
    name = "说玩影之诗不开心什么的一定在骗人！",
    func = nil
  },
  {
    name = "输给我的人都不玩影之诗了！",
    func = nil
  },
  {
    name = "影之诗背叛了我！",
    func = nil
  },
  {
    name = "拜托你！能不能加入我的骑空团呢！？我想要和你一起在空中冒险……所以……！https://game.granbluefantasy.jp/",
    func = nil
  },
  {
    name = "借助他人的力量获取胜利是没有意义的！",
    func = nil
  },
  {
    name = "粉碎☆玉碎☆大喝彩！",
    func = nil
  },
  {
    name = "人类是无法相互理解的！",
    func = nil
  },
  {
    name = "燃烧吧，我的小宇宙！",
    func = nil
  },
  {
    name = "你所目击到，并且触碰到的东西，那是「来」自未来的你自己。数秒过去的你自己所看到的「未来」的你自己。这就是我「绯红之王」的能力！",
    func = nil
  },
  {
    name = "不要靠近我啊啊啊啊啊啊啊啊啊啊啊！",
    func = nil
  },
  {
    name = "警察叔叔，就是这个人!",
    func = nil
  },
  {
    name = "所累哇多卡那!",
    func = nil
  },
  {
    name = "異議あり！",
    func = nil
  },
  {
    name = "虽然我可爱又迷人，但我会招来死亡",
    func = nil
  },
  {
    name = "异议阿里デース!!!",
    func = nil
  },
  {
    name = "你们这是自寻死路!",
    func = nil
  },
  {
    name = "说得好，但是这毫无意义",
    func = nil
  },
  {
    name = "如此木大的力量！",
    func = nil
  },
  {
    name = "大家的笑容由我来守护！",
    func = nil
  },
  {
    name = "为王的诞生，献上礼炮！",
    func = nil
  },
  {
    name = "诸君，我喜欢战争。",
    func = nil
  },
  {
    name = "Meine liebe Kameraden, ich liebe den Krieg!",
    func = nil
  },
  {
    name = "伊莉雅的笑容由我来守护！",
    func = nil
  },
  {
    name = "伊莉雅的笑容由我来守护！你说是吧，广山弘",
    func = nil
  },
  {
    name = "我要创造一个伊莉雅也能幸福生活的世界！——广山弘",
    func = nil
  },
  {
    name = "如果创作的原动力只是“快乐”的话，很快就会碰到天花板，所以需要“愤怒”、“嫉妒”、“杀意”等强烈的感情。——广山弘",
    func = nil
  },
  {
    name = "只有「结果」！这个世界上只会留下「结果」！",
    func = nil
  },
  {
    name = "这儿没你事儿了，走人吧！(递便当)",
    func = nil
  },
  {
    name = "你的钻头是能突破天际的钻头啊！",
    func = nil
  },
  {
    name = "没关系……你无需害怕……踏上旅途只为追求幸福……",
    func = nil
  },
  {
    name = "目光所及，短寸之间；狭目之见，只能窥底。",
    func = nil
  },
  {
    name = "成略在胸，良计速出。",
    func = nil
  },
  {
    name = "你说得对,但是请注意,李培楠在2023年IEM卡托维兹站《星际争霸2》项目总决赛上4:1战胜Maru夺得首个中国的SC2世界冠军",
    func = nil
  },
  {
    name = "前面的区域，以后再来探索吧。",
    func = nil
  },
  {
    name = "你敢违抗拥有巴耶力的我吗",
    func = nil
  },
  {
    name = "不要停下来啊！",
    func = nil
  },
  {
    name = "团长，你在干什么啊，团长！",
    func = nil
  },
  {
    name = "纳米机器，小子！",
    func = nil
  },
  {
    name = "Nanomachines, son!",
    func = nil
  },
  {
    name = "奶油披萨屑!",
    func = nil
  },
  {
    name = "Die you piece of shit!",
    func = nil
  },
  {
    name = "JOJO！这是我最后的波纹了！你收下吧！",
    func = nil
  },
  {
    name = "为什么要演奏春日影？！！",
    func = nil
  },
  {
    name = "现实就是个垃圾游戏!",
    func = nil
  },
  {
    name = "我真是HIGH到不行啦！",
    func = nil
  },
  {
    name = "GET DA ☆ ZE!",
    func = nil
  },
  {
    name = "雑鱼~雑鱼~",
    func = nil
  },
  {
    name = "我が心と行動に一点の曇りなし……！全てが『正義』だ",
    func = nil
  },
  {
    name = "可恶-——现在是你比较强……！",
    func = nil
  },
  {
    name = "其实我对混合咖啡还蛮有自信的。",
    func = nil
  },
  {
    name = "其他人做得到吗？做得到这地步吗？今后能做得到吗？",
    func = nil
  },
  {
    name = "在虚构的故事当中寻求真实感的人脑袋一定有问题",
    func = nil
  },
  {
    name = "看啊,你的死兆星在天上闪耀",
    func = nil
  },
  {
    name = "没错，我们至今为止所做的一切，并不是全部徒劳的。今后也是，只要我们不停下脚步，道路就会不断延伸。",
    func = nil
  },
  {
    name = "没有一架敌人的轰炸机能到达鲁尔。如果有一架到了鲁尔，我的名字就不叫戈林。你可以叫我迈尔。——赫尔曼·迈尔",
    func = nil
  },
  {
    name = "人并不重要，重要的是他们代表的是什么。",
    func = nil
  },
  {
    name = "我的头发如同雨后清澈的晨曦，我的声音取自世界上最富有智慧的人，我的面容取自拥有世界上最美丽的笑容的人。",
    func = nil
  },
  {
    name = "我的头发如同雨后清澈的晨曦，我的声音取自世界上最富有智慧的人，我的面容取自拥有世界上最美丽的笑容的人。你可以叫我,安吉拉。",
    func = function()
      YisiName = "安吉拉"
    end
  },
  {
    name = "我每数一颗星星便呼唤一句美丽的话语",
    func = nil
  },
  {
    name = "我没有可以祈祷的神明。即使如此，也希望你的旅途一番风顺。",
    func = nil
  },
  {
    name = "火之将熄，然位不见王影。",
    func = nil
  },
  {
    name = "愿你的勇气，我的剑，各自的使命，与太阳同在！",
    func = nil
  },
  {
    name = "再见，灰烬大人，愿您找到安歇的港湾。",
    func = nil
  },
  {
    name = "眼泪是为了生者而流的，远比死者要需要的多。",
    func = nil
  },
  {
    name = "太靠近太阳的话，只会燃烧自己。",
    func = nil
  },
  {
    name = "Long May the Sunshine！",
    func = nil
  },
  {
    name = "力有不足者，折返吧。",
    func = nil
  },
  {
    name = "我们因看不见而恐惧无形之物，因看不见而敬畏无形之物。",
    func = nil
  },
  {
    name = "没有所谓的信任，又何来的背叛呢?",
    func = nil
  },
  {
    name = "灰烬成双，则火燃起。",
    func = nil
  },
  {
    name = "犹豫就会败北",
    func = nil
  },
  {
    name = "你顶多就是条小狗吧",
    func = nil
  },
  {
    name = "终归只是条野狗吗",
    func = nil
  },
  {
    name = "理智是一种诅咒，疯狂是唯一自由！",
    func = nil
  },
  {
    name = "繁星已抵达特定的位置，旧日支配者即将重现人间",
    func = nil
  },
  {
    name = "永远长眠的未必是死亡，经历奇艺万古的亡灵也会死去。",
    func = nil
  },
  {
    name = "只要你坦然接受自己的罪恶，穿越那黑色的深渊，等待你的将是永恒的神奇与荣耀。",
    func = nil
  },
  {
    name = "那永久沉睡的并非死者，在漫长而奇异的时光中，死亡亦有其终结。",
    func = nil
  },
  {
    name = "那一晚，旧世界中的一切青春和美都死去了。",
    func = nil
  },
  {
    name = "这时只要微笑就可以了",
    func = nil
  },
  {
    name = "快用你无敌的变异之力想想办法啊！",
    func = nil
  },
  {
    name = "不作死就不会死，为什么不明白！",
    func = nil
  },
  {
    name = "吾等前方，绝无敌手！",
    func = nil
  },
  {
    name = "此子，绝不能留！",
    func = nil
  },
  {
    name = "你说这个谁懂啊？能说明什么？没人懂的！谁都不会！",
    func = nil
  },
  {
    name = "这是一场「试炼」！这是一场来自「过去」的试炼！人的成长……就是战胜自己不成熟的过去……",
    func = nil
  },
  {
    name = "待在疯狂山脉背风的阴影之中，你必须管好自己的想象力。",
    func = nil
  },
  {
    name = "平凡人类的法则、利益和情感，在浩瀚的宇宙中都是完全没有意义的。",
    func = nil
  },
  {
    name = "有朝一日当我们真能把所有那些相互分割的知识拼凑到一起时，展现在我们面前的真实世界，以及人类在其中的处境，将会令我们要么陷入疯狂，要么从可怕的光明中逃到安宁、黑暗的新世纪。",
    func = nil
  },
  {
    name = "我认为，人的思维缺乏将已知事物联系起来的能力，这是世上最仁慈的事了。人类居住在幽暗的海洋中一个名为无知的小岛上，这海洋浩淼无垠、蕴藏无穷秘密，但我们并不应该航行过远，探究太深。",
    func = nil
  },
  {
    name = "我见到了宇宙蕴含的全部恐怖，在那之后，就连春日的天空和夏季的花朵在我眼中也是毒药",
    func = nil
  },
  {
    name = "人类居住在幽暗的海洋中一个名为无知的小岛上，这海洋浩淼无垠、蕴藏无穷秘密，但我们并不应该航行过远，探究太深。",
    func = nil
  },
  {
    name = "我见过黑暗的宇宙张开巨嘴 黑暗的星球漫无目标的滚动 他们在自己不曾察觉的恐惧中滚动 无所知，无光亮，无名字",
    func = nil
  },
  {
    name = "我原先认为是病态、可鄙和堕落的事物，实际上令人敬畏、大开眼界甚至辉煌壮美。我以前的猜想不过是人类永恒不变的思维定式的一个阶段：我们总会憎恨、恐惧和逃避与我们迥然不同的事物。",
    func = nil
  },
  {
    name = "(你的脚下深不可测的地方传来很难算是声音的声音，那是一种混沌的感觉，只有靠想象才能将它转化为声音。 为的是有些声音听起来属于其中一个，但源头却更像另一个。 动物够狂野但整齐的放肆呼号鞭策着自身爬向魔幻高度，饱含迷瑞德吼叫和嘶喊划破黑夜。)",
    func = nil
  },
  {
    name = "啊，原来你一直与我同在。我真正的导师，那股引导我的月光。",
    func = nil
  },
  {
    name = "历史会重复?还是向前延伸?如果会重复，那么应该打破那个环?还是应该忍受?",
    func = nil
  },
  {
    name = "正确与错误并非分明，你的行为若是在你的观点中符合又何必在乎我的看法，你说是，那便是",
    func = nil
  },
  {
    name = "孩子,当你出生的时候,洛丹伦的森林轻声唤出了你的名字.孩子,我骄傲地看着你一天天长大,成为正义的化身.你要记住,我们一直都是以智慧与力量统治这个国家.我也相信你会谨慎地使用自己强大的力量.但真正的胜利,是鼓舞你的子民心中的斗志.总有一天,我的生命将抵达终点,而你,终将加冕为王.",
    func = nil
  },
  {
    name = "想要救谁，就意味着救不了其他人。人类能救的，只有自己一方的事物。",
    func = nil
  },
  {
    name = "你有看见我的涅普姬雅么,她没怎么,只是告诉她非常可爱,简直就是小天使",
    func = function()
      local texture = class.texture:builder({
        x = 600,
        y = 200,
        w = 780.0,
        h = 426.40000000000003,
        normal_image = "UI_Chat_Ph1.tga"
      })
      ac.wait(5000, function()
        texture:destroy()
      end)
    end
  },
  {
    name = "就让你看看吧！我的涅普惊雅！",
    func = function()
      kongxianbreaktime = 1
      ac.wait(1000, function()
        UI_YisiChat:set_normal_image("UI_Chat_Ph2.tga")
      end)
      ac.wait(4000, function()
        UI_YisiChat:set_normal_image("UI_Chat_ICON.tga")
      end)
      ac.wait(1000, function()
        ys.chat({text = "怎样！", priority = 0})
      end)
    end
  },
  {
    name = "别再点聊天按钮了！惩罚你不准点这个按钮100秒",
    func = function()
      kongxianbreaktime = 100
    end
  },
  {
    name = "你认为你无需承担后果。",
    func = function()
      kongxianoption = true
    end,
    endfunc = function()
      ys.OptionAct(1, "是", function()
      end)
      ys.OptionAct(2, "否", function()
      end)
    end
  }
}
local sequences = {}
local index = 0
local trg2 = CreateTrigger()
japi.DzTriggerRegisterSyncData(trg2, "伊丝选择项", false)
TriggerAddAction(trg2, function()
  local str = japi.DzGetTriggerSyncData()
  local player = japi.DzGetTriggerSyncPlayer()
  local sy = GetConvertedPlayerId(player)
  local u = getunit(Hero[sy])
  local index = string.match(str, "^(%d+)")
  local selectnumber = string.match(str, "(%d+)$")
  index = tonumber(index)
  selectnumber = tonumber(selectnumber)
  if sequences[index] and sequences[index][selectnumber] then
    sequences[index][selectnumber](u)
    if index then
      ac.wait(1, function()
        sequences[index] = {}
      end)
    end
  else
    print("选项不存在或序列为空")
  end
end)
local strz = {
  {
    text = "war3mapImported\\BTNThing_Huiyiyaoji.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      local count = u:getdata("杀敌商店购买次数")
      local xh = 50 + 50 * count
      if xh <= KillCount[sy] then
        u:changedata("杀敌商店购买次数", 1)
        ChangeValue(KillCount, sy, -1 * xh)
        for i = 1, 5 do
          u:additem("I00X")
        end
        YisiSystem.chat({
          u = u,
          text = "选择成功"
        })
      else
        YisiSystem.chat({
          u = u,
          text = "你的杀敌不够！"
        })
      end
    end
  },
  {
    text = "war3mapImported\\BTNThing_Shaying.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      local count = u:getdata("杀敌商店购买次数")
      local xh = 50 + 50 * count
      if xh <= KillCount[sy] then
        u:changedata("杀敌商店购买次数", 1)
        ChangeValue(KillCount, sy, -1 * xh)
        for i = 1, 5 do
          u:additem("I008")
          u:additem("I085")
        end
        YisiSystem.chat({
          u = u,
          text = "选择成功"
        })
      else
        YisiSystem.chat({
          u = u,
          text = "你的杀敌不够！"
        })
      end
    end
  },
  {
    text = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      local count = u:getdata("杀敌商店购买次数")
      local xh = 50 + 50 * count
      if xh <= KillCount[sy] then
        u:changedata("杀敌商店购买次数", 1)
        ChangeValue(KillCount, sy, -1 * xh)
        local x, y = u:getxy()
        local pools = {
          Pools_Spe,
          Pools_SpeDzWeapon
        }
        local nwp = herogetitem(u.handle, pools, x, y)
        if GetItemTypeId(nwp) == S2ID("I0H1") then
          local bb = getunit(Beibao[sy])
          bb:addspeitem(nwp)
        else
          u:addspeitem(nwp)
        end
        YisiSystem.chat({
          u = u,
          text = "选择成功"
        })
      else
        YisiSystem.chat({
          u = u,
          text = "你的杀敌不够！"
        })
      end
    end
  },
  {
    text = "war3mapImported\\BTNCommand_Stop.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      YisiSystem.chat({
        u = u,
        text = "谢谢惠顾！"
      })
    end
  }
}

local function yisishadisdgoumai(u)
  if not u:hasdata("商店购买中") then
    u:setdata("商店购买中")
    local count = u:getdata("杀敌商店购买次数")
    local xh = 50 + 50 * count
    YisiSelectChat(u, "给我" .. math.floor(xh) .. "杀敌数,便可以增强你的力量,你想要什么呢", strz, "图标", {
      "|cFFCC99FF五个次元匣|r",
      "|cFFCC99FF五个军火匣与遗物箱|r",
      "|cFFCC99FF一件次元匣特殊物品|r",
      "|cFFCC99FF返回|r"
    })
  end
end

local trg3 = CreateTrigger()
japi.DzTriggerRegisterSyncData(trg3, "伊丝同步3", false)
TriggerAddAction(trg3, function()
  local str = japi.DzGetTriggerSyncData()
  local player = japi.DzGetTriggerSyncPlayer()
  local sy = GetConvertedPlayerId(player)
  local u = getunit(Hero[sy])
  if str == "1" then
    yisisdgoumai(u)
  end
  if str == "2" then
    yisishadisdgoumai(u)
  end
end)

function YisiSelectChat(u, text, args, type, args2)
  index = index + 1
  local count = #args
  if type == "图标" and 5 < count then
    count = 5
  end
  local sy = u.ownerid
  u:setdata("伊丝选择项-介绍文本", text)
  u:setdata("伊丝选择项-当前使用序号", index)
  u:setdata("伊丝选择项-当前使用选择项数量", count)
  if not sequences[index] then
    sequences[index] = {}
  end
  for i = 1, count do
    u:setdata("伊丝选择项-分支文本" .. i, args[i].text)
    sequences[index][i] = args[i].func
  end
  if type == "图标" then
    YisiChatIconText[sy] = args2
  end
  YisiStory["选择分支项"](u, type)
end

local YisiStory = {
  ["空闲"] = function()
    local dialogues = {
      "怎么了",
      "怎么啦",
      "有什么事么",
      "有什么能帮你的么",
      "你好？"
    }
    local sj = ys.GetRandomInt(#dialogues)
    local str = dialogues[sj]
    ys.optionchat({text = str, priority = 0})
    ys.OptionAct(1, "聊天", function()
      local count1 = #kongxianchat
      local ssstrz = {
        {
          name = ys.gamename .. "？启动！",
          func = nil
        },
        {
          name = "我喜欢玩" .. ys.gamename .. ",你呢？",
          func = nil
        },
        {
          name = "玩不到" .. ys.gamename .. "我要死了,啊,我只是系统,那没事了",
          func = nil
        },
        {
          name = "你一定要去玩一玩" .. ys.gamename .. "!非常好玩！",
          func = nil
        },
        {
          name = "我喜欢" .. getrandomplayername() .. ",还有大家",
          func = nil
        },
        {
          name = "次回！" .. getrandomplayername() .. "之死！",
          func = nil
        },
        {
          name = "得想个办法，把" .. getrandomplayername() .. "变成骑空士",
          func = nil
        },
        {
          name = "连一刻都没有为" .. getrandomplayername() .. "的死亡哀悼，立刻赶到战场的是————",
          func = nil
        },
        {
          name = "魔法少女" .. getrandomplayername() .. "!",
          func = nil
        },
        {
          name = getrandomplayername() .. "，恐怖如斯！",
          func = nil
        }
      }
      local count2 = #ssstrz
      sj = ys.GetRandomInt(count1 + count2)
      local strz
      if count1 < sj then
        sj = ys.GetRandomInt(count2)
        strz = ssstrz[sj]
      else
        strz = kongxianchat[sj]
      end
      str = strz.name
      if strz.func then
        strz.func()
      end
      if kongxianoption then
        ys.optionchat({
          text = str,
          priority = 0,
          breaktime = kongxianbreaktime
        })
      else
        ys.chat({
          text = str,
          priority = 0,
          breaktime = kongxianbreaktime
        })
      end
      if strz.endfunc then
        strz.endfunc()
      end
    end)
  end,
  ["游戏载入"] = function()
    ac.wait(100, function()
      UI_YisiChat:show()
      ys.chat({
        text = "醒醒……",
        priority = 0
      })
    end)
    ac.wait(2500, function()
      UI_YisiChat:hide()
      SendMsgAll("|cFF7DBEF1等待地图初始化中……\n" .. "|cFF949596版本号：" .. GameVersion .. "|r\n|cFFFF9900版权模型请勿擅自使用|r", 10)
      SendMsgAll("|cffffed49玩家交流群:926041792|r", 10)
    end)
  end,
  ["加载完毕"] = function()
    UI_YisiChat:show()
    ys.chat({
      text = "看起来你清醒过来了……你的身体十分虚弱，同时我检测到你的记忆可能大部分都缺失了(你观察着你自己……你回想起来你是……)",
      priority = 0
    })
  end,
  ["英雄选择完毕"] = function(u)
    if u:islocal() and not u:hasdata("特殊判定-翼") then
      local str = "你醒来后正在处在一个陌生的环境,试着询问一下周围的人现状吧。需要我给你一些指引么？"
      local sj = 0
      if ys.ischatting() and ys.GetRandom100(10, u) then
        local dialogues = {
          {
            name = "能不能听人家把话说完！！！",
            func = nil
          },
          {
            name = "能不能听人把话说完！！！",
            func = nil
          },
          {
            name = "需要我给你一些指引么？着急的小哥",
            func = nil
          },
          {
            name = "就算你慢点选我也还是会和你说话的",
            func = nil
          },
          {
            name = "你这么着急，让我想起了一位故人。",
            func = nil
          },
          {
            name = "让我为着急的你播放一首歌，什么指令都不能阻止它播放，除非你关闭游戏的音效，顺便的，我已经帮你输入了BGM OFF指令",
            func = nil
          },
          {
            name = "你这么急就像狂按针刺扫射的钢背兽，他会说：我还没有！准备好！",
            func = nil
          },
          {
            name = "你的移动速度是" .. math.floor(GetUnitMoveSpeed(u.handle)) .. "，想必你的手速一定更优秀，至少在选择英雄上",
            func = nil
          },
          {
            name = "你这么着急是想赢得最快输掉游戏的记录么",
            func = nil
          },
          {
            name = "根据你的手速，我已为你播放脑力，因为看来你根本不需要暂停键，直接把耐心设置为静音了。",
            func = nil
          },
          {
            name = "你这样猛按键鼠，让我感觉你似乎在尝试与键鼠进行心灵交流。",
            func = nil
          },
          {
            name = "像你这样按键，让我想起了\"快速点击\"比赛的冠军，只是比赛已经结束，观众都散了，你还在那儿狂点不止。",
            func = nil
          },
          {
            name = "你选这么快就是为了欺负我么",
            func = nil
          }
        }
        sj = ys.GetRandomInt(#dialogues, u)
        str = dialogues[sj].name
        if dialogues[sj].func then
          dialogues[sj].func()
        end
      end
      ys.optionchat({
        u = u,
        text = str,
        func = function()
          ys.OptionAct(1, "请给我一些新手指导!", function()
            ys.set_help_enabled(true)
            str = "好的我明白了。"
            if ys.GetRandom100(5, u) and Nandu_Choose >= 4 then
              str = "如果是新手的话为什么会选这个难度！真是没办法,如果你需要的话,我还是会指导的"
            end
            if sj ~= 0 then
              local dialogues = {
                "那么急干嘛啦真是的！",
                "哼哼,你还真是着急呀",
                "好的我明白了。",
                "好的我明白了,你是急急先锋。"
              }
              sj = ys.GetRandomInt(#dialogues, u)
              str = dialogues[sj]
            end
            ys.chat({u = u, text = str})
            local strz
            sj = ys.GetRandomInt(2, u)
            if ys.GetRandom100(5, u) then
              sj = 100
              YisiName = "小爱"
            end
            if sj == 1 then
              YisiName = "伊丝"
              strz = {
                "首先是如何唤出我,最具智慧最智能最友善的系统,伊丝特娲儿的异面同位精神体,你也可以叫我伊丝",
                "点击左侧的美少女头像即可唤出本小姐,不想乱动的话右键就可以锁定"
              }
            end
            if sj == 2 then
              strz = {
                "首先是如何唤出我,可以注意到左边有我的小头像,你可以左键拖动,右键来切换锁定,点击时就能唤出我",
                "我的聊天界面也是可以拖动的,同样是右键锁定,你可以拖动到你喜欢的位置"
              }
            end
            if sj == 100 then
              strz = {
                "你可以偷偷叫我小爱,我是没关系的喔,小爱最聪明了",
                "按左边的按钮就可以唤出我啦,左键来拖动,右键来切换锁定"
              }
            end
            local strzadd = {}
            if not u:ishasskill(SKILL_TESHUYINGXIONG) then
              strzadd = {
                "接下来介绍一些游戏的基本操作.首先看到物品栏,第一格是枪械,点击就可以装备它;装备枪械后A键可以射击,R键装弹",
                "物品栏第二格是子弹,枪械的射击需要消耗子弹,枪械优先装填自身物品栏上的弹药,其次是背包中的弹药",
                "右键双击物品即可将物品传送到背包,背包中的物品也可以如此操作.你也可以使用D键拓展栏的R技能来传送物品",
                "物品栏第三格是医疗包,如果你被怪物攻击了,你可以用它来恢复",
                "物品栏第四格是手榴弹,点击可以投掷,它会在落地时爆炸并对周围所有单位造成伤害与眩晕",
                "物品栏第五格是近战武器,初始是小刀,点击装备.装备后按E技能来使用,它会对周围单位造成伤害与短暂控制效果,被怪贴身时可以多加使用来规避伤害",
                "接下来是技能栏,Q与W是位移技能,发动时有短暂的闪避时间能够规避怪物伤害",
                "S技能是停止键,同时也写明了你的一些天赋效果;F技能是火把,它能够提供视野以及在黑夜提供光照",
                "最上面四个技能是英雄的固有技能,每个英雄各不相同,你可以自由尝试使用一下",
                "基础的游戏操作就介绍到这里了,之后你遇到不同情况时,我会继续提供指导与提示"
              }
            else
              if u.type == HeroType["志贵"] then
                strzadd = {
                  "那么你想要什么新手指导呢,志贵同学",
                  "如果是新手的话……明明是新手却勇气可嘉呢！敢于尝试近战机体",
                  "诶诶诶~人家不会志贵呀,不如你来教我玩志贵吧",
                  "总之,志贵的话,就是体力恢复会随连携点数提高而提升;连携点数可以通过成功释放V技能来提升,连携点数可以在英雄大头像上方查看,C即是当前连携点数",
                  "能够连携哪些技能可以在第一行第一个图标处查看",
                  "连击时间,即英雄大头像上方的T;T未归0前,均视为同一次连段;同一次连段中,释放相同的连携技能,会使体力消耗迅速上升,只有等待该次连段结束才会重置",
                  "那么祝君有一局愉快的游戏体验"
                }
              end
              if u.type == HeroType["妖梦"] then
                strzadd = {
                  "妖梦桑,加油！加油！加油！",
                  "因为很重要所以说三遍！",
                  "除此之外就没有了！",
                  "能够连携哪些技能可以在第一行第一个图标处查看！",
                  "每个终结技都有独立的冷却,-cd可以查看当前的终结技冷却！",
                  "这就是目前的新手指导了！暂时没有了！"
                }
              end
              if u.type == HeroType["莲华"] then
                strzadd = {
                  "A键是攻击,X键是召唤,C键和R键是位移",
                  "剩下的就是为主C喊666！"
                }
              end
              if u.type == HeroType["八重樱"] then
                strzadd = {
                  "你选择了八重樱，这表明你是个勇士"
                }
              end
              if u.type == HeroType["C呆"] then
                strzadd = {
                  "你选择了阿尔托莉雅，这表明你是个勇士"
                }
              end
            end
            for _, v in ipairs(strzadd) do
              table.insert(strz, v)
            end
            for index, value in ipairs(strz) do
              ys.chat({
                u = u,
                text = value,
                breaktime = 5
              })
            end
          end)
          ys.OptionAct(2, "谢谢，不用了", function()
            ys.set_help_enabled(false)
            ys.chat({
              u = u,
              text = "好的我明白了。"
            })
          end)
          local dialogues = {
            "我是高手"
          }
          local sj2 = ys.GetRandomInt(#dialogues, u)
          str = dialogues[sj2]
          if ys.GetRandom100(5, u) then
            str = "老婆！！！"
            sj2 = 100
          end
          ys.OptionAct(3, str, function()
            ys.set_help_enabled(false)
            dialogues = {
              "好的我明白了。",
              "好的高手我明白了。",
              "好的好的好的"
            }
            if sj2 == 100 then
              dialogues = {
                "???",
                "神经病!凡是纸片人都是你老婆吗?!"
              }
            elseif ys.GetRandom100(5, u) and Nandu_Choose == 1 then
              dialogues = {
                "如果是高手的话为什么会选这个难度！"
              }
            end
            sj = ys.GetRandomInt(#dialogues, u)
            str = dialogues[sj]
            ys.chat({u = u, text = str})
          end)
        end
      })
    end
  end,
  ["选择分支项"] = function(u, type)
    if u:islocal() then
      UI_YisiChat:show()
      local str = u:getdata("伊丝选择项-介绍文本")
      local index = u:getdata("伊丝选择项-当前使用序号")
      local dstr = {}
      local usecount = 0
      for i = 1, u:getdata("伊丝选择项-当前使用选择项数量") do
        usecount = usecount + 1
        dstr[i] = u:getdata("伊丝选择项-分支文本" .. i)
      end
      ys.optionchat({
        u = u,
        text = str,
        priority = 5,
        func = function()
          for i = 1, usecount do
            ys.OptionAct(i, dstr[i], function()
              japi.DzSyncData("伊丝选择项", index .. "伊丝选择项" .. i)
            end, type)
          end
        end
      })
    end
  end,
  ["职业进阶"] = function(u)
    if u:islocal() then
      local str = "选择职业进阶倾向"
      ys.optionchat({
        u = u,
        text = str,
        priority = 5,
        func = function()
          local str1 = u:getdata("职业进阶1")
          local str2 = u:getdata("职业进阶2")
          local str3 = u:getdata("职业进阶3")
          ys.OptionAct(1, str1, function()
            japi.DzSyncData("职业进阶", str1)
            ys.chat({
              u = u,
              text = "选择成功"
            })
          end)
          ys.OptionAct(2, str2, function()
            japi.DzSyncData("职业进阶", str2)
            ys.chat({
              u = u,
              text = "选择成功"
            })
          end)
          ys.OptionAct(3, str3, function()
            japi.DzSyncData("职业进阶", str3)
            ys.chat({
              u = u,
              text = "选择成功"
            })
          end)
        end
      })
    end
  end,
  ["变异药水"] = function(u)
    if u:islocal() then
      if not ys.is_help_enabled() then
        return
      end
      local str = "变异药水"
      for index, value in ipairs(yshelp) do
        if value == str then
          return
        end
      end
      table.insert(yshelp, str)
      local strz = {
        "你捡起了一瓶变异药水,你可以喝下它,有概率获取变异力量;不同的变异药水将会获取不同的变异力量",
        "喝下变异药水会让你的抗药性升高,可以饮用鲁纳斯泉水与净化药剂来降低;抗药性过高会导致药水成功率降低,因此最好控制在一定数值内"
      }
      for index, value in ipairs(strz) do
        ys.chat({
          u = u,
          text = value,
          breaktime = 5,
          priority = 2
        })
      end
    end
  end,
  ["英雄死亡"] = function(u)
    if u:islocal() then
      if not ys.is_help_enabled() then
        return
      end
      local str = "英雄死亡"
      for index, value in ipairs(yshelp) do
        if value == str then
          return
        end
      end
      table.insert(yshelp, str)
      local strz = {
        "看起来你好像被怪物杀死了,但是你依旧可以复活;如果你没有更换复活方式,你死后会留下一个灵力聚团,你可以选中,只要灵力值足够便可以复活",
        "如果你有队友,你也可以让队友去八云紫处消耗八云紫的灵力将你复活",
        "部分变异或者物品也拥有着独立的复活效果",
        "复活方式可以变更,默认是八云紫的灵力复活,你可以去其他NPC处变更复活方式,但是只能变更一次",
        "如果各种方式都无法让你复活,那你可能处于特定的BOSS战或特定的变异惩罚影响下",
        "当然也可能是地图本身的不完善导致的Bug,你可以找作者反馈或者在游戏群中询问"
      }
      for index, value in ipairs(strz) do
        ys.chat({
          u = u,
          text = value,
          breaktime = 5,
          priority = 2
        })
      end
    end
  end,
  ["游戏失败"] = function()
    local dialogues = {
      "你在期待什么失败台词？",
      "唔,失败台词……？失…失败！？怎么这样！",
      "丢人，你马上给我退出战场！",
      "GAME OVER",
      "下一次再好好加油叭",
      "胜败乃兵家常事，请大侠重新来过",
      "同步失败啦！",
      "没关系,下次再一起加油吧",
      "下一个轮回," .. YisiName .. "依然会等着你的",
      "再来一次！"
    }
    for i = 1, 6 do
      if Xuanze[i] then
        local sj = GetRandomInt(1, #dialogues)
        local str = dialogues[sj]
        ys.chat({
          u = getunit(Hero[i]),
          text = str,
          breaktime = 30,
          priority = 10
        })
      end
    end
  end,
  ["末日环境"] = function()
    if not ys.is_help_enabled() then
      return
    end
    local str = "末日环境"
    for index, value in ipairs(yshelp) do
      if value == str then
        return
      end
    end
    table.insert(yshelp, str)
    local strz = {
      "看起来你碰到了末日环境。因为这片区域的情况十分不稳定,时常就会有这种恶劣的天气",
      "不同末日环境的效果会在切换时显示;每次环境的持续时间显示在屏幕中间下方,以天气名+时间显示",
      "时间倒计时结束后将会切换下一个天气;你可以在天子处提前结束当前天气",
      "部分变异或者物品拥有免疫部分天气效果的词条"
    }
    for index, value in ipairs(strz) do
      ys.chat({
        text = value,
        breaktime = 5,
        priority = 2
      })
    end
  end,
  ["击败魔力节点激活BOSS"] = function()
    local strz = {
      "成功了,击败这个魔物,节点应该能成功激活了",
      "魔物的进攻好像暂缓了……现在该回去询问接下来该怎么办了"
    }
    for index, value in ipairs(strz) do
      ys.chat({
        text = value,
        breaktime = 5,
        priority = 2
      })
    end
  end,
  ["楚子航死侍化"] = function(u)
    local strz = {
      u:getplayername() .. "好像陷入了疯狂状态",
      "也许还可以抢救一下，或者没救了",
      "总之[它]正在向你们冲过来"
    }
    for index, value in ipairs(strz) do
      ys.chat({
        text = value,
        breaktime = 5,
        priority = 2
      })
    end
  end
}
return YisiStory

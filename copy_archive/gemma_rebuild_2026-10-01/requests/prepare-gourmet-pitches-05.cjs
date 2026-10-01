// 미식전 머리에 남은 독립 사건의 다른 생활·협력 문제를 모델에 제안받는다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const data=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/14-gourmet.json'),'utf8'));
const schema={type:'object',additionalProperties:false,required:['pitches'],properties:{pitches:{type:'array',minItems:8,maxItems:8,items:{type:'object',additionalProperties:false,required:['key','title','situation','canonConnection','whyDifferent','actions','uncertain'],properties:{key:{type:'string'},title:{type:'string'},situation:{type:'string'},canonConnection:{type:'string'},whyDifferent:{type:'string'},uncertain:{type:'array',items:{type:'string'}},actions:{type:'array',minItems:2,maxItems:4,items:{type:'object',additionalProperties:false,required:['action','result','rewardRole','remainingProblem'],properties:{action:{type:'string'},result:{type:'string'},rewardRole:{type:'string'},remainingProblem:{type:'string'}}}}}}}}};
const sources=[
 {source:'https://anime.priconne-redive.jp/story/ep_02.html',fact:'미식전이 물건배달을간유우키를찾아갔더니인기아이돌길드카르미나의츠무기가가게에서옷을입히고있었다. 사건전체결말이나스킬은여기서확인하지않았다.'},
 {source:'https://anime.priconne-redive.jp/story/ep_04.html',fact:'미식전이괴수섬에서카스미·마코토와만나며자경단이섀도출몰을조사하고있다. 카스미는조사역할에서만쓴다. 본편섀도진상·성공결말을새사건으로완료하지않는다.'},
 {source:'https://anime.priconne-redive.jp/story/ep_06.html',fact:'주민을해치는수수께끼기사때문에모두가밥을먹기어렵다며페코린느가화를낸다. 미식전이의뢰에나서며자칭군인인작은여자아이와만난다. 제목의모니카·공식인물목록을함께확인했다.'},
 {source:'https://anime.priconne-redive.jp/story/ep_07.html',fact:'미식전은쌀농사를한다. 길에서쓰러진치카를발견하고같은카르미나의노조미를불러보살핀다. 농사·다른길드의연락과도움만소재로하며본편치카문제를해결하지않는다.'},
 {source:'https://anime.priconne-redive.jp/music/',fact:'카르미나의노조미·치카·츠무기가노래에참여한다. 노래의가사를재현하거나새전투스킬로지급하지않는다.'},
 {source:'https://priconne.kakaogames.com/character.html',fact:'한국어표기노조미·츠무기·카스미·모니카를명단에서확인했다. 명단만으로모든능력을읽었다고하지않는다.'}
];
const request={review:false,system:'한국어 서브컬처 사건 구상자다. 실제로 곤란한 물건·부탁·인물의 다른 관점에서 사건을 만든다. 독립 사건8개를제안하되약한것은검토에서폐기할수있다. 한문제와전혀상관없는카드를주기위해인물만끼워넣지않는다. 원작소재를별도창작으로연결한다.',schema,brief:{sources,existingEvents:data.events.map(e=>({key:e.key,title:e.title,story:e.story})),directions:['농작업과물이흐를길·수확시점등의문제','츠무기의의상가게에서의뢰와받을사람이엇갈리는문제','카스미가다른증언을대조하던중남은부탁','모니카와주민의서로다른우선순위를정하는준비','카르미나의모임·연습을도울때전부맡을수없는사정','유우키의배달과미식전의모험중책임을넘길경계를정하는문제'],rules:'각8개는새독립문제다.그냥돈내고카드·위험올리고카드·골드받기만반복하지않는다.똑같은식사나숨은메뉴·인형수선·길드청소·번진지도·아오이안내장·잘못온박·문병객·일반수업은제외. 이야기는가능하지만결과에실제로적용할수있는값은골드비용/보상·기존물약·지정캐릭터카드·개인적단계/수±뿐이다. 현재체력·팀라이프·AP·남은시간지불, 새로운몹종류·NPC동행·창고·퀘스트재고·관계게이지·세계구출결말없음. 카드효과는24개능력치에서인물태도를각색할수있지만원작전투스킬실현으로설명하지않는다. 무보상금욕·미담을유일정답으로만들지말고각선택이남긴다른문제를보여라. uncertain은추측인설정을적고무근거로확정하지말라. 기존전투카드와따라오는효과를잃지않는다.'}};
fs.writeFileSync(path.join(root,'requests/gourmet-pitches-05.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('미식전의 서로 다른 추가 독립 문제8개 제안 요청 보존.');

# 가방 입력과 상태·카드 통합 UI 분리 전 원본

기준 커밋 7b5f4852353007fe20421e9fffce17eec8f28325

I키 독립 가방 진입과 통합 상태·카드 화면을 교체하기 전 보존본이다. 활성 import에서 참조하지 않는다.

- `UI/UI_Item.j` · SHA-256 `eeb6cfd9aadde02563eba9c530d5dfc2d4aec66cb71991ce58efdde15b590fd1`
- `UI/UI_PrototypeStatus.j` · SHA-256 `49cfe0c27734cfc6f0f049a3ea337ea41b4a035f2b1888bfd9d40762cbbbc075`
- `UI/UI_Info2.j` · SHA-256 `b15be923f0352ee75ed5810a2289d711698ebb1fb925c85a26bc5b315e83385f`
- `UI/UI_OFF.j` · SHA-256 `25dab00640dc0b70d84a259d4cb88df99dd49ebce14b9e09725b42ff943cd871`

## 분리 결과

- `UI_Item.j`의 기존 IKey와 BindInput 등록부를 활성 코드에서 제거했다. 기존 I키/가운데 클릭 콜백은 이 원본에서 확인할 수 있다.
- `LEGACY_INVENTORY_UI_ENABLED = false`로 가방 ShowMenu 및 `UI_OFF.j`의 ShopShow/Shop2Show/StorageShow 진입을 차단했다. 사용자 요청에 따라 구형 상점·창고 UI도 사용하지 않는다.
- `UI_Item.j`는 장비창 `UI_Info.j`, 아이템 저장·로드 및 장착 계산이 참조하는 배열·함수를 제공하므로 통째로 import에서 제거하지 않았다. 다른 코드가 참조하는 프레임을 0으로 만들지 않도록 숨겨진 기존 프레임 생성도 유지했다.
- 새 I키 등록과 보유 카드 격자는 `UI/UI_PrototypeCards.j`에서 담당한다. 실제 보상 지급이나 전투 수치를 변경하지 않는 로컬 조회 화면이다.
- Tab의 `UI/UI_PrototypeStatus.j`에서는 카드 전용 프레임과 탭/정렬/페이지 처리를 제거했다.

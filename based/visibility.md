external / public / internal / private

1) public

외부(EOA/다른 컨트랙트)에서도 호출 가능

컨트랙트 내부에서도 getMinMax()처럼 바로 호출 가능

“외부 + 내부 둘 다 쓰겠다”면 보통 public

function getMinMax() public view returns (uint, uint) { ... }

2) internal

컨트랙트 내부 + 상속받은 자식 컨트랙트에서만 호출 가능

외부에서는 호출 불가 (Remix 버튼도 안 떠/호출 불가)

function getMinMax() internal view returns (uint, uint) { ... }

3) private

오직 이 컨트랙트 안에서만 호출 가능

자식 컨트랙트에서도 호출 불가

외부 호출도 불가

function getMinMax() private view returns (uint, uint) { ... }

“조회 함수(=getter 느낌)”는 external 또는 public

내부에서도 쓸 거면 public

내부에서 안 쓰면 external

“보조 함수/로직 분리”는 보통 internal

“진짜 숨기고 싶을 때만” private (상속에서도 못 쓰니까 생각보다 덜 씀)

상태변수에는 external을 붙일 수 없어. (external은 함수에만 붙는 가시성)
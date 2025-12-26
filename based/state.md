1) pure

상태변수 읽기도 안 함, 쓰기도 안 함

입력값/로컬 변수로만 계산할 때

function f(uint a, uint b) external pure returns (uint) {
    return a + b;
}

2) payable

이 함수가 ETH를 받을 수 있음

상태 변경 여부와는 별개지만, “mutability specifier”로 같이 분류됨

function deposit() external payable {
    // msg.value 사용 가능
}

3) (아무 것도 안 붙임)

view/pure 제약이 없어서 상태 변경 가능

보통 쓰기 함수(저장, 업데이트, emit 등)

function set(uint x) external {
    value = x; // 상태 변경
}

정리

view: 상태 읽기 O / 상태 쓰기 X

pure: 상태 읽기 X / 상태 쓰기 X

payable: ETH 수신 가능(읽기/쓰기 여부는 코드에 따라 가능)

(없음): 상태 쓰기 가능
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    // 데이터
    mapping(address => uint256) private balances; // 사용자 지갑별로 balances를 mapping하여 구분
    address private owner; // 컨트랙트 배포자

    // 입금과 출금을 한 경우 각각 함수 호출자의 지갑 주소와 입출금 개수를 event로 나타냄
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    // 컨트랙트 배포자를 owner로 지정
    constructor() {
        owner = msg.sender;
    }

    // onlyOwner modifier를 사용하여 getContractBalance 함수에서 owner만 호출 가능하도록 함
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // deposit 함수는 payable을 붙여 이더리움을 전송할 수 있게 함
    function deposit() public payable {
        // 이더리움을 입금하며 0보다 큰 개수만큼 입금하도록 require문 사용
        require(msg.value > 0, "deposit more than 0eth");
        // 함수 호출자 주소와 mapping되는 잔고에 입금한 이더리움만큼 추가됨
        balances[msg.sender] += msg.value;
        // Deposit 이벤트를 통해 입금자 지갑 주소와 입금한 이더의 개수를 블록체인 로그에 기록
        emit Deposit(msg.sender, msg.value);
    }

    // withdraw: 이더리움을 받는 함수가 아니라 보내는 함수이기 때문에 payable 선언을 안함
    function withdraw(uint256 amount) public {
        // 잔고보다 출금하려는 이더리움 개수가 많은 경우 require문으로 제어함
        require(balances[msg.sender] >= amount * 1 ether, "balances is not enough to withdraw");
        // 잔고에서 출금하는 이더리움 개수만큼 차감
        balances[msg.sender] -= amount * 1 ether;
        // payable을 사용하여 함수 호출자 지갑주소와 mapping된 balances에서 차감한 이더리움 개수만큼 함수 호출자 지갑으로 보냄
        payable(msg.sender).transfer(amount * 1 ether);
        // Withdrawal 이벤트를 통해 출금자 지갑 주소와 출금한 이더의 개수를 블록체인 로그에 기록
        emit Withdrawal(msg.sender, amount * 1 ether);
    }

    // getBalance: 함수 호출자의 balances를 이더리움 단위로 확인
    function getBalance() public view returns (uint256) {
        return balances[msg.sender] / 1 ether;
    }

    // getContractBalance: owner만 컨트랙트 이더리움 잔고를 확인가능하며 이더리움 단위로 확인
    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance / 1 ether;
    }
}

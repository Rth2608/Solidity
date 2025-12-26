// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

contract send_transfer
{
    /// 블록체인 상태(state)에 저장된 값(계정의 balance)이므로 읽기 = state 조회
    function getBalance(address _address) public view returns(uint)
    {
        return _address.balance;
    }

    function etherUnits() public pure returns(uint, uint, uint)
    {
        return (1 ether, 1 gwei, 1 wei);
    }

    /// 고정 금액 10 ETH 전송
    function ethDelivery1(address payable _address) public payable 
    {
        bool result = _address.send(10 ether);
        require(result, "Failed");
    }

    function ethDelivery2(address _address) public payable 
    {
        payable(_address).transfer(msg.value);
    }
    // send와 transfer의 차이
}

contract call
{
    function getBalance(address _address) public view returns (uint) 
    {
        return _address.balance;
    }

    function ethDelivery(address _address) public payable 
    {
        (bool result, ) = _address.call{value:msg.value, gas: 30000}("");
        require(result, "Failed");
    }
}

/// _address.balance는 wei라서, 사람이 보기 쉽게 ether로 보고 싶으면
/// return _address.balance / 1 ether; // (정수 나눗셈이라 소수는 버려짐)


contract funcReceive
{
    event Obtain(address from, uint amount);

    receive() external payable 
    {
        emit Obtain(msg.sender, msg.value);
    }

    function gerBalance() public view returns (uint)
    {
        return address(this).balance;
    }

    function sendEther() public payable 
    {
        payable(address(this)).transfer(msg.value);
    }
}

contract constructorPayable
{
    constructor() payable
    {

    }

    function getBalance() public view returns (uint)
    {
        return address(this).balance;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank
{
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    constructor()
    {
        owner = mag.sender;
    }

    modifier onlyOwner()
    {
        require(owner == msg.sender, "not Owner");
        _;
    }

    function deposit() public payable
    {
        require(msg.value > 0, "deposit more than 0 ether");

    }

    function deposit() public __________ {
}
function withdraw(uint256 amount) public {
}
function getBalance() public view returns (uint256) {
}
function getContractBalance() public view _____________ returns (uint256) {
}

}
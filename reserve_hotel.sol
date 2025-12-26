// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HotelRoom
{
    enum status {Vacant, Occupied}

    event Reserved(address indexed reserver, uint amount);
    
    address public owner;
    status public roomStatus;
    uint256 public constant MIN_RESERVATION_FEE = 10 ether;

    
    constructor()
    {  
        owner = msg.sender;
        roomStatus = status.Vacant;
    }

    modifier onlyWhileVacant()
    {
        require(roomStatus == status.Vacant, "currently occupied");
        _;
    }

    modifier cost(uint _amount)
    {
        require(_amount > MIN_RESERVATION_FEE, "Not enough ether provided");
        _;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only owner can do");
        _;
    }

    function book () public payable onlyWhileVacant cost(msg.value)
    {
        roomStatus = status.Occupied;
        payable(owner).transfer(msg.value);
    }

    function reset () public onlyOwner
    {
        roomStatus = status.Vacant;
    }
}


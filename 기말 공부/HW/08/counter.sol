// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter
{
    uint private counter;

    function get() public view returns (uint)
    {
        return counter;
    }

    function inc() public
    {
        counter += 1;
    }

    function dec() public
    {
        require(counter > 0, "counter already Zero");
        counter -= 1;
    }

}
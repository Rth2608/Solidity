// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract over_under_flow
{
    error Overflow();

    uint min = type(uint).min;
    uint max = type(uint).max;

    function underflow() public view returns(uint)
    {
        return min - 1;
    }

    function overflow() public view returns(uint)
    {
        return max + 1;
    }

    function unchecked_underflow() public view returns(uint)
    {
        unchecked
        {
            return min - 1;
        }
    }

    function unchecked_overflow() public view returns(uint)
    {
        unchecked
        {
            return max + 1;
        }
    }

    function unchecked_error_overflow() public view returns(uint)
    {
        uint x =  max + 1;
        if(x < max) overflow();
        return x;
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

contract SimpleStrorage
{
    uint min = type(uint).min;
    uint max = type(uint).max;

    function uint_min_underflow() public view returns(uint)
    {
        return min - 1;
    }

    function uint_max_overflow() public view returns(uint)
    {
        return max + 1;
    }
}
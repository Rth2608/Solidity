// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract SimpleStorage
{
    uint min = type(uint).min;
    uint max = type(uint).max;

    /// tuple 반환값으로 index 0 : min, index 1 : max
    function getMinMax() external view returns (uint, uint)
    {
        return (min, max);
    }

    function under() public view returns (uint)
    {
        return min - 1;
    }

    function over() public view returns (uint)
    {
        return max + 1;
    }
}
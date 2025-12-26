// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// 0.8.0 버전보다 높은 컴파일러는 overflow와 underflow를 자동으로 탐지함

contract Counter {
    // private를 사용하여 외부에 count 변수를 노출시키지 않음
    uint8 private count = 100;

    // 현재 카운트 값을 반환하는 함수
    function get() public view returns (uint8) 
    {
        return count;
    }

    // 카운트를 1 증가시키는 함수
    function inc() public 
    {
        count += 1;
    }

    // 카운트를 1 감소시키는 함수
    function dec() public 
    {
        count -= 1;
    }

    // underflow 테스트하기 위해 uint8 자료형 최소값으로 초기화
    function setToMin() public {
        count = type(uint8).min;
    }

    // overflow 테스트하기 위해 uint8 자료형 최대값으로 초기화
    function setToMax() public {
        count = type(uint8).max;
    }
}

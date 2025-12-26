// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract cloud_funding
{
    struct Investor
    {
        address addr;   // 투자자 주소
        uint amount;    // 투자액 (wei 단위)
    }
    
    event Funded(address indexed investor, uint amount);    // fund() 때마다 발생시킬 이벤트

    mapping(uint => Investor) public investors; // 투자자 증가할 때 key 추가

    address public owner; // 컨트랙트 소유자
    uint public numInvestors; // 투자자 수
    uint public deadline; // 모금 마감일
    string public status; // 모금활동 상태 (Funding, Campaign Succeeded, Campaign Failed)
    bool public ended; // 모금 종료 여부
    uint public goalAmount; // 목표액(ETH 단위)
    uint public totalAmount; // 총 투자액(wei 단위)

    // 컨트랙트를 배포할 때 딱 한 번만 호출
    constructor(uint _duration, uint _goalAmount)
    {  
        owner = msg.sender; // 컨트랙트 배포자 저장
        deadline = block.timestamp + (_duration * 1 seconds); // 모금기간(초 단위)
        goalAmount = _goalAmount; // ETH 단위로 모금 목표치를 저장
        status = "Funding"; // 모금활동 상태를 모금 진행중으로 저장
        ended = false;  // 모금이 종료되었는지 여부 저장
        numInvestors = 0;   // 모금에 참여한 투자자 수 저장
        totalAmount = 0;    // 모금이 총 얼마나 되었는지 저장
    }

    // 컨트랙트 소유자만 실행하도록 modifire 정의
    modifier onlyOwner()
    {
        // 컨트랙트 배포자가 아닌 경우 require문으로 에러 메시지 출력
        require(msg.sender == owner,"You are not owner [Failed]");
        _;
    }

    // 투자자가 투자할 때 호출하는 함수
    function fund() public payable
    {
        // 모금이 종료된 경우 require문 사용을 사용하여 모금을 진행할 수 없도록 함
        require(!ended, "Funding was ended");
        // 모금 가능한 시간을 초과한 경우 더 이상 모금을 못하도록 함
        require(deadline > block.timestamp, "Funding was ended");
        // investors 구조체에 투자자 주소 저장
        investors[numInvestors].addr = msg.sender;
        // investors 구조체에 투자 금액 저장
        investors[numInvestors].amount = msg.value;
        // 전체 투자 금액 업데이트
        totalAmount += msg.value;
        // 총 투자자 수 업데이트
        numInvestors += 1;
        // fund()가 호출될 때마다 이벤트를 발생
        emit Funded(msg.sender, msg.value);
    }

    // 투자자 주소 목록 반환 (주소타입의 배열을 반환)
    function getInvestors() public view returns (address[] memory) 
    {
        address[] memory addrs = new address[](numInvestors); // 투자자 수만큼 배열 생성
        for (uint i = 0; i < numInvestors; i++) 
        {
            addrs[i] = investors[i].addr; // mapping에 저장된 구조체에서 주소만 저장
        }
        return addrs;
    }

    /* 컨트랙트 배포자만 실행가능하도록 modifier을 통해 통제하며 모금이 종료되었을 때만 실행되도록 하며
    목표액 달성 여부에 따라 실패할 경우 환불 또는 성공할 경우 컨트랙트 배포자에게 모금된 이더 송금*/
    function checkGoalReached () public onlyOwner
    {
        // 모금 종료 시간이 되지 않은 경우 require 문으로 에러메시지 호출
        require(deadline < block.timestamp, "Funding is not ended");
        if(goalAmount * 1 ether > totalAmount)    // 모금에서 목표액이 달성 못했을 경우
        {
            // 반복문을 통해 investors 구조체에 idx을 index로 각 투자자를 구분하여 모금한 금액을 환불해줌
            for (uint i = numInvestors; i > 0; i--)
            {
                uint idx = i - 1;
                payable(investors[idx].addr).transfer(investors[idx].amount);
            }
            // 상태를 모금활동 실패로 변경
            status = "Campaign Failed";
        }
        else    // 모금이 성공적으로 완료된 경우
        {
            payable(msg.sender).transfer(totalAmount); // 컨트랙트 배포자에게 모금된 이더를 송금함
            status = "Campaign Succeeded";  // 상태를 모금활동 성공으로 변경
        }
        // 모금 활동을 중단하여 더 이상의 모금을 할 수 없도록 함
        ended = true;
    }
}

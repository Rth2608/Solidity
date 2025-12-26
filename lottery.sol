// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lottery 
{
    // 관리자(배포자)
    address public manager;
    // 게임 참여자
    address[] public players;
    // 1 ether 제한
    uint public constant BET_AMOUNT = 1 ether;
    // 베팅 가능 여부
    bool public bettingOpen;
    // 참가자 정보: 베팅 참여시(enter 함수 실행시)
    event BetEntered(address indexed player, uint amount);
    // 우승자 정보와 금액: pickWinner 함수 호출시
    event WinnerPicked(address indexed winner, uint amount);

    constructor() 
    {
        manager = msg.sender;   // manager를 컨트랙트 배포자로 초기화
        bettingOpen = false;    // 처음은 배팅 불가로 초기화
    }

    // 컨트랙트 배포자만 호출가능하도록
    modifier onlyOwner() 
    {
        require(msg.sender == manager, "only the manager can call this func");
        _;
    }

    // 컨트랙트 배포자 배팅 금지
    modifier restricted() 
    {
        require(msg.sender != manager, "owner can't betting");
        _;
    }
    
    // 배팅 금액 1ether 고정
    modifier bet_amount_restrict(uint _amount)
    {
        require(_amount == BET_AMOUNT, "Bet must be exactly 1 ether");
        _;
    }

    // 배팅을 이미 했는지 확인
    modifier already_enter()
    {
        require(!isPlayer(msg.sender), "Already participated");
        _;
    }

    // 현재 베팅 가능한지 확인
    modifier onlyWhenBettingOpen() 
    {
        require(bettingOpen, "Betting is closed");
        _;
    }

    // 베팅 시작 (enter 호출 가능하도록)
    function openBetting() public onlyOwner 
    {
        require(!bettingOpen, "Betting already open");
        bettingOpen = true;
    }

    // 베팅 종료 (enter 호출 불가하도록)
    function closeBetting() public onlyOwner 
    {
        require(bettingOpen, "Betting already closed");
        bettingOpen = false;
    }


    // 컨트랙트 소유자를 제외한 지갑에서 1ether를 보냈을 때 배팅을 하게 하며 지갑별로 딱 한번 배팅 가능하도록 함
    function enter() public payable restricted already_enter bet_amount_restrict(msg.value) onlyWhenBettingOpen  
    {
        // 배팅 참여 여부 저장
        players.push(msg.sender);
        // 배팅 참여 이벤트 발생
        emit BetEntered(msg.sender, msg.value);
    }

    // 우승자 추첨
    function pickWinner() public onlyOwner 
    {
        require(players.length >= 1, "No players"); // 배팅한 사용자가 없으면 추첨을 못하므로 예외처리
        require(bettingOpen, "Betting is not open"); // 참여 단계에서만 추첨
        bettingOpen = false;    // 추첨과 동시에 참여 단계 종료

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.number, block.timestamp, players.length))); // 배팅한 사람수에 맞춰서 랜덤 숫자 추출
        uint256 winnerIndex = randomNumber % players.length;    // 추출한 랜덤 숫자로 우승자를 특정함
        address winner = players[winnerIndex];  // 우승자 주소 저장

        uint256 prize = address(this).balance;  // 컨트랙트에 있는 이더리움 즉 배팅된 총 금액을 상금으로 지정
        payable(winner).transfer(prize);    // 우승자에게 상금만큼 이더 전송

        // 우승자 + 상금 이벤트
        emit WinnerPicked(winner, prize);

        // 다음 라운드를 위해 players 초기화
        delete players;
    }

    // 배팅 참여자 반환
    function getPlayers() public view returns (address[] memory) 
    {
        return players;
    }

    // 배팅에 참여한 사용자인지 여부 반환
    function isPlayer(address _player) public view returns (bool) 
    {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == _player) 
            {
                return true;
            }
        }
        return false;
    }
}

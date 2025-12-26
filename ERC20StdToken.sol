// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC20StdToken 
{
    // 각 주소가 보유한 토큰의 잔액을 저장하는 매핑
    mapping (address => uint256) balances;
    // 특정 주소가 소유자의 토큰을 얼마나 사용할 수 있는지를 저장하는 이중 매핑
    mapping (address => mapping (address => uint256)) allowed;
    // 토큰의 전체 발행량을 저장하는 변수
    uint256 private total;
    // 토큰 메타데이터
    string public name;
    string public symbol;
    uint8 public decimals;
    // 토큰 전송 시 발생하는 로그
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Approve 발생 시 남기는 로그
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 컨트랙트가 최초 배포될 때 한 번만 실행되는 초기화 함수
    constructor (string memory _name, string memory _symbol, uint _totalSupply) 
    {
        // 토큰 메타데이터
        total = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = 0;
        // 배포자에게 초기 발행량을 모두 할당
        balances[msg.sender] = _totalSupply;
        // 토큰이 생성되었음을 알리는 이벤트 발생
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }
    
    // 전체 발행량을 반환
    function totalSupply() public view returns (uint256) 
    {
        return total;
    }

    // 특정 주소(_owner)의 잔액을 반환
    function balanceOf(address _owner) public view returns (uint256 balance) 
    {
        return balances[_owner];
    }

    // _owner가 _spender에게 사용을 허락한 남은 금액을 반환
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) 
    {
        return allowed[_owner][_spender];
    }

    // 호출자가 _to 주소로 _value 만큼 토큰을 직접 전송
    function transfer(address _to, uint256 _value) public returns (bool success) 
    {
        // 보내는 사람의 잔액이 보낼 금액보다 많거나 같은지 확인
        require(balances[msg.sender] >= _value);

        // 받는 사람의 잔액이 늘어났는지 확인하는 오버플로우 방지 검사인데 0.8.0 컴파일러 이상이라 항상 true
        if ( (balances[_to] + _value) >= balances[_to]) 
        {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            // 전송 이벤트 발생
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        else 
        {
            return false;
        }
    }

    // 미리 approve 함수를 통해 권한을 위임받아야 하며 _from 주소에서 _to 주소로 권한이 있는 제3자가 호출해서 토큰 전송
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) 
    {
        // 토큰 소유자(_from)의 잔액이 충분한지 확인
        require(balances[_from] >= _value);
        // 호출자가 _from으로부터 받은 허용량이 충분한지 확인
        require(allowed[_from][msg.sender] >= _value);

        // 오버플로우 방지 검사
        if ( (balances[_to] + _value) >= balances[_to]) 
        {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        else 
        {
            return false;
        }
    }

    // 호출자가 _spender에게 _value 만큼의 토큰 사용 권한을 부여
    function approve(address _spender, uint256 _value) public returns (bool success) 
    {
        // // 허용량 매핑 업데이트
        allowed[msg.sender][_spender] = _value;
        // 승인 이벤트 발생
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NameRegistry {
    // 컨트랙트 정보를 나타낼 구조체
    struct ContractInfo 
    {
        address contractOwner; // 컨트랙트를 등록한 사람 (소유자)
        address contractAddress; // 실제 배포된 컨트랙트 주소
        string description; // 컨트랙트에 대한 설명
    }
    // 등록된 컨트랙트 수
    uint public numContracts;
    // 등록한 컨트랙트들을 저장할 매핑(이름->컨트랙트 정보 구조체)
    mapping(string => ContractInfo) public registeredContracts;

    // 새 컨트랙트가 등록될 때 이벤트
    event ContractRegistered
    (
        string indexed name,
        address indexed owner,
        address contractAddress,
        string description
    );

    // 컨트랙트가 삭제될 때 이벤트
    event ContractDeleted
    (
        string indexed name,
        address indexed owner,
        address contractAddress
    );

    // 컨트랙트 정보가 변경될 때 이벤트
    event ContractUpdated
    (
        string indexed name,
        string updateType // "OwnerChanged", "AddressChanged", "DescriptionChanged" 같은 문자열을 넣어줌
    );

    // 지정된 이름의 컨트랙트에 대해 소유자만 변경 가능하도록 제한
    modifier onlyOwner(string memory _name) 
    {
        require(registeredContracts[_name].contractOwner == msg.sender,"Not contract owner");
        _;
    }

    // 컨트랙트 배포시 실행
    constructor() 
    {
        numContracts = 0;
    }

    // 컨트랙트 등록 (아직 사용하지 않은 이름이어야 함)
    function registerContract(string memory _name,address _contractAddress,string memory _description) public 
    {
        // 이미 등록된 이름인지 확인
        require(registeredContracts[_name].contractAddress == address(0),"Name already registered");
        // 함수 호출자가 정한 이름으로 컨트랙트 주소와 설명이 담긴 컨트랙트 등록
        registeredContracts[_name] = ContractInfo({contractOwner: msg.sender,contractAddress: _contractAddress,description: _description});
        // 컨트랙트 개수 업데이트
        numContracts += 1;
        // 이벤트: 새 컨트랙트 등록
        emit ContractRegistered(_name, msg.sender, _contractAddress, _description);
    }

    // 컨트랙트 삭제 (소유자만 가능)
    function unregisterContract(string memory _name) public onlyOwner(_name)
    {
        // 이벤트에 넣어줄 삭제할 컨트렉트 주소
        address oldAddr = registeredContracts[_name].contractAddress;
        // 해당 이름의 컨트랙트 삭제
        delete registeredContracts[_name];
        // 컨트랙트 개수 업데이트
        numContracts -= 1;
        // 이벤트: 컨트랙트 삭제
        emit ContractDeleted(_name, msg.sender, oldAddr);
    }

    // 컨트랙트 소유자 변경 (소유자만 가능)
    function changeOwner(string memory _name, address _newOwner) public onlyOwner(_name)
    {
        // 해당 이름의 컨트랙트 소유자 변경
        registeredContracts[_name].contractOwner = _newOwner;
        // 이벤트 : 어떤 변경인지: OwnerChanged
        emit ContractUpdated(_name, "OwnerChanged");
    }

    // 컨트랙트 소유자 조회
    function getOwner(string memory _name) public view returns (address)
    {
        // 컨트랙트 이름으로 소유자 조회
        return registeredContracts[_name].contractOwner;
    }

    // 컨트랙트 주소 변경 (소유자만 가능)
    function setAddr(string memory _name, address _addr) public onlyOwner(_name)
    {
        // 컨트랙트 이름으로 조회하여 주소 변경
        registeredContracts[_name].contractAddress = _addr;
        // 이벤트 : 어떤 변경인지: AddressChanged
        emit ContractUpdated(_name, "AddressChanged");
    }

    // 컨트랙트 주소 조회
    function getAddr(string memory _name) public view returns (address)
    {
        // 컨트랙트 이름으로 주소 조회
        return registeredContracts[_name].contractAddress;
    }

    // 컨트랙트 설명 변경 (소유자만 가능)
    function setDescription(string memory _name,string memory _description) public onlyOwner(_name)
    {
        // 컨트랙트 이름으로 설명을 조회하고 변경
        registeredContracts[_name].description = _description;

        // 이벤트 : 어떤 변경인지: DescriptionChanged
        emit ContractUpdated(_name, "DescriptionChanged");
    }

    // 컨트랙트 설명 조회
    function getDescription(string memory _name) public view returns (string memory)
    {
        // 컨트랙트 이름으로 설명 조회
        return registeredContracts[_name].description;
    }
}

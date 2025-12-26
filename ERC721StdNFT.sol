// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 스마트 컨트랙트가 특정 인터페이스를 구현하고 있는지 확인하는 표준
interface ERC165 
{
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// NFT 표준 정의 / ERC-165를 상속받음
interface ERC721 is ERC165 
{
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// safeTransferFrom 실행 시 호출되는 스마트 컨트랙트가 NFT를 안전하게 받을 수 있는지 확인하기 위한 인터페이스
interface ERC721TokenReceiver 
{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}


contract ERC721StdNFT is ERC721
{
    // 컨트랙트 배포자
    address public founder;
    // Mapping from token ID to owner address(각 NFT의 소유자 주소)
    mapping(uint => address) internal _ownerOf; // tokenId → owner
    // Mapping owner address to token count(특정 주소가 보유한 NFT의 개수)
    mapping(address => uint) internal _balanceOf; // owner → number of NFTs
    // Mapping from token ID to approved address(특정 NFT를 대신 전송할 권리를 부여받은 주소를 저장)
    mapping(uint => address) internal _approvals; // tokenId → approved
    // Mapping from owner to operator approvals(특정 주소가 소유자의 모든 NFT를 관리할 권한이 있는지)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    // nft 메타데이터
    string public name;
    string public symbol;

    // 컨트랙트 배포 시 1 실행
    constructor (string memory _name, string memory _symbol) 
    {
        // 배포자를 founder로 설정
        founder = msg.sender;
        // NFT 메타데이터 등
        name = _name;
        symbol = _symbol;
        // 초기 토큰 5개를 배포자에게 자동 발행
        for (uint tokenID=1; tokenID<=5; tokenID++) 
        {
            _mint(msg.sender, tokenID);
        }
    }

    // 토큰 발행(Minting) 로직
    function _mint(address to, uint id) internal 
    {
        // 0번 주소로 발행 불가
        require(to != address(0), "mint to zero address");
        // 이미 존재하는 ID인지 확인
        require(_ownerOf[id] == address(0), "already minted");
        // 받는 사람의 잔고 증가
        _balanceOf[to]++;
        // 토큰의 주인 설정
        _ownerOf[id] = to;
        // 생성 이벤트 발생
        emit Transfer(address(0), to, id);
    }

    // 오직 founder만 호출 가능하며 추가 토큰 발행
    function mintNFT(address to, uint256 tokenID) public 
    {
        require(msg.sender == founder, "not an authorized minter");
        _mint(to, tokenID);
    }

    // Token ID의 소유자 반환
    function ownerOf(uint256 _tokenId) external view returns (address) 
    {
        address owner = _ownerOf[_tokenId];
        require(owner != address(0), "token doesn't exist");
        return owner;
    }

    // 특정 주소의 NFT 보유량 반환
    function balanceOf(address _owner) external view returns (uint256) 
    {
        require(_owner != address(0), "balance query for the zero address");
        return _balanceOf[_owner];
    }

    // 특정 토큰에 대해 승인받은 주소 반환
    function getApproved(uint256 _tokenId) external view returns (address) 
    {
        require(_ownerOf[_tokenId] != address(0), "token doesn't exist");
        return _approvals[_tokenId];
    }

    // 소유자와 운영자 간의 전체 위임 여부 반환
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) 
    {
        return _operatorApprovals[_owner][_operator];
    }

    // 호출자는 소유자이거나 이미 전체 권한을 가진 관리자여야 하며 특정 토큰 하나에 대한 전송 권한 부여
    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = _ownerOf[_tokenId];
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender],"not authorized");
        // 권한 부여 업데이트
        _approvals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    // 주로 NFT 마켓플레이스 등록 시 사용
    function setApprovalForAll(address _operator, bool _approved) external 
    {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // 실제 로직은 _transferFrom 함수가 처리
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable 
    {
        _transferFrom( _from, _to, _tokenId);
    }

    // 실제 소유권 이전이 일어나는 핵심 함수
    function _transferFrom(address _from, address _to, uint256 _tokenId) private 
    {
        address owner = _ownerOf[_tokenId];
        // 유효성 검사
        require(_from == owner, "from != owner");
        require(_to != address(0), "transfer to zero address");
        // 권한 검사
        require(msg.sender == owner || msg.sender == _approvals[_tokenId] || _operatorApprovals[owner][msg.sender], "not authorized");
        _balanceOf[_from]--;        // 보내는 사람 balance 감소
        _balanceOf[_to]++;          // 받는 사람 balance 증가
        _ownerOf[_tokenId] = _to;   // 토큰 소유자 변경
        delete _approvals[_tokenId];// 소유자가 바뀌었으므로 기존 개별 승인 권한 삭제

        emit Transfer(_from, _to, _tokenId);
    }

    // safeTransferFrom (데이터 없는 버전)
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable 
    {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    // safeTransferFrom (데이터 포함 버전)으로 받는 주소가 스마트 컨트랙트일 경우, NFT 수신 기능이 구현되어 있는지 확인하여 NFT가 컨트랙트 내에 영원히 갇히는 것을 방지함
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable 
    {
        // // 먼저 일반 전송 수행
        _transferFrom(_from, _to, _tokenId);
        // 받는 주소(_to)가 컨트랙트인지 확인하여 컨트랙트라면 onERC721Received 함수를 호출하여 올바른 값을 반환하는지 검사
        require(_to.code.length == 0 || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) ==ERC721TokenReceiver.onERC721Received.selector,"unsafe recipient");
    }

    // // 이 컨트랙트가 ERC-721 표준을 따르고 있음을 외부에 알림
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) 
    {
        return interfaceId == type(ERC721).interfaceId || interfaceId == type(ERC165).interfaceId;
    }
}
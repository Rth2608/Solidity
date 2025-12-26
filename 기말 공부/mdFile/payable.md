address 자료형의 ether를 전송하는 내장 함수

1) (payable이 적용된 adddress).send(송금할 wei)
실패시 return false (require과 함께 이용 권장)

2) (payable이 적용된 address).transfer(송금할 wei)
실패시 transaction fail

3) (address).call{value : 송금할 wei}("")
실패시 return false (require과 함께 이용 권장)

가스 소비량 : call은 가변적이며 send, transfer은 2300 gas
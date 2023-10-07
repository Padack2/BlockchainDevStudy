//// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.4.11;
contract SmartContract {
	// 투자자 구조체
	struct Investor {
		address addr;	// 투자자의 어드레스
		uint amount;	// 투자액
	}
	
	address public owner;		// 컨트랙트 소유자
	uint public numInvestors;	// 투자자 수
	uint public totalAmount;	// 총 투자액
	mapping (uint => Investor) public investors;	// 투자자 관리를 위한 매핑
	
	modifier onlyOwner () {
		require(msg.sender == owner);
		_;
	}
    uint randNonce = 0;
	
	/// 생성자
	constructor() {
		owner = msg.sender;

		numInvestors = 0;
		totalAmount = 0;
	}

    /// 이더를 지불할 때 호출되는 함수
	function bet () public payable {
		// 1 ETH가 아니면 처리 종료
		require(msg.value == 1000000000000000000);
		
		Investor storage inv = investors[numInvestors++];
		inv.addr = msg.sender;
		inv.amount = msg.value;
		totalAmount += inv.amount;
	}

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
	
	function draw () payable public onlyOwner {	
		if(totalAmount >= 0) {

            uint selected = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % numInvestors;
            randNonce++;
            uint ownershare = uint(getBalance() / 10);
            uint prize = uint(getBalance() - ownershare);

			if(!payable(owner).send(ownershare)) {
				revert();
			}
            
            if(!payable(investors[selected].addr).send(prize)) {
                revert();
            }
            numInvestors = 0;
            totalAmount = 0;
		}
	}
	
	/// 컨트랙트를 소멸시키기 위한 함수
	function kill() public onlyOwner {
		//selfdestruct(payable(owner));
	}
}

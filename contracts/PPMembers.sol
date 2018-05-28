pragma solidity 0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract PPMembers is Ownable {

	uint internal totalMembers;

	mapping(address => Member) private ppMembers;
	struct Member { uint voteWeight; bool inCouncil; bool expelled; }

	event NewMember(address indexed member, uint voteWeight, bool inCouncil);
	event RemovedMember(address indexed member, bool expelled);
	event CouncilChange(address indexed who, bool inCouncil);

	function removeMember(address member, bool expelled) external onlyOwner {
			ppMembers[member].voteWeight = 0;
			ppMembers[member].inCouncil = false;
			ppMembers[member].expelled = expelled;
			totalMembers--;
			emit RemovedMember(member, expelled);
	}

	function setInCouncil(address member, bool inCouncil) external onlyOwner {
			require(ppMembers[member].voteWeight > 0, "member's vote weight should be > 0");
			require(!ppMembers[member].expelled, "member should not be expelled");
			ppMembers[member].inCouncil = inCouncil;
			emit CouncilChange(member, inCouncil);
	}

	function getvoteWeightOf(address who) public view returns (uint) {
    	return ppMembers[who].voteWeight;
  }

	function isinCouncil(address who) public view returns (bool) {
    	return ppMembers[who].inCouncil;
  }

	function getTotalMembers() public view returns (uint) {
			return totalMembers;
	}

	function isExpelled(address who) public view returns (bool){
			return ppMembers[who].expelled;
	}

	function addNewMember(address newMember, uint voteweight, bool inCouncil) internal {
			require(voteweight > 0, "vote weight to set should be > 0");
			ppMembers[newMember].voteWeight = voteweight;
			ppMembers[newMember].inCouncil = inCouncil;
			ppMembers[newMember].expelled = false;
			totalMembers++;
			emit NewMember(newMember, voteweight, inCouncil);
	}
}

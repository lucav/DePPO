pragma solidity 0.4.24;

import "./PPMembers.sol";
import "./PPMotions.sol";


contract PoliticalParty is PPMembers, PPMotions {

	uint private newMembersFee;

	event ReceivedEther(address indexed sender, uint weiAmount);
	event Withdraw(address who, uint weiAmount);
	event FeeChanges(uint newFeeinFinney);

	modifier onlyValidMembers {
			require(getvoteWeightOf(msg.sender) > 0
				&& !isExpelled(msg.sender));
			_;
	}

	modifier onlyCounselors {
			require(getvoteWeightOf(msg.sender) > 0
				&& !isExpelled(msg.sender)
				&& isinCouncil(msg.sender));
			_;
	}

	// 	******************************
	//	INITIALIZERS
	constructor(uint minimumVoteToPassAMotion, uint minutesForDebate, uint newMembersFeeFinney) public {
      owner = msg.sender;
			require(newMembersFeeFinney > 0);
			newMembersFee = newMembersFeeFinney * 1 finney;
			ichangeVotingRules(minimumVoteToPassAMotion, minutesForDebate);
			totalMembers = 0;
	}

	function autodestroy() external onlyOwner {
			selfdestruct(owner);
  }
	// 	******************************

	// 	******************************
	//	MONEY MANAGEMENT
  function () public payable {
			require(msg.value > 0 && msg.value >= newMembersFee);
			require(!isExpelled(msg.sender)); // prevent expelled members

			emit ReceivedEther(msg.sender, msg.value);
			// if it's a new member
			if(getvoteWeightOf(msg.sender) < 1){
					addNewMember(msg.sender, 1, false);
			}
  }

	function withdrawFund(uint finneyAmount) external onlyOwner	{
			require(finneyAmount > 0);
			require(address(this).balance >= finneyAmount * 1 finney);
      owner.transfer(finneyAmount * 1 finney);
      emit Withdraw(owner, finneyAmount * 1 finney);
	}

	function getBalance() external view returns (uint) {
    	return address(this).balance;
  }

	function getNewMembersFee() external view returns (uint) {
    	return newMembersFee / 1 finney;
  }

	function setNewMembersFee(uint finneyAmount) external onlyOwner {
			require(finneyAmount > 0);
			newMembersFee = finneyAmount * 1 finney;
			emit FeeChanges(finneyAmount);
	}
	// 	******************************

	// 	******************************
	// 	MEMBER MANAGEMENT
	function addNewMemberByOwner(address who, uint voteWeight, bool isInCouncil) external onlyOwner {
			addNewMember(who, voteWeight, isInCouncil);
	}
	// 	******************************

	// 	******************************
	// 	VOTING MANAGEMENT
	function newMotion(string voteDescription, string voteSecretKey) external onlyCounselors  {
			inewMotion(voteDescription, voteSecretKey, msg.sender);
	}

	function newVote(uint proposalNumber, bool supportsProposal) external onlyValidMembers  {
			inewVote(proposalNumber, supportsProposal, msg.sender);
	}

	function newAbstentionVote(uint proposalNumber) external onlyValidMembers  {
			inewAbstentionVote(proposalNumber, msg.sender);
	}

	function executeMotion(uint proposalNumber, string voteSecretKey) external onlyCounselors  {
			iexecuteMotion(proposalNumber, voteSecretKey);
	}

	function changeVotingRules(uint minimumVoteToPassAMotion, uint minutesForDebate) external onlyCounselors  {
			ichangeVotingRules(minimumVoteToPassAMotion, minutesForDebate);
	}
	// 	******************************

	function abs_getvoteWeightOf(address who) internal view returns (uint) {
			return getvoteWeightOf(who);
	}
}
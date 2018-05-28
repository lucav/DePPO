pragma solidity 0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract PPMotions is Ownable {
  uint internal minimumQuorum;
	uint internal debatingPeriodInMinutes;
	Motion[] internal Motions;
	uint internal numMotions;

	//PPMembers private refPPMembers;

  struct Motion {
		  address MotionHolder;
			string description;
			uint votingDeadline;
			bool executed;
			bool MotionPassed;
			uint numberOfVotes;
			uint yesVotes;
			uint noVotes;
			uint abstentionVotes;
			bytes32 MotionHash;
			Vote[] votes;
			mapping (address => bool) voted;
	}

	struct Vote {
			bool inSupport;
			bool abstention;
			address voter;
			uint weight;
	}

	event MotionAdded(uint MotionID, address MotionHolder, string description);
	event Voted(uint MotionID, bool position, address voter);
	event AbstentionVoted(uint MotionID, address voter);
	event MotionTallied(uint MotionID, string MotionDescription,
		uint yesVotes, uint noVotes, uint abstentionVotes,
		uint totalVotes, bool MotionPassed);
	event ChangeOfRules(uint newMinimumQuorum, uint newDebatingPeriodInMinutes);

  /*constructor(uint minimumVoteToPassAMotion, uint minutesForDebate, address addrefPPMembers) public {
			owner = msg.sender;
			changeVotingRules(minimumVoteToPassAMotion, minutesForDebate);
			refPPMembers = PPMembers(addrefPPMembers);
  }*/

	/*function autodestroy() internal onlyOwner {
      selfdestruct(msg.sender);
  }*/

	function getMotionResult(uint MotionNumber) external view returns (bool) {
			require(MotionNumber > 0);
			Motion storage p = Motions[MotionNumber];
			require(p.executed, "Motion is not executed yet");

			return p.MotionPassed;
	}

	function getMotionVotes(uint MotionNumber) external view returns (uint) {
			require(MotionNumber > 0);
			Motion storage p = Motions[MotionNumber];
			require(p.executed, "Motion is not executed yet");

			return p.numberOfVotes;
	}

	/**
		* Add Motion
		*
		* Propose to issue a new motion
		*
		* @param voteDescription Description
		* @param voteSecretKey secret key for the Motion
		*/
	function inewMotion(string voteDescription, string voteSecretKey, address MotionHolder) internal {

			uint MotionID = Motions.length++;
			Motion storage p = Motions[MotionID];
			p.MotionHolder = MotionHolder;
			p.description = voteDescription;
			p.MotionHash = keccak256(abi.encodePacked(MotionHolder, voteSecretKey));
			p.votingDeadline = now + (debatingPeriodInMinutes * 1 minutes);
			p.executed = false;
			p.MotionPassed = false;
			p.numberOfVotes = 0;
			p.abstentionVotes = 0;
			p.noVotes = 0;
			p.yesVotes = 0;

			emit MotionAdded(MotionID, MotionHolder, voteDescription);
			numMotions = Motions.length;
	}

	/**
		* Log a vote for a Motion
		*
		* Vote `supportsMotion? in support of : against` Motion #`MotionNumber`
		*
		* @param MotionNumber number of Motion
		* @param supportsMotion either in favor or against it
		*/
	function inewVote(uint MotionNumber, bool supportsMotion, address Member)	internal {
			require(MotionNumber < numMotions);
			Motion storage p = Motions[MotionNumber];
			require(p.voted[Member] != true);

			uint voteID = p.votes.length++;
			uint voteWeight = abs_getvoteWeightOf(Member);
			p.votes[voteID] = Vote({inSupport: supportsMotion, abstention: false, voter: Member, weight: voteWeight});
			p.voted[Member] = true;
			p.numberOfVotes += voteWeight;
			if(supportsMotion){
				p.yesVotes += voteWeight;
			}else{
				p.noVotes += voteWeight;
			}

			emit Voted(MotionNumber, supportsMotion, Member);
	}

	/**
	*	Log an abstention vote for a Motion. Valid for reach the quorum needed
	*
	 */
	function inewAbstentionVote(uint MotionNumber, address Member) internal {
			require(MotionNumber < numMotions);
			Motion storage p = Motions[MotionNumber];
			require(p.voted[Member] != true);

			uint voteID = p.votes.length++;
			uint voteWeight = abs_getvoteWeightOf(Member);
			p.votes[voteID] = Vote({inSupport:false, abstention: true, voter: Member, weight: voteWeight});
			p.voted[Member] = true;
			p.numberOfVotes += voteWeight;
			p.abstentionVotes += voteWeight;

			emit AbstentionVoted(MotionNumber, Member);
	}

	/**
		* Finish vote
		*
		* Count the votes Motion #`MotionNumber` and execute it if approved
		*
		* @param MotionNumber Motion number
		* @param voteSecretKey optional: if the transaction contained a key, you need to send it
		*/
	function iexecuteMotion(uint MotionNumber, string voteSecretKey) internal {

			Motion storage p = Motions[MotionNumber];

			// If it is past the voting deadline
			// and it has not already been executed
			// and the supplied code matches the Motion...
			require(now > p.votingDeadline
			&& !p.executed
			&& checkMotionCode(MotionNumber, p.MotionHolder, voteSecretKey), "Cannot execute the motion");

			// Check if a minimum quorum has been reached
			require(p.numberOfVotes >= minimumQuorum, "Votes are under the quorum");

			// ...then tally the results
			p.executed = true;
			if (p.yesVotes > p.noVotes) {
					// Motion passed; execute the transaction
					p.MotionPassed = true;
			} else {
					// Motion failed
					p.MotionPassed = false;
			}

			// Fire Events
			emit MotionTallied(MotionNumber, p.description,
				p.yesVotes, p.noVotes, p.abstentionVotes,
				p.numberOfVotes, p.MotionPassed);
	}

	/**
		* Change voting rules
		*
		* Make so that Motions need to be discussed for at least `minutesForDebate/60` hours
		* and all voters combined must own more than `minimumVoteToPassAMotion` shares of token to be executed
		*
		* @param minimumVoteToPassAMotion Motion can pass only if the sum of yes held by all voters exceed this number
		* @param minutesForDebate the minimum amount of delay between when a Motion is made and when it can be executed
	*/
	function ichangeVotingRules(uint minimumVoteToPassAMotion, uint minutesForDebate) internal {

			if (minimumVoteToPassAMotion < 1 ) {
				minimumVoteToPassAMotion = 1;
			}
			minimumQuorum = minimumVoteToPassAMotion;
			debatingPeriodInMinutes = minutesForDebate;
			emit ChangeOfRules(minimumQuorum, debatingPeriodInMinutes);
	}

	function abs_getvoteWeightOf(address who) internal view returns (uint);

	/**
	* Check if a Motion code matches
	*
	* @param MotionNumber ID number of the Motion to query
	* @param holder who create the Motion
	* @param voteSecretKey secret key of Motion
	*/
	function checkMotionCode(uint MotionNumber, address holder, string voteSecretKey) private view returns (bool) {
			Motion storage p = Motions[MotionNumber];
			return p.MotionHash == keccak256(abi.encodePacked(holder, voteSecretKey));
	}
}
var PoliticalParty = artifacts.require("PoliticalParty.sol");

module.exports = function(deployer) {
  // 2 vote for quorum, 1 minute for debate, 100 finney for new member
  deployer.deploy(PoliticalParty, 2, 1, 100);
};

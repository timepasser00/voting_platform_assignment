var DvoteContract = artifacts.require("voting.sol");

module.exports = async function (deployer) {
  deployer.deploy(DvoteContract);
};

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const DEFAULT_CANDIDATE_NAMES = ["Raksha", "Aditya", "Arya"];
const DEFAULT_VOTING_DURATION = 60; // Duration in minutes

module.exports = buildModule("Voting", (m) => {
  // Define parameters for candidate names and voting duration
  const candidateNames = m.getParameter("candidateNames", DEFAULT_CANDIDATE_NAMES);
  const votingDuration = m.getParameter("votingDuration", DEFAULT_VOTING_DURATION);

  // Deploy the Voting contract with candidate names and voting duration
  const Voting = m.contract("Voting", [candidateNames, votingDuration], {});
  console.log("Voting contract deployed at address:", Voting.address);
  return { Voting };
});
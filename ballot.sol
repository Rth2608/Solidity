// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ballot {

    struct Voter {                     
        uint weight;
        bool voted;
        uint vote;
    }
    struct Proposal {                  
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;  
    Proposal[] public proposals;

    
    enum Phase { Init, Regs, Vote, Done }
    Phase public state = Phase.Init;

    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase, "Invalid phase");
        _;
    }

    modifier validVoter() {
        require(voters[msg.sender].weight > 0, "No right to vote");
        require(!voters[msg.sender].voted, "Already voted");
        _;
    }

    modifier onlyChair() {
        require(msg.sender == chairperson, "Only chairperson can call this.");
        _;
    }

    constructor(uint numProposals) {
        chairperson = msg.sender;
        for (uint i = 0; i < numProposals; i++) {
            proposals.push(Proposal(0));
        }
    }

    function advancePhase() public onlyChair {
        require(state != Phase.Done, "Ballot is finished");
        if (state == Phase.Init) {
            state = Phase.Regs;
        } else if (state == Phase.Regs) {
            state = Phase.Vote;
        } else if (state == Phase.Vote) {
            state = Phase.Done;
        }
    }

    function register(address voter) public onlyChair {
        require(voters[voter].weight == 0, "Already registered");
        voters[voter].weight = 1;
    }

    function vote(uint toProposal) public validVoter {
        Voter storage sender = voters[msg.sender];
        require(toProposal < proposals.length, "Invalid proposal");
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    function reqWinner() public view returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal = p;
            }
        }
    }
}
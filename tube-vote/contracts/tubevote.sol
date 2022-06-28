pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract TubeVote is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _countVotes;

    mapping(uint256 => Vote) private votes;

    event VoteNew(
        uint256 voteId,
        address admin,
        
        uint256 contentType,
        uint256 contentId,

        uint256 voteType
    );
    
    event VoteUpdate(
        uint256 voteId,

        uint256 voteType
    );
    
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct Vote {
        address admin;
        
        uint256 contentType;
        uint256 contentId;

        uint256 voteType;
    }
    
    constructor(
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createVote(uint256 contentType, uint256 contentId, uint256 voteType) public returns (uint256 voteId) {

        _countVotes.increment();
        uint256 newVoteId = _countVotes.current();

        votes[newVoteId] = Vote({
            admin: _msgSender(),
        
            contentType: contentType,
            contentId : contentId,

            voteType : voteType
        });

        voteId = newVoteId;

        emit VoteNew(newVoteId, _msgSender(), contentType, contentId, voteType);
    }

    function updateVote(uint256 voteId, uint256 voteType) public {
        // todo
    }

    function getVoteById(uint256 voteId) public view returns (address admin, uint256 contentType, uint256 contentId, uint256 voteType) {
        
        Vote memory vote = votes[voteId];

        admin = vote.admin;
        contentType = vote.contentType;
        contentId = vote.contentId;
        voteType = vote.voteType;
    }

}
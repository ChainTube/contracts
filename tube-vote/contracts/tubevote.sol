pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

interface ITubeInterface {
    function getAuthor(uint256 contentId) external returns (address author);
    function getCreator(uint256 contentId) external returns (address author);
}

contract TubeVote is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _countVotes;

    mapping(uint256 => Vote) private Votes;

    uint256 SystemCommission;
    address payable SystemWallet;
    uint256 PlatformCommission;

    event VoteSet(uint256 voteId, address indexed author, address indexed contractHash, uint256 indexed contentId, int256 voteType, uint256 voteValue);

    struct Vote {
        address author;

        address contractHash; // address of the content contract
        uint256 contentId; // content ID within the contract

        // voteType > 0 up vote
        // voteType < 0 down vote
        // voteType == 0 neutral vote?
        int256 voteType;
        uint256 voteValue;
    }

    constructor(
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        SystemCommission = 100; // 10%
        SystemWallet = payable(_msgSender());
        PlatformCommission = 200; // 20%
    }

    // Modifier for admin roles
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    function setSystemWallet(address payable systemWallet) public onlyOwner {
        SystemWallet = systemWallet;
    }

    function setComission(uint256 systemCommission, uint256 platformCommission) public onlyOwner {
        require(platformCommission + systemCommission <= 500, "excessive commission"); // no more than 50% comission

        SystemCommission = systemCommission;
        PlatformCommission = platformCommission;
    }

    // @contractHash can be the hash of the TubeContent Contract of teh hash of the TubeCOmment contract
    // @contentId the respective entry is
    // @platformWallet the wallet for the paltform comission, may be 0
    function doTransfers(address contractHash, uint256 contentId, int256 voteType, address payable platformWallet, uint256 amount) internal
    {
        address payable authorWallet = payable(ITubeInterface(contractHash).getAuthor(contentId)); // author of comment or content
        address payable creatorWallet = payable(ITubeInterface(contractHash).getCreator(contentId)); // content creator

        uint256 forSystem = SystemCommission;
        uint256 forPlatform = 0;
        if(platformWallet != payable(0))
            forPlatform = PlatformCommission;

        uint256 forAuthor = (1000 - (forSystem + forPlatform)) / 2;
        uint256 forCreator = forAuthor;

        if(voteType < 0) // down vote
        {
            if(authorWallet == creatorWallet) // down vote for the actual content
            {
                forAuthor = 0;
                forCreator = 0;
            }
            else // down vote for a comment to some content
            {
                forAuthor = 0;
                // content creator still gets some commission
            }
        }

        uint256 forPlatformVal = (amount / 1000) * forPlatform;
        uint256 forAuthorVal = (amount / 1000) * forAuthor;
        uint256 forCreatorVal = (amount / 1000) * forCreator;
        uint256 forSystemVal = amount - (forPlatformVal + forAuthorVal + forCreatorVal);

        if(forPlatformVal > 0)
            platformWallet.transfer(forPlatformVal);

        if(forAuthorVal > 0)
            authorWallet.transfer(forAuthorVal);

        if(forCreatorVal > 0)
            creatorWallet.transfer(forCreatorVal);

        SystemWallet.transfer(forSystemVal);
    }

    function castVote(address contractHash, uint256 contentId, int256 voteType, address payable platformWallet) public payable returns (uint256 voteId) {

        _countVotes.increment();
        voteId = _countVotes.current();

        Votes[voteId] = Vote({
        author: _msgSender(),

        contractHash : contractHash,
        contentId : contentId,

        voteType : voteType,
        voteValue: msg.value
        });

        doTransfers(contractHash, contentId, voteType, platformWallet, msg.value);

        emit VoteSet(voteId, _msgSender(), contractHash, contentId, voteType, msg.value);
    }

    function updateVote(uint256 voteId, int256 voteType, address payable platformWallet) public payable {

        // todo add a setting how long a vote can be updated

        Vote memory vote = Votes[voteId];
        require(vote.author == _msgSender());

        vote.voteType = voteType;
        vote.voteValue = vote.voteValue + msg.value;

        Votes[voteId] = vote;

        doTransfers(vote.contractHash, vote.contentId, voteType, platformWallet, msg.value);

        emit VoteSet(voteId, _msgSender(), vote.contractHash, vote.contentId, vote.voteType, vote.voteValue);
    }

    function getVoteById(uint256 voteId) public view returns (address author, address contractHash, uint256 contentId, int256 voteType, uint256 voteValue) {

        Vote memory vote = Votes[voteId];

        author = vote.author;
        contractHash = vote.contractHash;
        contentId = vote.contentId;
        voteType = vote.voteType;
        voteValue = vote.voteValue;
    }

    function totalVotes() public view returns (uint256 count) {
        count = _countVotes.current();
    }
}
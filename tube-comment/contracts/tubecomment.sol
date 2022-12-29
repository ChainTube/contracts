pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

interface ITubeInterface {
    function getAuthor(uint256 contentId) external returns (address author);
    function getCreator(uint256 contentId) external returns (address author);
}

contract TubeComment is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _countComments;

    mapping(uint256 => Comment) private comments;

    event CommentSet(uint256 commentId, address indexed author, address indexed contractHash, uint256 indexed contentId, uint256 replyId, string content, bool blocked);

    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct Comment {
        address author;

        address contractHash; // address of the content contract
        uint256 contentId; // content ID within the contract
        uint256 replyId; // when not 0 id of the comment within this contract this is a reply to

        string content;
        // Note: comments have no value thair value is a result of the up /down votes
        // a user is expected to upovte his own comment with the value he is willing to spent

        bool blocked;
    }

    constructor(
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createComment(address contractHash, uint256 contentId, uint256 replyId, string memory content) public returns (uint256 commentId) {

        // todo check if user has a profile and optionaly deny posting if not

        _countComments.increment();
        commentId = _countComments.current();

        comments[commentId] = Comment({
        author: _msgSender(),

        contractHash: contractHash,
        contentId : contentId,
        replyId : replyId,

        content : content,

        blocked : false
        });

        emit CommentSet(commentId, _msgSender(), contractHash, contentId, replyId, content, false);
    }

    function blockComment(uint256 commentId, bool set_block) public {
        Comment memory comment = comments[commentId];
        // only original content author can moderate comments on chain
        require(ITubeInterface(comment.contractHash).getAuthor(comment.contentId) == _msgSender());

        comment.blocked = set_block;

        emit CommentSet(commentId, comment.author, comment.contractHash, comment.contentId, comment.replyId, comment.content, set_block);
    }

    function updateComment(uint256 commentId, string memory content) public {

        Comment memory comment = comments[commentId];
        require(comment.author == _msgSender());

        comment.content = content;

        comments[commentId] = comment;

        emit CommentSet(commentId, _msgSender(), comment.contractHash, comment.contentId, comment.replyId, content, comment.blocked);
    }

    function getCommentById(uint256 commentId) public view returns (address author, address contractHash, uint256 contentId, uint256 replyId, string memory content, bool blocked) {

        Comment memory comment = comments[commentId];

        author = comment.author;
        contractHash = comment.contractHash;
        contentId = comment.contentId;
        replyId = comment.replyId;
        content = comment.content;
        blocked = comment.blocked;
    }

    // @return: returns the author of the comment
    function getAuthor(uint256 commentId) external returns (address author)
    {
        Comment memory comment = comments[commentId];

        author = comment.author;
    }

    // @return: returns the creator (author) of the content the comment is for
    function getCreator(uint256 commentId) external returns (address author)
    {
        Comment memory comment = comments[commentId];

        author = ITubeInterface(comment.contractHash).getAuthor(comment.contentId);
    }

    function totalComments() public view returns (uint256 count) {
        count = _countComments.current();
    }
}
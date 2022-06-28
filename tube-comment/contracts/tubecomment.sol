pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract TubeComment is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _countComments;

    mapping(uint256 => Comment) private comments;

    event CommentNew(
        uint256 commentId,
        address admin,
        
        uint256 contentType,
        uint256 contentId,

        string comment
    );
    
    event CommentUpdate(
        uint256 commentId,

        string comment
    );
    
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct Comment {
        address admin;
        
        uint256 contentType;
        uint256 contentId;

        string comment;
    }
    
    constructor(
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createComment(uint256 contentType, uint256 contentId, string memory text) public returns (uint256 commentId) {

        _countComments.increment();
        uint256 newCommentId = _countComments.current();

        comments[newCommentId] = Comment({
            admin: _msgSender(),
        
            contentType: contentType,
            contentId : contentId,

            comment : text
        });

        commentId = newCommentId;

        emit CommentNew(newCommentId, _msgSender(), contentType, contentId, text);
    }

    function updateComment(uint256 commentId, string memory comment) public {
        // todo
    }

    function getCommentById(uint256 commentId) public view returns (address admin, uint256 contentType, uint256 contentId, string memory text) {
        
        Comment memory comment = comments[commentId];

        admin = comment.admin;
        contentType = comment.contentType;
        contentId = comment.contentId;
        text = comment.comment;
    }

}
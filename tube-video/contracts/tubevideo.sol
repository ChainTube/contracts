pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract TubeVideo is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _countVideos;

    mapping(uint256 => Video) private videos;

    event VideoNew(
        uint256 videoId,
        address admin,
        
        string  url,
        
        string title,
        string [] tags,
        string description
    );
    
    event VideoUpdate(
        uint256 videoId,
        address admin,
        
        string  url,
        
        string title,
        string [] tags,
        string description
    );
    
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct Video {
        address admin;
        
        string  url;
        
        string title;
        string [] tags;
        string description; // can be a entire blog post
    }
    
    constructor(
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createVideo(string memory url, string memory title, string [] memory tags, string memory description) public returns (uint256 videoId) {

        _countVideos.increment();
        uint256 newVideoId = _countVideos.current();

        videos[newVideoId] = Video({
            admin: _msgSender(),
        
            url: url,
        
            title: title,
            tags: tags,
            description: description
        });

        videoId = newVideoId;

        emit VideoNew(videoId, _msgSender(), url, title, tags, description);
    }

    function updateUrl(uint256 videoId, string memory url) public {
        // todo
    }

    function updateTitle(uint256 videoId, string memory title) public {
        // todo
    }

    function updateTags(uint256 videoId, string [] memory tags) public {
        // todo
    }

    function updateDescr(uint256 videoId, string memory description) public {
        // todo
    }

    function getVideoById(uint256 videoId) public view returns (address admin, string memory url, string memory title, string [] memory tags, string memory description) {
        
        Video memory video = videos[videoId];

        admin = video.admin;
        url = video.url;
        title = video.title;
        tags = video.tags;
        description = video.description;
    }

}
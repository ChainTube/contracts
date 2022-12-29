pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract TubeContent is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _count;

    mapping(uint256 => Content) private contents;

    event ContentSet(uint256 contentId, address indexed author, string title, Pair [] video, Pair [] subs, Pair [] sound, string [] tags, string content);

    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct Pair {
        string key;
        string value;
    }

    struct Content {
        address author;

        string title;

        mapping(string => uint) video_map; // key to index
        Pair [] video;

        mapping(string => uint) subs_map; // key to index
        Pair [] subs;

        mapping(string => uint) sound_map; // key to index
        Pair [] sound;

        string [] tags;
        string content; // can be a entire blog post
    }

    constructor(
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createContent(string memory title, string memory video, string memory video_key, string [] memory tags, string memory content) public returns (uint256 contentId) {

        _count.increment();
        contentId = _count.current();

        contents[contentId].author = _msgSender();
        contents[contentId].title = title;
        contents[contentId].tags = tags;
        contents[contentId].content = content;

        contents[contentId].video.push(Pair({
        key: video_key,
        value: video
        }));
        contents[contentId].video_map[video_key] = contents[contentId].video.length;

        EmitContent(contentId);
    }

    function EmitContent(uint256 contentId) internal
    {
        emit ContentSet(contentId, _msgSender(), contents[contentId].title, contents[contentId].video, contents[contentId].subs, contents[contentId].sound, contents[contentId].tags, contents[contentId].content);
    }

    function updateTitle(uint256 contentId, string memory title) public {

        require(contents[contentId].author == _msgSender());

        contents[contentId].title = title;

        EmitContent(contentId);
    }

    function updateVideo(uint256 contentId, string memory key, string memory video) public {

        require(contents[contentId].author == _msgSender());

        uint pos = contents[contentId].video_map[key];
        if (pos == 0){
            contents[contentId].video.push(Pair({
            key: key,
            value: video
            }));
            contents[contentId].video_map[key] = contents[contentId].video.length;
        }
        else{
            contents[contentId].video[pos - 1] = Pair({
            key: key,
            value: video
            });
        }

        EmitContent(contentId);
    }

    function updateSubs(uint256 contentId, string memory key, string memory subs) public {

        require(contents[contentId].author == _msgSender());

        uint pos = contents[contentId].subs_map[key];
        if (pos == 0){
            contents[contentId].subs.push(Pair({
            key: key,
            value: subs
            }));
            contents[contentId].subs_map[key] = contents[contentId].subs.length;
        }
        else{
            contents[contentId].subs[pos - 1] = Pair({
            key: key,
            value: subs
            });
        }

        EmitContent(contentId);
    }

    function updateSound(uint256 contentId, string memory key, string memory sound) public {

        require(contents[contentId].author == _msgSender());

        uint pos = contents[contentId].sound_map[key];
        if (pos == 0){
            contents[contentId].sound.push(Pair({
            key: key,
            value: sound
            }));
            contents[contentId].sound_map[key] = contents[contentId].sound.length;
        }
        else{
            contents[contentId].sound[pos - 1] = Pair({
            key: key,
            value: sound
            });
        }

        EmitContent(contentId);
    }

    function updateTags(uint256 contentId, string [] memory tags) public {

        require(contents[contentId].author == _msgSender());

        contents[contentId].tags = tags;

        EmitContent(contentId);
    }

    function updateContent(uint256 contentId, string memory content) public {

        require(contents[contentId].author == _msgSender());

        contents[contentId].content = content;

        EmitContent(contentId);
    }

    function getContentById(uint256 contentId) public view returns (address author, string memory title, Pair [] memory video, Pair [] memory subs, Pair [] memory sound, string [] memory tags, string memory content) {

        author = contents[contentId].author;
        title = contents[contentId].title;
        video = contents[contentId].video;
        subs = contents[contentId].subs;
        sound = contents[contentId].sound;
        tags = contents[contentId].tags;
        content = contents[contentId].content;
    }

    function getAuthor(uint256 contentId) external returns (address author)
    {
        author = contents[contentId].author;
    }

    function getCreator(uint256 contentId) external returns (address author)
    {
        author = contents[contentId].author;
    }

    function totalCount() public view returns (uint256 count) {
        count = _count.current();
    }
}
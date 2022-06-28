pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract TubeProfile is AccessControl {
    using Counters for Counters.Counter;

    mapping(address => uint256) private userByAddress;
    mapping(string => uint256) private userByName;
    mapping(uint256 => User) private userById;
    

    Counters.Counter private _countUsers;

    event UserNew(
        address indexed userAddress,
        uint256 userId,
        string userName,
        string userAlias
    );

    event UserUpdate(
        address indexed userAddress,
        uint256 userId,
        string userName,
        string userAlias
    );

    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct User {
        address userAddr;
        string userName; // a-zA-Z0-9_-
        string userAlias;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createProfile(string memory userName, string memory userAlias) public returns (uint256 userId) {
        require(userByAddress[_msgSender()] == 0, "Already registered");
        require(userByName[userName] == 0, "Name already taken");
        
        // todo: filter user name for valid cahrakters
        
        _countUsers.increment();
        uint256 newUserId = _countUsers.current();

        userById[newUserId] = User({
            userAddr: _msgSender(),
            userName: userName,
            userAlias: userAlias
        });

        userByName[userName] = newUserId;
        userByAddress[_msgSender()] = newUserId;

        userId = newUserId;
        emit UserNew(_msgSender(), newUserId, userName, userAlias);
    }
    
    function updateProfile(string memory userAlias) external {
        require(userByAddress[_msgSender()] != 0, "Not Registered");

        userById[userByAddress[_msgSender()]].userAlias = userAlias;

        uint256 userId = userByAddress[_msgSender()];
        User memory user = userById[userId];

        emit UserUpdate(_msgSender(), userId, user.userName, userAlias);
    }
    
    function getUserByID(uint256 userId) public view returns (address userAddress, string memory userName, string memory userAlias) {
        User memory user = userById[userId];
        userAddress = user.userAddr;
        userName = user.userName;
        userAlias = user.userAlias;
    }
    
    function getUserByAddress(address userAddress) public view returns (uint256 userId, string memory userName, string memory userAlias) {
        userId = userByAddress[userAddress];
        User memory user = userById[userId];
        userName = user.userName;
        userAlias = user.userAlias;
    }

    function getUserByName(string memory userName) public view returns (address userAddress, uint256 userId, string memory userAlias) {
        userId = userByName[userName];
        User memory user = userById[userId];
        userAddress = user.userAddr;
        userName = user.userName;
        userAlias = user.userAlias;
    }
}
import './utils/EnumerableSet.sol';
import './utils/Address.sol';
import './GSN/Context.sol';
import './access/AccessControl.sol';
import './math/SafeMath.sol';
import './utils/Counters.sol';
import './introspection/IERC165.sol';
import './token/ERC721/IERC721.sol';
import './token/ERC721/IERC721Receiver.sol';
import './token/ERC721/ERC721Holder.sol';

import './token/BEP20/IBEP20.sol';

import './utils/SafeBEP20.sol';

pragma solidity ^0.6.0;


contract TubeProfile is AccessControl {
    using Counters for Counters.Counter;
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    mapping(address => bool) public hasRegistered;

    mapping(address => User) private users;

    Counters.Counter private _countUsers;

    event UserNew(
        address indexed userAddress
    );

    event UserUpdate(
        address indexed userAddress
    );

    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    struct User {
        uint256 userId;
    }

    constructor(
    ) public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function createProfile() external {
        require(!hasRegistered[_msgSender()], "Already registered");
        
        _countUsers.increment();
        uint256 newUserId = _countUsers.current();

        users[_msgSender()] = User({
            userId: newUserId,
        });

        hasRegistered[_msgSender()] = true;

        emit UserNew(_msgSender(), _teamId, _nftAddress, _tokenId);
    }

}
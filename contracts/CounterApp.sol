pragma solidity 0.4.18;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/zeppelin/math/SafeMath.sol";
import "@aragon/os/contracts/common/IForwarder.sol";

contract CounterApp is AragonApp {
    using SafeMath for uint256;

    /// Events
    event Increment(address indexed entity, uint256 step);
    event Decrement(address indexed entity, uint256 step);
    event NewVote(address indexed entity);
    event ExecuteVote();

    /// State
    uint256 public value;
    uint256 public goal = 10;
    bytes executionScript;

    /// ACL
    bytes32 constant public INCREMENT_ROLE = keccak256("INCREMENT_ROLE");
    bytes32 constant public DECREMENT_ROLE = keccak256("DECREMENT_ROLE");
    bytes32 constant public CREATE_VOTES_ROLE = keccak256("CREATE_VOTES_ROLE");

    function isForwarder() public pure returns (bool) {
        return true;
    }

    /**
    * @notice Creates a vote to execute the desired action, and casts a support vote
    * @dev IForwarder interface conformance
    * @param _evmScript Start vote with script
    */
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript));
        _newVote(_evmScript);
    }

    function canForward(address _sender, bytes _evmCallScript) public view returns (bool) {
        return canPerform(_sender, CREATE_VOTES_ROLE, arr());
    }

    function _newVote(bytes _executionScript) internal returns (bool) {
        executionScript = _executionScript;

        value = 0; // Reset the count

        NewVote(msg.sender);

        return true;
    }

    /**
     * @notice Increment the counter by `step`
     * @param step Amount to increment by
     */
    function increment(uint256 step) auth(INCREMENT_ROLE) external {
        value = value.add(step);
        Increment(msg.sender, step);

        if(value >= goal) {
            _executeVote();
        }
    }

    function _executeVote() internal {
        bytes memory input = new bytes(0);
        runScript(executionScript, input, new address[](0));
        ExecuteVote();
    }

    /**
     * @notice Decrement the counter by `step`
     * @param step Amount to decrement by
     */
    function decrement(uint256 step) auth(DECREMENT_ROLE) external {
        value = value.sub(step);
        Decrement(msg.sender, step);
    }
}

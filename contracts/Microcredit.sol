pragma solidity ^0.5.12;

import "./Utils.sol";
import "./IMicrocredit.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Microcredit is IMicrocredit, Ownable {
    using SafeMath for uint256;

    mapping(address => mapping(bytes32 => bool)) public requests;
    mapping(address => mapping(bytes32 => uint256)) public debts;

    constructor() public {}

    function() external payable {}

    function request(
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external onlyOwner returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(this, amount, expires, nonce)
        );

        requests[user][hash] = true;

        emit Request(user, amount, expires, nonce, sig, hash);

        return true;
    }

    function approve(
        uint256 approveAmount,
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external onlyOwner returns (bool) {
        require(expires >= block.number, "Request is expired");

        bytes32 hash = keccak256(
            abi.encodePacked(this, amount, expires, nonce)
        );

        require(Utils.checkSig(user, hash, sig), "Ivalid sig");

        if (Utils.checkSig(user, hash, sig)) {
            debts[user][hash] = approveAmount;

            emit Approve(user, amount, expires, nonce, sig, hash);

            return true;
        }

        return false;
    }

    function cancel(
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external onlyOwner returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(this, amount, expires, nonce)
        );

        require(debts[user][hash] == 0, "The user has a debt");

        require(Utils.checkSig(user, hash, sig), "Not request owner");

        requests[user][hash] = false;

        emit Cancel(user, amount, expires, nonce, sig, hash);

        return true;
    }

    function refund(
        uint256 ramount,
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce
    ) external onlyOwner returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(this, amount, expires, nonce)
        );

        if (debts[user][hash] != 0) {
            debts[user][hash] = debts[user][hash].sub(ramount);

            return true;
        }

        return false;
    }

    function withdraw() external onlyOwner returns (bool) {
        msg.sender.transfer(address(this).balance);

        return true;
    }
}

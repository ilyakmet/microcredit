pragma solidity ^0.5.12;

import "./IMicrocredit.sol";
import "./NameRegistry.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract ProxyMicrocredit is Ownable, NameRegistry {
    address public contractAddress;
    uint16 public version;

    IMicrocredit MicrocreditInstance;

    function setInstance(string calldata name) external returns (uint16) {
        bytes32 hash = keccak256(abi.encodePacked(name));

        (address instanceAddress, uint16 instanceVersion) = NameRegistry
            .getContractInfo(hash);

        MicrocreditInstance = IMicrocredit(instanceAddress);

        contractAddress = instanceAddress;
        version = instanceVersion;

        return instanceVersion;
    }

    function request(
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external returns (bool) {
        return
            MicrocreditInstance.request(
                msg.sender,
                amount,
                expires,
                nonce,
                sig
            );
    }

    function approve(
        address payable user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external payable onlyOwner returns (bool) {
        bool isComplete = MicrocreditInstance.approve(
            msg.value,
            user,
            amount,
            expires,
            nonce,
            sig
        );

        if (isComplete) {
            user.transfer(msg.value);
        }

        return true;
    }

    function cancel(
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external returns (bool) {
        return
            MicrocreditInstance.cancel(msg.sender, amount, expires, nonce, sig);
    }

    function refund(
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce
    ) external payable returns (bool) {
        return
            MicrocreditInstance.refund(msg.value, user, amount, expires, nonce);
    }

    function withdraw() external onlyOwner returns (bool) {
        msg.sender.transfer(address(this).balance);

        return true;
    }
}

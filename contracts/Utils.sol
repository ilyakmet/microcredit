pragma solidity ^0.5.12;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";

library Utils {
    using ECDSA for bytes32;

    function checkSig(address user, bytes32 hash, bytes memory sig)
        internal
        pure
        returns (bool)
    {
        return hash.toEthSignedMessageHash().recover(sig) == user;
    }
}

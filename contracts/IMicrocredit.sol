pragma solidity ^0.5.12;

interface IMicrocredit {
    event Request(
        address indexed user,
        uint256 indexed amount,
        uint256 expires,
        uint256 nonce,
        bytes sig,
        bytes32 hash
    );
    event Approve(
        address indexed user,
        uint256 indexed amount,
        uint256 expires,
        uint256 nonce,
        bytes sig,
        bytes32 hash
    );
    event Cancel(
        address indexed user,
        uint256 indexed amount,
        uint256 expires,
        uint256 nonce,
        bytes sig,
        bytes32 hash
    );

    function request(
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external returns (bool);

    function approve(
        uint256 approveAmount,
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external returns (bool);

    function cancel(
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce,
        bytes calldata sig
    ) external returns (bool);

    function refund(
        uint256 ramount,
        address user,
        uint256 amount,
        uint256 expires,
        uint256 nonce
    ) external returns (bool);

    function withdraw() external returns (bool);
}

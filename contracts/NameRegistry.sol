pragma solidity ^0.5.12;

/**
 * Creates a registry for contracts
 **/
contract NameRegistry {
    // Manages info about the contract instance
    struct ContractInfo {
        address owner;
        address contractInst;
        uint16 version;
    }

    // Manages the name to address mapping
    mapping(bytes32 => ContractInfo) nameInfo;

    // Adds the version of the contract to be used by apps
    function registerName(string calldata name, address conAddress, uint16 ver)
        external
        returns (bool)
    {
        // Version MUST start with number 1
        require(ver >= 1, "Version < 1!");

        bytes32 hash = keccak256(abi.encodePacked(name));

        if (nameInfo[hash].contractInst == address(0x0)) {
            nameInfo[hash].owner = msg.sender;
            nameInfo[hash].contractInst = conAddress;
            nameInfo[hash].version = ver;
        } else {
            require(
                nameInfo[hash].owner == msg.sender,
                "Only owner have an access!"
            );
            nameInfo[hash].contractInst = conAddress;
            nameInfo[hash].version = ver;
        }
        return true;
    }

    // Contracts having a dependency on this contract will invoke this function
    function getContractInfo(bytes32 name)
        public
        view
        returns (address, uint16)
    {
        return (nameInfo[name].contractInst, nameInfo[name].version);
    }

    function removeContract(string calldata name) external returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(name));
        require(
            nameInfo[hash].owner == msg.sender,
            "Only owner have an access!"
        );
        delete nameInfo[hash];
        return true;
    }

}

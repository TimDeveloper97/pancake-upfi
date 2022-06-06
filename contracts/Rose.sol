// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Rose is ERC20 {
    constructor() ERC20("Rose - testnet", "Rose") {
        _mint(msg.sender, 100000);
    }
}

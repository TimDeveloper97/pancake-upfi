// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Upo is ERC20 {
    constructor() ERC20("Upo - testnet", "Upo") {
        _mint(msg.sender, 100000);
    }
}

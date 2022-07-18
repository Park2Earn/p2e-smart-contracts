// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GooddeedToken is ERC20 {
    constructor()ERC20("GooddeedToken", "GDT"){
        _mint(msg.sender, 1000);
    }
}
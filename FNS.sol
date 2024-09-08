// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FNSToken is ERC20, Ownable {
    uint256 private constant TOTAL_SUPPLY = 10_000_000 * 10**18;

    constructor(address initialOwner) 
        ERC20("Fan Network System", "FNS") 
        Ownable(initialOwner)
    {
        _mint(initialOwner, TOTAL_SUPPLY);
    }
}
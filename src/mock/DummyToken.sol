// DummyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DummyToken is ERC20, Ownable {
    constructor() ERC20("Dummy Token", "DUMMY") Ownable(msg.sender) {
        // Mint 25 million tokens (enough for ~30 days with 100 tokens/block)
        _mint(msg.sender, 25_000_000 * 10 ** decimals());
    }
}

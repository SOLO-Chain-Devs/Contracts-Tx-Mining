// DummyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SOLOToken is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init("SOLO Token", "SOLO");
        __Ownable_init(msg.sender);
    }
    
    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function mintTo(address recepient, uint256 amount) public {
        _mint(recepient, amount);
    }
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GasRefund is Ownable {
   IERC20 public token;
   uint256 public blockReward;
   uint256 public runwayBlocks;
   uint256 public latestClaimableBlock;
   uint256 public epochDuration;

   struct UserClaim {
       uint256 lastClaimedBlock;
       uint256 totalClaimAmount;
       uint256 pendingClaimAmount;
       uint256[] claimedBlocks;
       mapping(uint256 => uint256) blockClaimAmounts;
   }

   mapping(address => UserClaim) public userClaims;

   constructor(address _token, uint256 _blockReward, uint256 _epochDuration) Ownable(msg.sender) {
        token = IERC20(_token);
        blockReward = _blockReward;
        epochDuration = _epochDuration;
    }

   function setBlockReward(uint256 _blockReward) external onlyOwner {
       blockReward = _blockReward;
   }

   function setEpochDuration(uint256 _epochDuration) external onlyOwner {
       epochDuration = _epochDuration;
   }

   function updateLatestClaimableBlock(uint256 _block) external onlyOwner {
       require(_block > latestClaimableBlock, "New block number must be greater than the current latest claimable block");
       latestClaimableBlock = _block;
   }

   function updateUserClaim(address _user, uint256[] memory _blocks, uint256[] memory _amounts) external onlyOwner {
       require(_blocks.length == _amounts.length, "Blocks and amounts arrays must have the same length");

       UserClaim storage claim = userClaims[_user];
       for (uint256 i = 0; i < _blocks.length; i++) {
           uint256 blockID = _blocks[i];
           uint256 amount = _amounts[i];

           if (claim.blockClaimAmounts[blockID] == 0) {
               claim.claimedBlocks.push(blockID);
           }
           claim.blockClaimAmounts[blockID] = amount;
           claim.pendingClaimAmount += amount;
       }
       claim.totalClaimAmount += claim.pendingClaimAmount;
   }

   function claimRewards() external {
       UserClaim storage claim = userClaims[msg.sender];
       require(claim.lastClaimedBlock < latestClaimableBlock, "No new rewards to claim");
       require(claim.pendingClaimAmount > 0, "No pending rewards to claim for the user");

       uint256 reward = claim.pendingClaimAmount;
       claim.pendingClaimAmount = 0;
       claim.lastClaimedBlock = latestClaimableBlock;

       token.transfer(msg.sender, reward);
   }

   function getRunway() external view returns (uint256) {
       return token.balanceOf(address(this)) / blockReward;
   }

   function getPendingClaimAmount(address _user) external view returns (uint256) {
       UserClaim storage claim = userClaims[_user];
       return claim.pendingClaimAmount;
   }

   function getTotalClaimAmount(address _user) external view returns (uint256) {
       UserClaim storage claim = userClaims[_user];
       return claim.totalClaimAmount;
   }

   function getLastClaimedBlock(address _user) external view returns (uint256) {
       UserClaim storage claim = userClaims[_user];
       return claim.lastClaimedBlock;
   }

   function getCurrentEpoch() external view returns (uint256) {
       return block.number / epochDuration;
   }

   function getBlockClaimAmount(address _user, uint256 _block) external view returns (uint256) {
       UserClaim storage claim = userClaims[_user];
       return claim.blockClaimAmounts[_block];
   }

   function getClaimedBlocks(address _user) external view returns (uint256[] memory) {
       UserClaim storage claim = userClaims[_user];
       return claim.claimedBlocks;
   }
}

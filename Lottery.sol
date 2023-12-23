//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Lottery {
    address tokenContract;
    address[] public players;
    address public owner;
    uint256 public lotteryEndTime;
    uint256 ticketPrice;

    mapping (address => uint256) participants;

    event Successful (address participant, uint256 amount, uint256 time);
    event LotteryEnded(address winner, uint256 prize);

    constructor(address _tokenContract, uint256 _lotteryDuration, uint256 _ticketPrice ) {
        tokenContract= _tokenContract;
        owner = msg.sender;
        lotteryEndTime = block.timestamp + _lotteryDuration;
        ticketPrice= _ticketPrice;
    }

    function participate (uint256 _amount) external {
        require(_amount == ticketPrice, "not ticket price");
        require(IERC20(tokenContract).balanceOf(msg.sender) >= ticketPrice, "insufficient balance");

        IERC20(tokenContract).transferFrom(msg.sender, address(this), _amount);
        players.push(msg.sender);

        participants[msg.sender] ++;

        emit Successful (msg.sender, _amount, block.timestamp);
    }

    function generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    function endLottery () external {
        require (players.length > 0, "no participants");
        require (block.timestamp == lotteryEndTime, "lottery not ended");

        uint256 winnerIndex = generateRandomNumber() % players.length;
        address winner = players[winnerIndex];


        uint256 prize = IERC20(tokenContract).balanceOf(address(this));
        IERC20(tokenContract).transfer(winner, prize);

        emit LotteryEnded(winner, prize);

    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }
}
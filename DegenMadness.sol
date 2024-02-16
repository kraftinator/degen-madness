// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DegenMadness is ERC721, ReentrancyGuard, Ownable {
    constructor(address initialOwner)
        ERC721("Degen Madness", "DMAD")
        Ownable(initialOwner)
    {}

    struct Brackets {
        uint256[7] games;
    }

    mapping(uint256 => Brackets) private tokenBrackets;
    bool public pauseMinting = false;
    uint256 public totalSupply = 0;
    uint256 public maxSupply = 5;
    uint256 public mintDeadline = 1710651600; // Midnight March 17, 2024 Central Daylight Time

    function mintBracket(uint256[7] calldata games) external nonReentrant {
        require(pauseMinting == false, "Minting is currently paused");
        require(block.timestamp < mintDeadline, "Minting period has ended");
        require(totalSupply < maxSupply, "Max supply reached");
        validateBracket(games);

        totalSupply += 1; // Increment the total supply
        uint256 tokenId = totalSupply; // Use totalSupply as the new tokenId

        _safeMint(msg.sender, tokenId);
        tokenBrackets[tokenId] = Brackets(games);
    }

    function validateBracket(uint256[7] calldata games) internal pure {
        // First Round
        require(games[0] == 0 || games[0] == 1, "Invalid winner for game 1");
        require(games[1] == 2 || games[1] == 3, "Invalid winner for game 2");
        require(games[2] == 4 || games[2] == 5, "Invalid winner for game 3");
        require(games[3] == 6 || games[3] == 7, "Invalid winner for game 4");
        // Semifinals
        require(games[4] == games[0] || games[4] == games[1], "Invalid winner for semifinal 1");
        require(games[5] == games[2] || games[5] == games[3], "Invalid winner for semifinal 2");
        // Championship
        require(games[6] == games[4] || games[6] == games[5], "Invalid winner for the final");
    }

    function getBracket(uint256 tokenId) public view returns (Brackets memory) {
        //require(ownerOf(tokenId) != address(0), "Token does not exist.");
        return tokenBrackets[tokenId];
    }

    function setMintDeadline(uint256 _newDeadline) external onlyOwner {
        mintDeadline = _newDeadline;
    }

    function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
        maxSupply = newMaxSupply;
    }

    function enableMinting() public onlyOwner {
        pauseMinting = false;
    }

    function disableMinting() public onlyOwner {
        pauseMinting = true;
    }
}

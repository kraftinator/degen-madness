// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract DegenMadness is ERC721, ReentrancyGuard, Ownable {
    using Strings for uint256;
    using StringUtils for uint256;

    constructor(address initialOwner)
        ERC721("Degen Madness", "DMAD")
        Ownable(initialOwner)
    {
        for(uint256 i = 0; i < winners.length; i++) {
            winners[i] = NULL;
        }
    }

    struct Brackets {
        uint8[7] games;
        bool hasClaimed;
    }

    mapping(uint256 => Brackets) private tokenBrackets;

    //struct WinningBracketsStruct {
    //    uint256 tokenId;
    //    bool hasClaimed;
    //}

    //mapping(uint256 => WinningBracketsStruct) public winningBrackets;

    bool public pauseMinting = false;
    uint256 public totalSupply = 0;
    uint256 public maxSupply = 5;
    uint256 public mintDeadline = 1710651600; // Midnight March 17, 2024 Central Daylight Time
    
    uint256 public highestScore = 0;
    uint256 public winningBracketCount = 0;

    string[] private teams = [
        "Kansas",
        "Oregon St",
        "Iowa",
        "Florida",
        "Gonzaga",
        "Pittsburgh",
        "Portland St",
        "UCLA"
    ];

    uint256[7] private winners;
    uint256 private constant NULL = type(uint256).max;
    uint256 public mintFee = 0.01 ether;

    function mintBracket(uint8[7] calldata games) external nonReentrant payable {
        require(msg.value >= mintFee, "Insufficient payment"); // Check if the caller sent enough ether
        require(pauseMinting == false, "Minting is currently paused");
        //require(block.timestamp < mintDeadline, "Minting period has ended");
        require(totalSupply < maxSupply, "Max supply reached");
        validateBracket(games);

        totalSupply += 1; // Increment the total supply
        uint256 tokenId = totalSupply; // Use totalSupply as the new tokenId

        _safeMint(msg.sender, tokenId);
        tokenBrackets[tokenId] = Brackets(games, false);
    }

    function withdrawMintFees() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawWinnings(uint256 tokenId) external {
        uint256 score = getScore(tokenId);
        if (score == highestScore && tokenBrackets[tokenId].hasClaimed == false) {
            uint256 amountToSend = address(this).balance / winningBracketCount;
            address owner = ownerOf(tokenId);
            payable(owner).transfer(amountToSend);
            tokenBrackets[tokenId].hasClaimed = true;
        }
    }

/*
    function withdrawWinnings() external {
        // can caller withdraw?
        uint256 tokenCount = balanceOf(msg.sender);
        require(tokenCount > 0, "Caller does not own any tokens");
        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(msg.sender, i);
            // Your logic here for each tokenId
        }

        uint256 contractBalance = address(this).balance;
        uint256 amountToSend = contractBalance / 2;
        payable(msg.sender).transfer(amountToSend);
    }
*/
  
    function validateBracket(uint8[7] calldata games) internal pure {
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

    // Make private
    function setWinner(uint256 index, uint256 winnerId) external onlyOwner {
        require(index < winners.length, "Index out of bounds.");
        winners[index] = winnerId;
    }

    // Make private
    function setWinners(uint256[7] calldata newWinners) external onlyOwner {
        winners = newWinners;
    }
/*
    function getWinners() public view returns (uint256[] memory) {
        uint256[] memory copyWinners = new uint256[](winners.length);
        for (uint256 i = 0; i < winners.length; i++) {
            copyWinners[i] = winners[i];
        }
        return copyWinners;
    }
*/
    function getWinner(uint256 index) public view returns (uint256) {
        require(index < winners.length, "Index out of bounds.");
        return winners[index];
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
/*
    function getRankings() public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](totalSupply);
        uint256[] memory scores = new uint256[](totalSupply);

        for (uint256 i = 1; i <= totalSupply; i++) {
            uint256 tokenId = i;
            tokenIds[i - 1] = tokenId;
            scores[i - 1] = getScore(tokenId);
        }

        return (tokenIds, scores);
    }
*/

/*
    function getHighestScoreBrackets() public view returns (uint256[] memory, uint256) {
        require(totalSupply > 0, "No brackets minted yet");

        uint256 highestScore = 0;
        uint256[] memory highestScoreTokenIds = new uint256[](totalSupply); // Initialize with maximum possible size
        uint256 count = 0;

        for (uint256 i = 1; i <= totalSupply; i++) {
            uint256 tokenId = i;
            uint256 score = getScore(tokenId);
            if (score > highestScore) {
                highestScore = score;
                count = 0; // Reset count for new highest score
                highestScoreTokenIds[count++] = tokenId;
            } else if (score == highestScore) {
                highestScoreTokenIds[count++] = tokenId;
            }
        }

        // Trim array to remove any unused elements
        uint256[] memory trimmedTokenIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            trimmedTokenIds[i] = highestScoreTokenIds[i];
        }

        return (trimmedTokenIds, highestScore);
    }
*/
/*
    function getHighestScore() public view returns (uint256) {
        uint256 highestScore = 0;
        for (uint256 i = 1; i <= totalSupply; i++) {
            uint256 tokenId = i;
            uint256 score = getScore(tokenId);
            if (score > highestScore) {
                highestScore = score;
            }
        }
        return highestScore;
    }
*/
    function setHighestScore() external onlyOwner {
        uint256 newHighScore = 0;
        for (uint256 i = 1; i <= totalSupply; i++) {
            uint256 tokenId = i;
            uint256 score = getScore(tokenId);
            if (score > newHighScore) {
                newHighScore = score;
            }
        }
        highestScore = newHighScore;
    }

    function setWinningBracketCount() external onlyOwner {
        uint256 count = 0;
        for (uint256 i = 1; i <= totalSupply; i++) {
            uint256 tokenId = i;
            uint256 score = getScore(tokenId);
            if (score == highestScore) {
                count++;
            }
        }
        winningBracketCount = count;
    }
/*
    function setWinningBrackets() external onlyOwner {
        require(totalSupply > 0, "No brackets minted yet");

        uint256 highestScore = getHighestScore();
        uint256 count = 0;
        for (uint256 i = 1; i <= totalSupply; i++) {
            uint256 tokenId = i;
            uint256 score = getScore(tokenId);
            if (score == highestScore) {
                winningBrackets[count++] = WinningBracketsStruct(tokenId, false);
            }
        }
    
    }
*/


    function getScore(uint256 tokenId) public view returns (uint256) {
        Brackets storage bracket = tokenBrackets[tokenId];
        uint256 score = 0;
        for (uint256 i = 0; i < winners.length; i++) {
            if (winners[i] == bracket.games[i]) {
                if (i <= 3) { 
                    score += 1;
                } else if (i <= 5) { 
                    score += 2;
                } else { 
                    score += 4;
                }    
            }
        }
        return score;
    }

    function isEliminated(uint8 pick) public view returns (bool) {
        // Round 1
        uint8 firstGame = uint8(pick / 2);
        if (winners[firstGame] == NULL) {
            return false;
        }
        // Round 2
        uint8 secondGame = uint8((pick / 4) + (teams.length / 2));
        if (winners[firstGame] == pick && winners[secondGame] == NULL) {
            return false;
        }
        // Final
        if (winners[firstGame] == pick && winners[secondGame] == pick && winners[6] == NULL) {
            return false;
        }
        return true;
    }

    function getFillColor(uint8 pick, uint256 index) public view returns (string memory) {
        if (winners[index] == NULL) {
            if (isEliminated(pick)) {
                return "pink";
            }
            return "lightgray";
        } 
        if (winners[index] == pick) {
            return "lightgreen";
        }
        return "pink";
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        Brackets storage bracket = tokenBrackets[tokenId];
        string[] memory parts = new string[](40);

        parts[0] = '<svg width="800" height="450" xmlns="http://www.w3.org/2000/svg">';
        parts[1] = '<style>text { font-family: \'Arial\', sans-serif; font-size: 16px; }</style>';
        parts[2] = getRectangle(5, 38, "lightgrey");
        parts[3] = getRectangle(5, 62, "lightgrey");
        parts[4] = getRectangle(5, 98, "lightgrey");
        parts[5] = getRectangle(5, 122, "lightgrey");
        parts[6] = getRectangle(5, 158, "lightgrey");
        parts[7] = getRectangle(5, 182, "lightgrey");
        parts[8] = getRectangle(5, 218, "lightgrey");
        parts[9] = getRectangle(5, 242, "lightgrey");

        parts[10] = string.concat('<text x="10" y="57">', teams[0], '</text>'); 
        parts[11] = string.concat('<text x="10" y="81">', teams[1], '</text>'); 
        parts[12] = string.concat('<text x="10" y="117">', teams[2], '</text>');
        parts[13] = string.concat('<text x="10" y="141">', teams[3], '</text>');
        parts[14] = string.concat('<text x="10" y="177">', teams[4], '</text>'); 
        parts[15] = string.concat('<text x="10" y="201">', teams[5], '</text>');
        parts[16] = string.concat('<text x="10" y="237">', teams[6], '</text>');
        parts[17] = string.concat('<text x="10" y="261">', teams[7], '</text>'); 

        // 2nd Round
        // Game 0 Winner
        parts[18] = getRectangle(210, 68, getFillColor(bracket.games[0], 0));
        parts[19] = string.concat('<text x="215" y="86">', teams[bracket.games[0]], '</text>');
        
        // Game 1 Winner
        parts[20] = getRectangle(210, 92, getFillColor(bracket.games[1], 1));
        parts[21] = string.concat('<text x="215" y="110">', teams[bracket.games[1]], '</text>'); 

        // Game 2 Winner
        parts[22] = getRectangle(210, 188, getFillColor(bracket.games[2], 2));
        parts[23] = string.concat('<text x="215" y="206">', teams[bracket.games[2]], '</text>'); 

        // Game 3 Winner
        parts[24] = getRectangle(210, 212, getFillColor(bracket.games[3], 3));
        parts[25] = string.concat('<text x="215" y="230">', teams[bracket.games[3]], '</text>'); 

        parts[26] = '<path d="M 145,62 H 175 V 92 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[27] = '<path d="M 145,122 H 175 V 92 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[28] = '<path d="M 145,182 H 175 V 212 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[29] = '<path d="M 145,242 H 175 V 212 H 209" stroke="black" stroke-width="2" fill="none"/>';

        // 3rd Round
        // Game 4 Winner
        parts[30] = getRectangle(415, 130, getFillColor(bracket.games[4], 4));
        parts[31] = string.concat('<text x="420" y="148">', teams[bracket.games[4]], '</text>');
        
        // Game 5 Winner
        parts[32] = getRectangle(415, 154, getFillColor(bracket.games[5], 5));
        parts[33] = string.concat('<text x="420" y="172">', teams[bracket.games[5]], '</text>');
        
        parts[34] = '<path d="M 350,92 H 380 V 154 H 415" stroke="black" stroke-width="2" fill="none"/>';
        parts[35] = '<path d="M 350,212 H 380 V 154 H 415" stroke="black" stroke-width="2" fill="none"/>';

        // Game 6 Winner
        parts[36] = getRectangle(630, 142, getFillColor(bracket.games[6], 6));
        parts[37] = string.concat('<text x="635" y="160">', teams[bracket.games[6]], '</text>'); // Oregon (Final)
        
        parts[38] = '<line x1="555" y1="154" x2="630" y2="154" stroke="black" stroke-width="2"/>';
        parts[39] = '</svg>';

        string memory svgBytes;
        for (uint i = 0; i < parts.length; i++) {
            svgBytes = string.concat(svgBytes, parts[i]);
        }

        string memory output = string(svgBytes);
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Bag #', StringUtils.toString(tokenId), '", "description": "Degen Madness!", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function getRectangle(uint x, uint y, string memory fill) internal pure returns (string memory) {
        return string(abi.encodePacked('<rect x="', StringUtils.toString(x), '" y="', StringUtils.toString(y), '" width="140" height="24" stroke="black" fill="', fill, '"/>'));
    }

}

library StringUtils {
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}


/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract DegenMadness is ERC721, ReentrancyGuard, Ownable {
    using Strings for uint256;

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

    function tokenURI(uint256 tokenId) override public view returns (string memory) {

        //string[3] memory parts;
        //parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        //parts[1] = 'Hello, world!';
        //parts[2] = '</text></svg>';
        //string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));

        Brackets storage bracket = tokenBrackets[tokenId];
        string[] memory parts = new string[](40);

        parts[0] = '<svg width="800" height="450" xmlns="http://www.w3.org/2000/svg">';
        parts[1] = '<style>text { font-family: \'Arial\', sans-serif; font-size: 16px; }</style>';
        parts[2] = '<rect x="5" y="38" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[3] = '<rect x="5" y="62" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[4] = '<rect x="5" y="98" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[5] = '<rect x="5" y="122" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[6] = '<rect x="5" y="158" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[7] = '<rect x="5" y="182" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[8] = '<rect x="5" y="218" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[9] = '<rect x="5" y="242" width="140" height="24" fill="lightgrey" stroke="black"/>';

        // Dynamically setting team names using the teams array
        parts[10] = string.concat('<text x="10" y="57">', teams[0], '</text>'); // Kansas
        parts[11] = string.concat('<text x="10" y="81">', teams[1], '</text>'); // Oregon
        parts[12] = string.concat('<text x="10" y="117">', teams[2], '</text>'); // Iowa
        parts[13] = string.concat('<text x="10" y="141">', teams[3], '</text>'); // Florida
        parts[14] = string.concat('<text x="10" y="177">', teams[4], '</text>'); // Gonzaga
        parts[15] = string.concat('<text x="10" y="201">', teams[5], '</text>'); // Pittsburgh
        parts[16] = string.concat('<text x="10" y="237">', teams[6], '</text>'); // Portland St
        parts[17] = string.concat('<text x="10" y="261">', teams[7], '</text>'); // UCLA

        // Continuing with the rest of the SVG parts
        parts[18] = '<rect x="210" y="68" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[19] = '<rect x="210" y="92" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[20] = string.concat('<text x="215" y="86">', teams[bracket.games[0]], '</text>'); // Oregon (Round 2)
        parts[21] = string.concat('<text x="215" y="110">', teams[bracket.games[1]], '</text>'); // Iowa (Round 2)
        parts[22] = '<rect x="210" y="188" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[23] = '<rect x="210" y="212" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[24] = string.concat('<text x="215" y="206">', teams[bracket.games[2]], '</text>'); // Gonzaga (Round 2)
        parts[25] = string.concat('<text x="215" y="230">', teams[bracket.games[3]], '</text>'); // UCLA (Round 2)
        // The rest of the parts are unchanged and do not include team names
        parts[26] = '<path d="M 145,62 H 175 V 92 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[27] = '<path d="M 145,122 H 175 V 92 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[28] = '<path d="M 145,182 H 175 V 212 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[29] = '<path d="M 145,242 H 175 V 212 H 209" stroke="black" stroke-width="2" fill="none"/>';
        parts[30] = '<rect x="415" y="130" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[31] = '<rect x="415" y="154" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[32] = string.concat('<text x="420" y="148">', teams[bracket.games[4]], '</text>'); // Oregon (Semi-Finals)
        parts[33] = string.concat('<text x="420" y="172">', teams[bracket.games[5]], '</text>'); // UCLA (Semi-Finals)
        parts[34] = '<path d="M 350,92 H 380 V 154 H 415" stroke="black" stroke-width="2" fill="none"/>';
        parts[35] = '<path d="M 350,212 H 380 V 154 H 415" stroke="black" stroke-width="2" fill="none"/>';
        parts[36] = '<rect x="630" y="142" width="140" height="24" fill="lightgrey" stroke="black"/>';
        parts[37] = string.concat('<text x="635" y="160">', teams[bracket.games[6]], '</text>'); // Oregon (Final)
        parts[38] = '<line x1="555" y1="154" x2="630" y2="154" stroke="black" stroke-width="2"/>';
        parts[39] = '</svg>';



        bytes memory svgBytes;
        for (uint i = 0; i < parts.length; i++) {
            svgBytes = abi.encodePacked(svgBytes, parts[i]);
        }
        //return string(svgBytes);


        //string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));
        //string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));
        string memory output = string(svgBytes);

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Bag #', toString(tokenId), '", "description": "Loot is randomized adventurer gear generated and stored on chain. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use Loot in any way you want.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

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

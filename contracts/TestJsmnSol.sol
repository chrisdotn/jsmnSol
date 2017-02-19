pragma solidity ^0.4.2;

import "./JsmnSol.sol";

contract TestJsmnSol {

    event TokenInfo(JsmnSol.JsmnType jsmnType, uint start, uint end, uint8 size);
    event InfoEvent(bytes msg);

    function parse(string json, uint len) {
        var (success, tokens, actualNum) = JsmnSol.parse(json, len);

        if (success) {
            getAllTokens(tokens, actualNum);
        }

        if (success && actualNum > 28) {
            // FIXME Use substring instead
            InfoEvent(getBytes(json, tokens[25].start, tokens[25].end));
        }

    }

    function getBytes(string json, uint from, uint to) returns (bytes) {
        bytes memory s = bytes(json);
        bytes memory result = new bytes(to-from);
        for (uint i=from; i<to; i++) {
            result[i-from] = s[i];
        }
        return result;
    }

    function getAllTokens(JsmnSol.Token[] tokens, uint len) internal {
        for (uint i=0; i<len; i++) {
            JsmnSol.Token memory t = tokens[i];
            TokenInfo(t.jsmnType, t.start, t.end, t.size);
        }
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}

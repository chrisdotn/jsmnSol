pragma solidity ^0.4.2;

import "./JsmnSol.sol";

contract TestJsmnSol {

    event TokenInfo(JsmnSol.JsmnType jsmnType, uint start, uint end, uint8 size);
    event InfoEvent(string key, string value);
    event Debug(uint to, uint from, uint i, bytes c);

    function parse(string json, uint len) {
        var (success, tokens, actualNum) = JsmnSol.parse(json, len);

        if (success) {
            getAllTokens(tokens, actualNum);
        }

        printKeyVal(tokens, json, 27);
        printKeyVal(tokens, json, 29);
        printKeyVal(tokens, json, 33);
        printKeyVal(tokens, json, 35);
    }

    function printKeyVal(JsmnSol.Token[] t, string s, uint i) internal {
        if (i+1<t.length) {
            JsmnSol.Token memory t_key = t[i];
            JsmnSol.Token memory t_val = t[i+1];
            string memory key = JsmnSol.getBytes(s, t_key.start, t_key.end);
            string memory value = JsmnSol.getBytes(s, t_val.start, t_val.end);
            InfoEvent(key, value);
        }
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

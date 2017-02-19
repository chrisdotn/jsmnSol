pragma solidity ^0.4.2;

import "./JsmnSol.sol";

contract TestJsmnSol {

    event TokenInfo(JsmnSol.JsmnType jsmnType, uint start, uint end, uint8 size);

    function parse(string json, uint len) {
        var (success, tokens, actualNum) = JsmnSol.jsmnParse(json, len);
        //JsmnToken[] memory tokens = jsmnParse(json, len);

        if (success) {
            getAllTokens(tokens, actualNum);
        }
    }

    function getAllTokens(JsmnSol.JsmnToken[] tokens, uint len) internal {
        for (uint i=0; i<len; i++) {
            JsmnSol.JsmnToken memory t = tokens[i];
            TokenInfo(t.jsmnType, t.start, t.end, t.size);
        }
    }
}

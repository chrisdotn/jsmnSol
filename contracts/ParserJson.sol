pragma solidity ^0.4.5;

import "./JsmnSolLib.sol";

contract ParserJson {

    function parse(string json, uint len) returns (bool, uint) {

        var (success, tokens, actualNum) = JsmnSolLib.parse(json, len);
        return (success, actualNum);
    }

}

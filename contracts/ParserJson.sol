pragma solidity ^0.4.5;

import "./JsmnSolLib.sol";

contract ParserJson {

    event Result(bool success, uint actualNum);
    event Info(string msg);

    function parse(string json, uint len) returns (bool) {

        var (success, tokens, actualNum) = JsmnSolLib.parse(json, len);
        Info('Parsed msg');
        Result(success, actualNum);
        return success;
    }

}

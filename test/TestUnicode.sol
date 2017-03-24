pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestUnicode {

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    function testUmlaut() {
        string memory json = '{"key": "Möhrenbrot"}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        JsmnSolLib.Token memory t = tokens[2];

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'Möhrenbrot', 'Problems with an umlaut');
    }

    function testDiacritcs() {
        string memory json = '{"key": "svenskå", "key2": "smørgasbröd", "key3": "Fußball"}';
        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 10);

        JsmnSolLib.Token memory t;

        t = tokens[2];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'svenskå', 'Problems with svensk 1');

        t = tokens[4];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'smørgasbröd', 'Problems with svensk 2');

        t = tokens[6];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'Fußball', 'Problems with svensk 2');
    }

}

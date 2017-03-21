pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestPrimitives {

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    function testStringKeyValue() {
        string memory json = '{"key": "value"}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key', 'Not equal');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end), 'value', 'Not equal');
    }

    function testIntegerKeyValue() {
        string memory json = '{"key": 23}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key', 'Not equal');
        Assert.equal(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end)), 23, 'Not equal');
    }

    function testNegativeIntegerKeyValue() {
        string memory json = '{"key": -4523}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key', 'Not equal');
        Assert.equal(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end)), -4523, 'Not equal');
    }

    function testBoolKeyValue() {
        string memory json = '{"key": true}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key', 'Not equal');
        Assert.isTrue(JsmnSolLib.parseBool(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end)), 'Not equal');
    }

    function testFloatKeyValue() {
        string memory json = '{"key": 23.45}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key', 'Not equal');
        Assert.equal(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end), 1), 234, 'Not equal');
    }

}

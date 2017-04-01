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

    function testLongerJson() {
        string memory json = '{ "key1": { "key1.1": "value", "key1.2": 3, "key1.3": true, "key1.4": "val2"} }';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        JsmnSolLib.Token memory t;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 20);
        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        t = tokens[1];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'key1', 'Not equal');

        t = tokens[3];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'key1.1', 'Not equal');

        t = tokens[4];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'value', 'Not equal');

        t = tokens[5];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'key1.2', 'Not equal');

        t = tokens[6];
        Assert.equal(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, t.start, t.end)), 3, 'Not equal');

        t = tokens[7];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'key1.3', 'Not equal');

        t = tokens[8];
        Assert.equal(JsmnSolLib.parseBool(JsmnSolLib.getBytes(json, t.start, t.end)), true, 'Not equal');

        t = tokens[9];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'key1.4', 'Not equal');

        t = tokens[10];
        Assert.equal(JsmnSolLib.getBytes(json, t.start, t.end), 'val2', 'Not equal');
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
        string memory json = '{"key": 23.45, "key2": 5, "key3": "23.66", "key4": "236.6"}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 10);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key', 'Not equal');
        Assert.equal(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end), 2), 2345, 'Not equal');
    }

}

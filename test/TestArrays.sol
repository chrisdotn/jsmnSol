pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestArrays {

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    function testSimpleArray() public {
        string memory json = '{"outerKey": [{"innerKey1": "value"}, {"innerKey2": "value"}]}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 10);

        JsmnSolLib.Token memory t = tokens[2];

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.isTrue(t.jsmnType == JsmnSolLib.JsmnType.ARRAY, 'Not an array');
    }

    function testFloatArray() public {
        string memory json = '[16500.4, 16450.5]';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        int expectedInt1 = 1650040;
        int expectedInt2 = 1645050;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 3);

        int returnedInt1 = JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 2);
        int returnedInt2 = JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end), 2);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(actualNum, 3, 'Number of tokens should be 3');
        Assert.isTrue(tokens[0].jsmnType == JsmnSolLib.JsmnType.ARRAY, 'Not an array');
        Assert.isTrue(tokens[1].jsmnType == JsmnSolLib.JsmnType.PRIMITIVE, 'Not a primitive');
        Assert.isTrue(tokens[2].jsmnType == JsmnSolLib.JsmnType.PRIMITIVE, 'Not a primitive');
        Assert.equal(returnedInt1, expectedInt1, 'First numbers not equal');
        Assert.equal(returnedInt2, expectedInt2, 'First numbers not equal');
    }


}

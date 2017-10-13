pragma solidity ^0.4.5;

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

}

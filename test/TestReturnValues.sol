pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestReturnValues {

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    event ReturnValueEvent(uint returnVal);

    function testNotEnoughMemory() {
        string memory json = '{ "key": "value", "key_2": 23, "key_3": true }';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        ReturnValueEvent(returnValue);

        //JsmnSolLib.Token memory t = tokens[2];

        Assert.equal(returnValue, RETURN_ERROR_NO_MEM, 'There should not have been enough tokens to store the json.');
    }

}

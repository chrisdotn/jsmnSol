pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestReturnValues {

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    function testNotEnoughMemory() {
        string memory json = '{ "key": "value", "key_2": 23, "key_3": true }';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        Assert.equal(returnValue, RETURN_ERROR_NO_MEM, 'There should not have been enough tokens to store the json.');
    }

    function testUnescapedQuoteInString() {
        string memory json = '{ "key1": { "key1.1": "value", "key1"2": 3, "key1.3": true } }'
;

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 20);

        Assert.equal(returnValue, RETURN_ERROR_INVALID_JSON, 'An unescaped quote should result in a RETURN_ERROR_INVALID_JSON');

    }

    function testNumberOfElements() {
        string memory json = '{ "key": "value", "key_2": 23, "key_3": true }';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 10);

        Assert.equal(returnValue, RETURN_SUCCESS, 'Should have returned SUCCESS');
        Assert.equal(actualNum, 7, 'Should have returned the correct # of elements');

    }

}

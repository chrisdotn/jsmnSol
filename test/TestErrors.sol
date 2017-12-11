pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestErrors {

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    function testTooFewTokens() public {
        string memory json = '[16500.4, 16450.5]';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 2);

        Assert.equal(returnValue, RETURN_ERROR_NO_MEM, 'Parser should have run out of tokens');
    }

}

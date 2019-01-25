pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestHelpers {

    function testIntParser() public {
        string memory testValue = '236.6';
        int expected = 23660;
        int result = JsmnSolLib.parseInt(testValue, 2);
        Assert.equal(result, expected, 'Not equal');
    }

    function testIntParserOneDecimal() public {
        string memory testValue = '23.4';
        int expected = 234;
        int result = JsmnSolLib.parseInt(testValue, 1);
        Assert.equal(result, expected, 'Not equal');
    }

    function testIntParserTwoDecimal() public {
        string memory testValue = '23.4';
        int expected = 2340;
        int result = JsmnSolLib.parseInt(testValue, 2);
        Assert.equal(result, expected, 'Not equal');
    }

    function testIntParserNegative() public {
        string memory testValue = '-45.2';
        int expected = -452;
        int result = JsmnSolLib.parseInt(testValue, 1);
        Assert.equal(result, expected, 'Not equal');
    }

}

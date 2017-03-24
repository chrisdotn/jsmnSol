pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestHelpers {

    function testIntParser() {
        string memory testValue = '236.6';
        int expected = 23660;
        int result = JsmnSolLib.parseInt('236.6', 2);
        Assert.equal(result, expected, 'Not equal');
    }

    function testIntParserOneDecimal() {
        string memory testValue = '23.4';
        int expected = 234;
        int result = JsmnSolLib.parseInt(testValue, 1);
        Assert.equal(result, expected, 'Not equal');
    }

    function testIntParserTwoDecimal() {
        string memory testValue = '23.4';
        int expected = 2340;
        int result = JsmnSolLib.parseInt(testValue, 2);
        Assert.equal(result, expected, 'Not equal');
    }

    function testIntParserNegative() {
        string memory testValue = '-45.2';
        int expected = -452;
        int result = JsmnSolLib.parseInt(testValue, 1);
        Assert.equal(result, expected, 'Not equal');
    }

}

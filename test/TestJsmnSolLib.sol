pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/JsmnSolLib.sol";

contract TestJsmnSolLib {
    function testSimpleJson() {
        string memory json = '{"key": "value"}';

        bool success;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (success, tokens, actualNum) = JsmnSolLib.parse(json, 5);
        Assert.isTrue(success, 'Valid JSON should return a success.');
    }

}

pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestHelpers {

    function testIntParser() {
        int expected = 23660;
        int result = JsmnSolLib.parseInt('236.6', 2);

        Assert.equal(result, expected, 'Not equal');
    }

}

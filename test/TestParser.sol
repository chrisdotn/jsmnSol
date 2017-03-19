pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ParserJson.sol";

contract TestParser {
    function testSimpleJson() {
        ParserJson parser = ParserJson(DeployedAddresses.ParserJson());
        string memory json = '{"key": "value"}';
        //string memory json = "string";

        bool success = parser.parse(json, 5);

        Assert.isTrue(success, 'Failed horribly');
    }

}

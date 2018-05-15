pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "../contracts/JsmnSolLib.sol";

contract TestObjects {
    
    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;
    
    function testSimpleObject() public {
        string memory json = '{"supplier_company_name":"Item description","supplier_authorized_person_name":"100","supplier_authorized_person_email":"Ton","supplier_company_street":"Steel Work","supplier_company_mobile_phone":"EUR900","supplier_company_fax":"EUR4500","supplier_account_beneficiary_name":"shuja","supplier_bank_name":"Emirates NBD"}';
        
        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;
        
        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 101);
        
        JsmnSolLib.Token memory t = tokens[4];
        string memory jsonElement = JsmnSolLib.getBytes(json, t.start, t.end);
        
        Assert.equal(returnValue, RETURN_SUCCESS, 'Valid JSON should return a success.');
        Assert.equal(jsonElement, '100', 'Valid JSON should return a success.');
        Assert.equal(actualNum, 17, 'Should have returned the correct # of elements');
        Assert.isTrue(t.jsmnType == JsmnSolLib.JsmnType.STRING, 'Not an string');
        
        
    }
}

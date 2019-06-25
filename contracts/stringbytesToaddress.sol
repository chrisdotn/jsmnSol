pragma solidity ^0.5.0;

library stringbytesToaddress {



// Convert an hexadecimal character to their value
function fromHexChar(uint8 c) public pure returns (uint8) {
    if (byte(c) >= byte('0') && byte(c) <= byte('9')) {
        return c - uint8(byte('0'));
    }
    if (byte(c) >= byte('a') && byte(c) <= byte('f')) {
        return 10 + c - uint8(byte('a'));
    }
    if (byte(c) >= byte('A') && byte(c) <= byte('F')) {
        return 10 + c - uint8(byte('A'));
    }
}

function fromHex(string memory s) public pure returns (bytes memory) {
    bytes memory ss = bytes(s);
    require(ss.length%2 == 0); // length must be even
    bytes memory r = new bytes(ss.length/2);
    for (uint i=0; i< (ss.length/2 -1 ); ++i) {
        
        r[i] = byte(fromHexChar(uint8(ss[2*(i+1)])) * 16 +
                    fromHexChar(uint8(ss[2*(i+1)+1])));
        
    }
    return r;
}

// this definetelly works! 
function bytesToAddress(bytes memory _address) public pure returns (address) {
  uint160 m = 0;
  uint160 b = 0;

  for (uint8 i = 0; i < 20; i++) {
    m *= 256;
    b = uint8(_address[i]);
    m += (b);
  }

  return address(m);
}


function convert (string memory source) public pure returns (address) {
    
    return (bytesToAddress(fromHex(source)));
}

}

# jsmnSol
`jsmnSol` is a port of the [jsmn](https://github.com/zserge/jsmn) JSON parser to Solidity, originally written in C. Its main purpose is to parse **small** JSON data on chain. Because string handling is complicated in Solidity and particularly expensive the usage should be restricted to small JSON data. However, it can help to reduce calls to oracles and deal with the responses on chain.

## Installation
There are two ways to use the library:
 1. Clone the repository using `git clone`. This will give you all the files including the parser, the tests and everything in between. To use it in your project you then need to import the `JsmnSolLib.sol` into your project.
 2. If you are using truffle as a framework, you can use the ethpm package manager and just run a `truffle install jsmnsol-lib`. This will install the library into a folder named `installed_contracts`. In your contract you can then import it using `import jsmnsol-lib/JsmnSolLib.sol`.


## Usage
There is pretty much one interesting function only:
```
function parse(string json, uint numberElements) internal returns (bool, Token[], uint)
```
The function takes a JSON string that should be parsed and the maximum number of elements in the JSON as input parameter. It returns a `boolean` to indicate successful parsing, an array of tokens and the number of tokens that is has found.

### Token
The main concept for JsmnSol is to parse the JSON string once and identify all tokens in it. Instead of copying the values from the string, the parser only stores the tokens' indices. To access an element later, one can use these index values to retrieve the relevant substring from the original string. A `Token` is a struct like this:
```
struct Token {
    JsmnType jsmnType;
    uint start;
    bool startSet;
    uint end;
    bool endSet;
    uint8 size;
}
```
The `start` and `end` members are the index values for the token. `JsmnType` can have the following values:
```
enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
```
The parser treats all primitives (ie. `number`, `boolean` or `null`) as the same type. They can be distinguished by comparing the first character. These are the possibilities:
 - `0–9` or `-`: The primitive is a number.
 - `t` or `f`: The primitive is a boolean.
 - `n`: The primitive is `null`.

## Helpers
To make life easier, a number of helper functions are included. They can be used to convert the substring that is marked by a token to useful data.

### getBytes
`getBytes` can be used to retrieve a string value for a token. The signature is:
```
function getBytes(string json, uint start, uint end) internal returns (string)
```
It takes the original JSON string as first input. `start` and `end` indicate the start and the end of the substring. If the parser has returned an array of tokens called `tokens`, the call would be:
```
string memory json = '{"key":"value"}';

uint returnValue;
JsmnSolLib.Token[] memory tokens;
uint actualNum;

(returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

Token memory t = tokens[2];
string memory jsonElement = getBytes(json, t.start, t.end);

// jsonElement is 'value' now.
```

### parseBool
`parseBool(string _a) returns (bool)` will take a string as input and return a `Boolean`. The return value will be:
- `true` if and only if `_a == 'true'`
- `false` in all other cases

### parseInt
parseInt comes in two flavors:
1. `function parseInt(string _a) internal returns (int)`: The version with one input parameter returns an `int` from a string. It is useful for strings known to contain an integer value.
2. `function parseInt(string _a, uint _b) internal returns (int)`: The version with two input parameters is useful for parsing floating-point numbers. Because Solidity itself doesn't allow to use floating-point numbers, the `parseInt` will return the integer part + the number of decimal places specified by `_b`. The entire value is multiplied by 10<sup>\_b</sup>.

#### Examples
The function will return these values:
- `parseInt('34')`: 34
- `parseInt('34.45', 1)`: 344
- `parseInt('34.45', 2)`: 3445
- `parseInt('34.45', 3)`: 34450

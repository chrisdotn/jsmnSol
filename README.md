# jsmnSol
`jsmnSol` is a port of the [jsmn](https://github.com/zserge/jsmn) JSON parser to Solidity, orginally written in C. Its main purpose is to parse **small** JSON data onchain. Because string handling is complicated in Solidity and particularly expensive the usage should be restricted to small JSON data. However, it can help to reduce calls to oracles and deal with the responses onchain.


## Usage
JsmnSol is a library that can be imported with
```
import '${PATH_TO_FILE}/JsmnSol.sol';
```

There is pretty much one interesting function only:
```
function parse(string json, uint numberElements) internal returns (bool, Token[], uint)
```
The function takes a JSON string that should be parsed and the maximum number of elements in the JSON as input parameter. It returns a `boolean` to indicate successful parsing, an array of tokens and the number of tokens that is has found.

### Token
The main concept for JsmnSol is to parse the JSON string once and identify all tokens in it. Instead of copying the values from the string, the parser only stores the token's index. To access an element later, one can use these index values to retrieve the relevant substring from the original string. A `Token` is a struct like this:
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
The `start` and `end` members are the index values for the token. `jsmnType` can have the following values:
```
enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
```
The parser treats all primitives (ie. `number`, `boolean` or `null` as the same type. They can be distinguised by comparing the first character. These are the possibilities:
 - `0–9`: The primitive is a number.
 - `t` or `f`: The primitive is a boolean.
 - `n`: The primitive is `null`.

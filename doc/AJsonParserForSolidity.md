# TODO
- Proof read

# A JSON Parser For Solidity
Developing smart contracts in Ethereum has become easier with the advent of frameworks such as [Truffle](https://www.truffleframework.com) and services such as [oraclize.it](https://oraclize.it). In particular, using oracles to access information that is external to the blockchain has become simple enough to be used by the average solidity developer. However, most of the data that is fed into the blockchain via transactions from oracles comes in as JSON formatted data. This requires a smart contract to parse a JSON object to process the data supplied by an oracle.

String processing is particularly expensive on the Ethereum blockchain. Thus, the JSON parser should be "lightweight" and not use much computation for parsing and processing a JSON string.

As there was not JSON parser for Solidity that I'm aware of, I set out to create my own. As a basis I ported the code from [jsmn](https://github.com/zserge/jsmn) to Solidity. The main design consideration of jsmn is parsing a JSON string in a single pass and avoid copying substrings along the way. Thus, the parser only generates _meta data_ on the provided string that can be used for  locating and accessing objects in the JSON string.

## Single Pass, Fixed Memory, No Copying
The parser works by parsing the supplied string character by character once. Along the way it creates tokens, which each identify a JSON object in the string and indicate its starting and ending position in the string. A `token` has this structure:
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

The `JsmnType` encodes the type of the token. Valid values are:
```
enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
```

Note that `number, boolean` and `null` are all treated as `JsmnType.PRIMITIVE`. They can be distinguished by evaluating the first character of the token.

Next are the two values `start` and `end`. They encode the starting and the ending position of the substring. The `size` indicates the number of subobjects for that object (that is the number of children in the JSON hierarchy). For technical reasons there are two more variables (`startSet` and `endSet`) that are `false` on initialization and flip to `true` once the values for `start` or `end` have been set. They are needed because Solidity has the habit of initializing every variable to its default value. A newly created `Token` would return 0 for both `token.start` and `token.end`. The parser uses that zero value to distinguish a newly initialized token form a to token whose object actually starts at position 0 in the string.

## Usage
The library basically requires only one call: `function parse(string json, uint numberElements) internal returns (uint, Token[], uint)`. This call takes two parameters:
- `string json`: The string containing the JSON
- `uint numberOfTokens`: The maximum number of tokens to allocate for parsing. This parameter ensures reasonable gas consumption. Whenever the string has more objects than `numberOfTokens` allows, the parser returns with an error.

### A Simple Example
The JSON that we want to parse is this:
```
{
    "key1": {
        "key1.1": "value",
        "key1.2": 3,
        "key1.3": true
    }
}
```
The actual JSON that we pass to the parser is a minified version of the JSON above so that we have the following string: ```{ "key1": { "key1.1": "value", "key1.2": 3, "key1.3": true } }```.

After a call to `parse(json, 10)`, the parser would return three values:
 - `uint`: The return value. It is zero for _success_ and non-zero for _errors_
 - `Token[]`: An array of tokens. The array has 10 elements.
 - `uint`: The number of tokens returned. This number is generally less than the length of the token array. It should be used to access the tokens. Indices greater than the number of elements return a default token.

 The token array would look like this:

| # | JsmnType | start | end | startSet | endSet | size |
|---|---|---|---|---|---|---|
| 0 | OBJECT    |  0 | 62 | true  | true  | 1 |
| 1 | STRING    |  3 |  7 | true  | true  | 1 |
| 2 | OBJECT    | 10 | 60 | true  | true  | 3 |
| 3 | STRING    | 13 | 19 | true  | true  | 1 |
| 4 | STRING    | 23 | 28 | true  | true  | 0 |
| 5 | STRING    | 32 | 38 | true  | true  | 1 |
| 6 | PRIMITIVE | 41 | 42 | true  | true  | 0 |
| 7 | STRING    | 45 | 51 | true  | true  | 1 |
| 8 | PRIMITIVE | 54 | 58 | true  | true  | 0 |
| 9 | UNDEFINED |  0 |  0 | false | false | 0 |

## Installation
The library is available on [github](https://github.com/chrisdotn/jsmnSol) or on the Ethereum Package Manager `ethpm` as package `jsmnsol-lib`. If you are using truffle you can easily include the library by running `truffle install jsmnsol-lib`.

## Use Case: Response Data From an Oracle
One of the possible use cases for the parser is processing an oracle response. For instance, if you are using oraclize.it as oracle, the data that is returned in the callback is most likely a JSON string that is the result of a call to a REST API. Usually these responses include all kinds of data that is probably not relevant for the smart contract. It might, however, be the case that the contract is not only interested in one specific datum from the JSON, but more than one. An example would be a bet for a football match: A call to an API (this one specifically is the response of `GET https://api.football-data.org/v1/fixtures/152250?head2head=0`) returns the result of the match as a JSON:
```
{
    "fixture": {
        "_links": {
            "self": {
                "href": "http://api.football-data.org/v1/fixtures/152250"
            },
            "competition": {
                "href": "http://api.football-data.org/v1/competitions/430"
            },
            "homeTeam": {
                "href": "http://api.football-data.org/v1/teams/16"
            },
            "awayTeam": {
                "href": "http://api.football-data.org/v1/teams/11"
            }
        },
        "date": "2016-08-27T13:30:00Z",
        "status": "FINISHED",
        "matchday": 1,
        "homeTeamName": "FC Augsburg",
        "awayTeamName": "VfL Wolfsburg",
        "result": {
            "goalsHomeTeam": 0,
            "goalsAwayTeam": 2
        },
        "odds": {
            "homeWin": 3.0,
            "draw": 3.3,
            "awayWin": 2.37
        }
    }
}
```
For winner determination the only interesting part of that response is the `result` part of the response. From that result part, we need two elements, namely the number for `goalsHomeTeam` and the number of `goalsAwayTeam`. We need to compare the numbers to decide on the winner of the match. There are two steps to facilitate processing of the response:

### Reduce The Result to Fewer Elements...
The first step to make that reponse useful is to reduce it to the actually needed parts. oraclize.it provides a means to filter a response from a server with [JSONPath](http://goessner.net/articles/JsonPath/)). By filtering the response with `$.fixture.result` oraclize would only return the following part of the JSON to our smart contract (again as a minified string actually):
```
{
    "goalsHomeTeam": 0,
    "goalsAwayTeam": 2
}
```

### ...And Parse Them
This bit is much less expensive to process on chain. We can use the parser to parse this string. It would return the following tokens:

| # | JsmnType | start | end | startSet | endSet | size |
|---|---|---|---|---|---|---|
| 0 | OBJECT    |  0 | 42 | true  | true  | 2 |
| 1 | STRING    |  3 | 16 | true  | true  | 1 |
| 2 | PRIMITIVE | 19 | 20 | true  | true  | 0 |
| 3 | STRING    | 23 | 36 | true  | true  | 1 |
| 4 | PRIMITIVE | 39 | 40 | true  | true  | 0 |

Now we can use the two tokens `token[2]` and `token[4]` to access the two interesting numbers. To extract the substring for `token[2]` we would call: `string goalsHT_string = getBytes(json, token[2].start, token[2].end)`. This call returns a string. To do useful comparisons on the actual numbers, we still need to convert that string to a `uint`. A call to `uint goalsHT = parseInt(goalsHT_string)` accomplishes that.

This procedure of combining a filter on the result via JSONPath and then parsing the result with the parser allows processing of oracle responses with a smart contract.

# Final Words
This parser is still in beta; this is its first release. Because of the gas cost it should not be used to parse large JSON files as that will most likely fail. String processing is computation intensive and thus expensive. However, for small JSONs (possibly already reduced by a suitable JSONPath) it can be economical to parse them on chain and save another call to an oracle to get another part of the JSON.

If you find the library useful, I would appreciate a comment or a donation. Issues and or feature request can be filed on Github.

Ether donations: `0x7a0984e31a65fcdea119943f88858cfc3fe00da9`

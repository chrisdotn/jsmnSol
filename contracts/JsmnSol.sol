pragma solidity ^0.4.2;

library JsmnSol {

    enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
    enum JsmnError { INVALID, ERROR_PART, NO_MEMORY}

    struct Token {
        JsmnType jsmnType;
        uint start;
        bool startSet;
        uint end;
        bool endSet;
        uint8 size;
    }

    struct Parser {
        uint pos;
        uint toknext;
        int toksuper;
    }

    function init(uint length) internal returns (Parser, Token[]) {
        Parser memory p = Parser(0, 0, -1);
        Token[] memory t = new Token[](length);
        return (p, t);
    }

    function allocateToken(Parser parser, Token[] tokens) internal returns (bool, Token) {
        if (parser.toknext >= tokens.length) {
            // no more space in tokens
            return (false, tokens[tokens.length-1]);
        }
        Token memory token = Token(JsmnType.UNDEFINED, 0, false, 0, false, 0);
        tokens[parser.toknext] = token;
        parser.toknext++;
        return (true, token);
    }

    function fillToken(Token token, JsmnType jsmnType, uint start, uint end) internal {
        token.jsmnType = jsmnType;
        token.start = start;
        token.startSet = true;
        token.end = end;
        token.endSet = true;
        token.size = 0;
    }

    function parseString(Parser parser, Token[] tokens, bytes s) internal returns (int) {
        uint start = parser.pos;
        parser.pos++;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // Quote -> end of string
            if (c == '"') {
                var (success, token) = allocateToken(parser, tokens);
                if (!success) {
                    parser.pos = start;
                    return int(JsmnError.NO_MEMORY);
                }
                fillToken(token, JsmnType.STRING, start+1, parser.pos);
                return 0;
            }

            if (c == '\\') {
                // TODO handle escaped characters
            }
        }
        parser.pos = start;
        return int(JsmnError.ERROR_PART);
    }

    function parsePrimitive(Parser parser, Token[] tokens, bytes s) internal returns (int) {
        bool found = false;
        uint start = parser.pos;
        byte c;
        for (; parser.pos < s.length; parser.pos++) {
            c = s[parser.pos];
            if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == ','
                || c == 0x7d || c == 0x5d) {
                    found = true;
                    break;
            }
            if (c < 32 || c > 127) {
                parser.pos = start;
                return int(JsmnError.INVALID);
            }
        }
        if (!found) {
            parser.pos = start;
            return int(JsmnError.ERROR_PART);
        }

        // found the end
        var (success, token) = allocateToken(parser, tokens);
        if (!success) {
            parser.pos = start;
            return int(JsmnError.NO_MEMORY);
        }
        fillToken(token, JsmnType.PRIMITIVE, start, parser.pos);
        parser.pos--;
        return 0;
    }

    function parse(string json, uint numberElements) internal returns (bool, Token[], uint) {
        bytes memory s = bytes(json);
        var (parser, tokens) = init(numberElements);

        // Token memory token;
        int r;
        uint count = parser.toknext;
        uint i;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // 0x7b, 0x5b opening parentheses
            if (c == 0x7b || c == 0x5b) {
                count++;
                var (success, token)= allocateToken(parser, tokens);
                if (!success) {
                    return (false, tokens, 0);
                    //JsmnError.NO_MEMORY;
                }
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                token.jsmnType = (c == 0x7b ? JsmnType.OBJECT : JsmnType.ARRAY);
                token.start = parser.pos;
                token.startSet = true;
                parser.toksuper = int(parser.toknext - 1);
                continue;
            }

            // closing parentheses
            if (c == 0x7d || c == 0x5d) {
                JsmnType tokenType = (c == 0x7d ? JsmnType.OBJECT : JsmnType.ARRAY);
                bool isUpdated = false;
                for (i=parser.toknext-1; i>=0; i--) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        if (token.jsmnType != tokenType) {
                            // found a token that hasn't been closed but from a different type
                            return (false, tokens, 0);
                            //JsmnError.INVALID;
                        }
                        parser.toksuper = -1;
                        tokens[i].end = parser.pos + 1;
                        tokens[i].endSet = true;
                        isUpdated = true;
                        break;
                    }
                }
                if (!isUpdated) {
                    return (false, tokens, 0);
                    //JsmnError.INVALID;
                }
                for (; i>0; i--) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        parser.toksuper = int(i);
                        break;
                    }
                }

                if (i==0) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        parser.toksuper = uint128(i);
                    }
                }
                continue;
            }

            // 0x42
            if (c == '"') {
                r = parseString(parser, tokens, s);
                if (r < 0) return (false, tokens, 0);
                //JsmnError.INVALID;
                count++;
				if (parser.toksuper != -1)
					tokens[uint(parser.toksuper)].size++;
                continue;
            }

            // ' ', \r, \t, \n
            if (c == ' ' || c == 0x11 || c == 0x12 || c == 0x14) {
                continue;
            }

            // 0x3a
            if (c == ':') {
                parser.toksuper = int(parser.toknext -1);
                continue;
            }

            if (c == ',') {
                if (parser.toksuper != -1
                    && tokens[uint(parser.toksuper)].jsmnType != JsmnType.ARRAY
                    && tokens[uint(parser.toksuper)].jsmnType != JsmnType.OBJECT) {
                        for(i = parser.toknext-1; i>=0; i--) {
                            if (tokens[i].jsmnType == JsmnType.ARRAY || tokens[i].jsmnType == JsmnType.OBJECT) {
                                if (tokens[i].startSet && !tokens[i].endSet) {
                                    parser.toksuper = int(i);
                                    break;
                                }
                            }
                        }
                    }
                continue;
            }

            // Primitive
            // FIXME Doesn't handle negative numbers (Can I just include '-'?)
            if ((c >= '0' && c <= '9') || c == '-' || c == 'f' || c == 't' || c == 'n') {
                if (parser.toksuper != -1) {
                    token = tokens[uint(parser.toksuper)];
                    if (token.jsmnType == JsmnType.OBJECT
                        || (token.jsmnType == JsmnType.STRING && token.size != 0)) {
                            return (false, tokens, 0);
                            // JsmnError.INVALID;
                        }
                }

                r = parsePrimitive(parser, tokens, s);
                if (r < 0) { return (false, tokens, 0);
                    // JsmnError.INVALID;
                }
                count++;
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                continue;
            }

            // printable char
            if (c >= 0x20 && c <= 0x7e) {
                continue;
            }
        }

        return (true, tokens, parser.toknext-1);
    }

    function getBytes(string json, uint start, uint end) internal returns (string) {
        bytes memory s = bytes(json);
        bytes memory result = new bytes(end-start);
        for (uint i=start; i<end; i++) {
            result[i-start] = s[i];
        }
        return string(result);
    }

}

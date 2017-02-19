pragma solidity ^0.4.2;

contract JsmnSol {

    event Info(string msg);
    event TokenInfo(JsmnType jsmnType, int start, int end, uint8 size);
    event Debug(int toksuper, int length);

    enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
    enum JsmnError { INVALID, ERROR_PART, NO_MEMORY}

    struct JsmnToken {
        JsmnType jsmnType;
        int start;
        bool startSet;
        int end;
        bool endSet;
        uint8 size;
    }

    struct Parser {
        uint pos;
        uint toknext;
        int toksuper;
    }

    JsmnToken[] storageTokens;

    function jsmnInit(uint length) internal returns (Parser, JsmnToken[]) {
        Parser memory p = Parser(0, 0, -1);
        JsmnToken[] memory t = new JsmnToken[](length);
        return (p, t);
    }

    function allocateToken(Parser parser, JsmnToken[] tokens) internal returns (bool, JsmnToken) {
        Info('allocateToken');
        if (parser.toknext >= tokens.length) {
            // no more space in tokens
            return (false, tokens[tokens.length-1]);
        }
        JsmnToken memory token = JsmnToken(JsmnType.UNDEFINED, -1, false, -1, false, 0);
        tokens[parser.toknext] = token;
        parser.toknext++;
        return (true, token);
    }

    function fillToken(JsmnToken token, JsmnType jsmnType, int start, int end) internal {
        token.jsmnType = jsmnType;
        token.start = start;
        token.startSet = true;
        token.end = end;
        token.endSet = true;
        token.size = 0;
    }

    function parseString(Parser parser, JsmnToken[] tokens, bytes s) internal returns (int) {
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
                fillToken(token, JsmnType.STRING, int(start+1), int(parser.pos));
                return 0;
            }

            if (c == '\\') {
                // TODO handle escaped characters
            }
        }
        parser.pos = start;
        return int(JsmnError.ERROR_PART);
    }

    function parsePrimitive(Parser parser, JsmnToken[] tokens, bytes s) internal returns (int) {
        bool found = false;
        uint start = parser.pos;
        byte c;
        uint ti;
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
        fillToken(token, JsmnType.PRIMITIVE, int(start), int(parser.pos));
        parser.pos--;
        return 0;
    }

    function jsmnParse(string json, uint numberElements) returns (JsmnError) {
        bytes memory s = bytes(json);
        var (parser, tokens) = jsmnInit(numberElements);

        // JsmnToken memory token;
        int r;
        uint count = parser.toknext;
        uint i;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // 0x7b, 0x5b opening parentheses
            if (c == 0x7b || c == 0x5b) {
                Info('Opening parentheses');
                count++;
                //token = allocateToken();
                var (success, token)= allocateToken(parser, tokens);
                if (!success) {
                    return JsmnError.NO_MEMORY;
                }
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                token.jsmnType = (c == 0x7b ? JsmnType.OBJECT : JsmnType.ARRAY);
                token.start = int(parser.pos);
                token.startSet = true;
                parser.toksuper = int(parser.toknext - 1);
                continue;
            }

            // closing parentheses
            if (c == 0x7d || c == 0x5d) {
                Info('Closing parentheses');
                JsmnType tokenType = (c == 0x7d ? JsmnType.OBJECT : JsmnType.ARRAY);
                bool isUpdated = false;
                for (i=parser.toknext-1; i>=0; i--) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        if (token.jsmnType != tokenType) {
                            // found a token that hasn't been closed but from a different type
                            Info('Error: wrong type');
                            return JsmnError.INVALID;
                        }
                        parser.toksuper = -1;
                        tokens[i].end = int(parser.pos + 1);
                        tokens[i].endSet = true;
                        isUpdated = true;
                        break;
                    }
                }
                if (!isUpdated) {
                    Info('Error: No update');
                    return JsmnError.INVALID;
                }
                for (; i>0; i--) {
                    token = tokens[uint(i)];
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
                Info('Double quote');
                r = parseString(parser, tokens, s);
                if (r < 0) return JsmnError.INVALID;
                count++;
				if (parser.toksuper != -1)
					tokens[uint(parser.toksuper)].size++;
                continue;
            }

            // ' ', \r, \t, \n
            if (c == ' ' || c == 0x11 || c == 0x12 || c == 0x14) {
                Info('Whitespace');
                continue;
            }

            // 0x3a
            if (c == ':') {
                Info('Colon');
                parser.toksuper = int(parser.toknext -1);
                continue;
            }

            if (c == ',') {
                Info('Comma');
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

            if ((c >= '0' && c <= '9') || c == 'f' || c == 't' || c == 'n') {
                Info('Primitive');
                if (parser.toksuper != -1) {
                    token = tokens[uint(parser.toksuper)];
                    if (token.jsmnType == JsmnType.OBJECT
                        || (token.jsmnType == JsmnType.STRING && token.size != 0)) {
                            return JsmnError.INVALID;
                        }
                }

                r = parsePrimitive(parser, tokens, s);
                if (r < 0) { return JsmnError.INVALID; }
                count++;
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                continue;
            }

            if (c >= 0x20 && c <= 0x7e) {
                Info('Printable char');
                continue;
            }
        }

        storageTokens.length = 0;
        for (i=0; i<parser.toknext; i++) {
            storageTokens.push(tokens[i]);
        }
    }

    function getAllTokens() {
        for (uint i=0; i<storageTokens.length; i++) {
            JsmnToken t = storageTokens[i];
            TokenInfo(t.jsmnType, t.start, t.end, t.size);
        }
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

}

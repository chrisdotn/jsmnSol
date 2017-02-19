pragma solidity ^0.4.2;

library JsmnSol {

    event TokenInfo(JsmnType jsmnType, uint start, uint end, uint8 size);
    event Debug(int toksuper, int length);

    enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
    enum JsmnError { INVALID, ERROR_PART, NO_MEMORY}

    struct JsmnToken {
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

    //JsmnToken[] storageTokens;

    function jsmnInit(uint length) internal returns (Parser, JsmnToken[]) {
        Parser memory p = Parser(0, 0, -1);
        JsmnToken[] memory t = new JsmnToken[](length);
        return (p, t);
    }

    function allocateToken(Parser parser, JsmnToken[] tokens) internal returns (bool, JsmnToken) {
        if (parser.toknext >= tokens.length) {
            // no more space in tokens
            return (false, tokens[tokens.length-1]);
        }
        JsmnToken memory token = JsmnToken(JsmnType.UNDEFINED, 0, false, 0, false, 0);
        tokens[parser.toknext] = token;
        parser.toknext++;
        return (true, token);
    }

    function fillToken(JsmnToken token, JsmnType jsmnType, uint start, uint end) internal {
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
        fillToken(token, JsmnType.PRIMITIVE, start, parser.pos);
        parser.pos--;
        return 0;
    }

    function jsmnParse(string json, uint numberElements) internal returns (bool, JsmnToken[], uint) {
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

            if ((c >= '0' && c <= '9') || c == 'f' || c == 't' || c == 'n') {
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

        /*storageTokens.length = 0;
        for (i=0; i<parser.toknext; i++) {
            storageTokens.push(tokens[i]);
        }*/
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

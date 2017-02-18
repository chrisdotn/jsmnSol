pragma solidity ^0.4.2;

contract JsmnSol {

    event Info(string msg);
    event TokenInfo(JsmnType jsmnType, int start, int end, uint8 size);
    event Debug(int toksuper, int length);

    enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }
    enum JsmnError { INVALID, ERROR_PART }

    struct JsmnToken {
        JsmnType jsmnType;
        int start;
        int end;
        uint8 size;
    }

    struct Parser {
        uint pos;
        int toksuper;
    }

    Parser parser;
    JsmnToken[] tokens;

    function jsmnInit() public {
        parser = Parser(0, -1);
        tokens.length = 0;
    }

    function allocateToken() internal returns (uint) {
        Info('allocateToken');
        tokens.length++;
        tokens[tokens.length - 1] = JsmnToken(JsmnType.UNDEFINED, -1, -1, 0);
        return tokens.length - 1;
    }

    function fillToken(uint ti, JsmnType jsmnType, int start, int end) {
        tokens[ti].jsmnType = jsmnType;
        tokens[ti].start = start;
        tokens[ti].end = end;
        tokens[ti].size = 0;
    }

    function parseString(bytes s) returns (int) {
        uint start = parser.pos;
        uint ti;
        parser.pos++;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // Quote -> end of string
            if (c == '"') {
                ti = allocateToken();
                fillToken(ti, JsmnType.STRING, int(start+1), int(parser.pos-1));
                return 0;
            }

            if (c == '\\') {
                // TODO handle escaped characters
            }
        }
        parser.pos = start;
        return int(JsmnError.ERROR_PART);
    }

    function parsePrimitive(bytes s) returns (int) {
        bool found = false;
        uint start = parser.pos;
        byte c;
        uint ti;
        for (; parser.pos < s.length; parser.pos++) {
            c = s[parser.pos];
            if (c == ' ' || c == '\t' || c == '\n' || c == '\r' //|| c == ','
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
        ti = allocateToken();
        fillToken(ti, JsmnType.PRIMITIVE, int(start), int(parser.pos));
        parser.pos--;
        return 0;
    }

    function jsmnParse(string json) returns (JsmnError) {
        bytes memory s = bytes(json);
        jsmnInit();

        // JsmnToken memory token;
        int r;
        uint ti;
        uint count = tokens.length;
        uint128 i;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // 0x7b, 0x5b opening parentheses
            if (c == 0x7b || c == 0x5b) {
                Info('Opening parentheses');
                count++;
                //token = allocateToken();
                ti = allocateToken();
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                tokens[ti].jsmnType = (c == 0x7b ? JsmnType.OBJECT : JsmnType.ARRAY);
                tokens[ti].start = int(parser.pos);
                parser.toksuper = int(tokens.length - 1);
                continue;
            }

            // closing parentheses
            if (c == 0x7d || c == 0x5d) {
                Info('Closing parentheses');
                JsmnType tokenType = (c == 0x7d ? JsmnType.OBJECT : JsmnType.ARRAY);
                bool isUpdated = false;
                for (i=uint128(tokens.length-1); i>=0; i--) {
                    //token = tokens[uint(i)];
                    if (tokens[i].start != -1 && tokens[i].end == -1) {
                        if (tokens[i].jsmnType != tokenType) {
                            // found a token that hasn't been closed but from a different type
                            Info('Error: wrong type');
                            return JsmnError.INVALID;
                        }
                        parser.toksuper = -1;
                        tokens[i].end = int(parser.pos);
                        isUpdated = true;
                        break;
                    }
                }
                if (!isUpdated) {
                    Info('Error: No update');
                    return JsmnError.INVALID;
                }
                for (; i>0; i--) {
                    //token = tokens[uint(i)];
                    if (tokens[i].start != -1 && tokens[i].end == -1) {
                        parser.toksuper = uint128(i);
                        break;
                    }
                }

                if (i==0) {
                    if (tokens[i].start != -1 && tokens[i].end == -1) {
                        parser.toksuper = uint128(i);
                    }
                }
                continue;
            }

            // 0x42
            if (c == '"') {
                Info('Double quote');
                r = parseString(s);
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
                parser.toksuper = int(tokens.length -1);
                continue;
            }

            if (c == ',') {
                Info('Comma');
                if (parser.toksuper != -1
                    && tokens[uint(parser.toksuper)].jsmnType != JsmnType.ARRAY
                    && tokens[uint(parser.toksuper)].jsmnType != JsmnType.OBJECT) {
                        for(i = uint128(tokens.length)-1; i>=0; i--) {
                            if (tokens[i].jsmnType == JsmnType.ARRAY || tokens[i].jsmnType == JsmnType.OBJECT) {
                                if (tokens[i].start != -1 && tokens[i].end == -1) {
                                    parser.toksuper = i;
                                }
                            }
                        }
                    }
                continue;
            }

            if ((c >= '0' && c <= '9') || c == 'f' || c == 't' || c == 'n') {
                Info('Primitive');
                if (parser.toksuper != -1) {
                    if (tokens[uint(parser.toksuper)].jsmnType == JsmnType.OBJECT
                        || (tokens[uint(parser.toksuper)].jsmnType == JsmnType.STRING
                            && tokens[uint(parser.toksuper)].size != 0)) {
                            return JsmnError.INVALID;
                        }
                }

                parsePrimitive(s);


                continue;
            }

            if (c >= 0x20 && c <= 0x7e) {
                Info('Printable char');
                continue;
            }
        }
    }

    function getAllTokens() {
        for (uint i=0; i<tokens.length; i++) {
            JsmnToken t = tokens[i];
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

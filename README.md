# jsmnSol
`jsmnSol` is a port of the [jsmn](https://github.com/zserge/jsmn) JSON parser to Solidity, orginally written in C. Its main purpose is to parse **small** JSON data onchain. Because string handling is complicated in Solidity and particularly expensive the usage should be reduced to small JSON data. However, it can help to reduce calls to oracles and deal with the responses onchain. 

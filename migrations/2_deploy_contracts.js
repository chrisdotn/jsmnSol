var JsmnSolLib = artifacts.require('./JsmnSolLib.sol');
var Parser = artifacts.require('./ParserJson.sol');

module.exports = function(deployer) {
  deployer.deploy(JsmnSolLib);
  deployer.link(JsmnSolLib, Parser);
  deployer.deploy(Parser);
};

var JsmnSolLib = artifacts.require('./JsmnSolLib.sol');

module.exports = function(deployer) {
  deployer.deploy(JsmnSolLib);
};

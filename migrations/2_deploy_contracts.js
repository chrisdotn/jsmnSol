module.exports = function(deployer) {
  deployer.deploy(JsmnSol);
  deployer.deploy(TestJsmnSol);
  deployer.autolink();
};

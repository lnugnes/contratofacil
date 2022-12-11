var TokenBRServiceProviderChain = artifacts.require(
  "TokenBRServiceProviderChain"
);
module.exports = function (deployer) {
  deployer.deploy(TokenBRServiceProviderChain, [
    "0x1939fd0e5f561b2c3d1089785a623de9bc8662e2",
    "32.852.538/0001-10",
  ]);
};

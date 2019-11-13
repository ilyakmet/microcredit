const Microcredit = artifacts.require("Microcredit");
const ProxyMicrocredit = artifacts.require("ProxyMicrocredit");


module.exports = (deployer) => {
    deployer.deploy(Microcredit);
    deployer.deploy(ProxyMicrocredit);
};
const Utils = artifacts.require("Utils");
const Microcredit = artifacts.require("Microcredit");
const ProxyMicrocredit = artifacts.require("ProxyMicrocredit");


module.exports = (deployer) => {
    deployer.deploy(Utils);
    deployer.link(Utils, Microcredit);
    deployer.deploy(Microcredit);
    deployer.deploy(ProxyMicrocredit);
};
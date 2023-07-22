const { network } = require("hardhat");

const BASE_FEE = ethers.utils.parseEther("0.25"); //0.25 is the premium. It consts 0.25 LINK per request
const GAS_PRICE_LINK = 1e9; //link per gas. calculated value based on gas price of the chain

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    args = [BASE_FEE, GAS_PRICE_LINK];

    await deploy("VRFCoordinatorV2Mock", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    log("Mocks Deployed!");
    log("--------------------------------------------");
};

module.exports.tags = ["all", "mock"];

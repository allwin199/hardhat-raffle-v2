const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    log("Raffle Deployed!");
    log("--------------------------------------------");

    if (chainId !== 31337 && process.env.ETHERSCAN_API_KEY) {
        await verify(raffle.address, args);
        log("--------------------------------------------");
    }
};

module.exports.tags = ["all", "raffle"];

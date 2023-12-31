const { network } = require("hardhat");
const { verify } = require("../utils/verify");
require("dotenv").config();

const VRF_SUB_FUND_AMOUNT = ethers.parseEther("2");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;
    let vrfCoordinatorV2Address, subscriptionId;

    if (chainId === 31337) {
        const vrfCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2Mock",
        );

        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.target;
        const transactionResponse =
            await vrfCoordinatorV2Mock.createSubscription();
        const transactionReceipt = await transactionResponse.wait(1);

        subscriptionId = transactionReceipt.events[0].args.subId;
        // // we got the subscription, now we have to fund the subscription.
        // // usually we need the link token on a real network to fund.
        await vrfCoordinatorV2Mock.fundSubscription(
            subscriptionId,
            VRF_SUB_FUND_AMOUNT,
        );
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"];
        subscriptionId = networkConfig[chainId]["subscriptionId"];
    }

    const entranceFee = networkConfig[chainId]["entranceFee"];
    const gasLane = networkConfig[chainId]["gasLane"];
    const callbackGasLimit = networkConfig[chainId]["callbackGasLimit"];
    const interval = networkConfig[chainId]["interval"];

    const args = [
        vrfCoordinatorV2Address,
        entranceFee,
        gasLane,
        subscriptionId,
        callbackGasLimit,
        interval,
    ];

    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    log("Raffle Deployed!");
    log("--------------------------------------------");

    // we need a valid consumer while running locally
    if (chainId === 31337) {
        await vrfCoordinatorV2Address.addConsumer(
            subscriptionId,
            raffle.address,
        );
    }

    if (chainId !== 31337 && process.env.ETHERSCAN_API_KEY) {
        await verify(raffle.address, args);
        log("--------------------------------------------");
    }
};

module.exports.tags = ["all", "raffle"];

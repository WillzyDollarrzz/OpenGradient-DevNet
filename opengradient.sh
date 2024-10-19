#!/bin/bash

echo "Installing dependencies..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
nvm install 18
nvm use 18
npm install -g hardhat
npm install --save-dev hardhat
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install --save-dev ethers @nomiclabs/hardhat-ethers
npm i opengradient-neuroml dotenv
npm install


if [ ! -d "contracts" ]; then
  echo "Initializing Hardhat project..."
  npx hardhat
else
  echo "Hardhat project already initialized."
fi

ENV_FILE=".env"
PREDEFINED_RPC_URL="http://18.218.115.248:8545"  

if [ ! -f "$ENV_FILE" ]; then
  echo "Please provide your private key:"
  read -s PRIVATE_KEY

  echo "Saving private key to .env file..."
  cat > $ENV_FILE <<EOL
PRIVATE_KEY=$PRIVATE_KEY
OPENGRADIENT_RPC_URL=$PREDEFINED_RPC_URL
EOL

  echo "Private Key saved successfully."
else
  echo ".env file already exists."
fi


CONFIG_FILE="hardhat.config.js"
echo "Updating hardhat.config.js..."
cat > $CONFIG_FILE <<EOL
require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

module.exports = {
  solidity: "0.8.27",
  defaultNetwork: "opengradient",
  networks: {
    opengradient: {
      url: process.env.OPENGRADIENT_RPC_URL,
      accounts: [\`0x\${process.env.PRIVATE_KEY}\`],
      chainId: 2970285607590380
    }
  },
};
EOL


CONTRACT_FILE="contracts/Test.sol"
if [ ! -f "$CONTRACT_FILE" ]; then
  echo "Creating Test.sol contract..."
  mkdir -p contracts
  cat > $CONTRACT_FILE <<EOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "opengradient-neuroml/src/OGInference.sol";

contract Test {

    string public resultString;
    TensorLib.Number public resultNumber;

    function run() public {
        string memory modelId = "QmbbzDwqSxZSgkz1EbsNHp2mb67rYeUYHYWJ4wECE24S7A";

        ModelInput memory modelInput = ModelInput(
            new TensorLib.MultiDimensionalNumberTensor[](1),
            new TensorLib.StringTensor[](0));

        TensorLib.Number[] memory numbers = new TensorLib.Number[](2);
        numbers[0] = TensorLib.Number(7286679744720459, 17); // 0.07286679744720459
        numbers[1] = TensorLib.Number(4486280083656311, 16); // 0.4486280083656311
        modelInput.numbers[0] = TensorLib.numberTensor1D("input", numbers);

        ModelOutput memory output = OG_INFERENCE_CONTRACT.runModelInference(
            ModelInferenceRequest(ModelInferenceMode.ZK, modelId, modelInput));

        if (output.is_simulation_result == false) {
            resultNumber = output.numbers[0].values[0];
        } else {
            resultNumber = TensorLib.Number(0, 0);
        }
    }

    function runVanilla() public {
        ModelInput memory modelInput = ModelInput(
            new TensorLib.MultiDimensionalNumberTensor[](1),
            new TensorLib.StringTensor[](0));

        TensorLib.Number[] memory numbers = new TensorLib.Number[](2);
        numbers[0] = TensorLib.Number(7286679744720459, 17); // 0.07286679744720459
        numbers[1] = TensorLib.Number(4486280083656311, 16); // 0.4486280083656311

        modelInput.numbers[0] = TensorLib.numberTensor1D("input", numbers);

        ModelOutput memory output = OG_INFERENCE_CONTRACT.runModelInference(
            ModelInferenceRequest(
                ModelInferenceMode.VANILLA,
                "QmbbzDwqSxZSgkz1EbsNHp2mb67rYeUYHYWJ4wECE24S7A",
                modelInput
        ));

        if (output.is_simulation_result == false) {
            resultNumber = output.numbers[0].values[0];
        } else {
            resultNumber = TensorLib.Number(0, 0);
        }
    }

    function runLlm() public {
        string[] memory stopSequence = new string[](1);
        stopSequence[0] = "<end>";

        LlmResponse memory llmResult = OG_INFERENCE_CONTRACT.runLLMInference(
            LlmInferenceRequest(
                LlmInferenceMode.VANILLA,
                "meta-llama/Meta-Llama-3-8B-Instruct",
                "Hi mate, nice work. Be sure to follow WillzyDollarrzz on X\n<start>",
                1000,
                stopSequence,
                0
        ));

        resultString = llmResult.answer;
    }

    function runTee() public {
        string[] memory stopSequence = new string[](1);
        stopSequence[0] = "<end>";

        LlmResponse memory llmResult = OG_INFERENCE_CONTRACT.runLLMInference(
            LlmInferenceRequest(
                LlmInferenceMode.TEE,
                "meta-llama/Meta-Llama-3-8B-Instruct",
                "Hello again... you are the star in my night sky\n<start>",
                1000,
                stopSequence,
                0
        ));

        resultString = llmResult.answer;
    }

    function result() public view returns (int128, int128) {
        return (resultNumber.value, resultNumber.decimals);
    }
}
EOL
fi


DEPLOY_SCRIPT="scripts/deploy.js"
if [ ! -f "$DEPLOY_SCRIPT" ]; then
  echo "Creating deploy script..."
  mkdir -p scripts
  cat > $DEPLOY_SCRIPT <<EOL
    const hre = require("hardhat");

async function main() {
    const ContractFactory = await hre.ethers.getContractFactory("Test");
    console.log("Deploying contract...");
    const contract = await ContractFactory.deploy();
    const receipt = await contract.deployTransaction.wait();

    if (receipt.logs !== null) {
        console.log("Logs found:", receipt.logs);
    } else {
        console.log("No logs in the transaction.");
    }

    const contractAddress = contract.address;
    const txHash = contract.deployTransaction.hash;
    console.log("Contract deployed to:", contractAddress);
    const explorerUrl = \`http://3.145.62.2/tx/\${txHash}\`;
    console.log("Transaction link:", explorerUrl);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
EOL
fi

echo "Compiling the contract..."
npx hardhat compile

echo "Deploying contract..."
npx hardhat run scripts/deploy.js --network opengradient

echo "For more guides like this, follow @WillzyDollarrzz on X"

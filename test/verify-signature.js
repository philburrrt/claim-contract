const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Verify Signature", function () {
  it("Check signature", async function () {
    const accounts = await ethers.getSigners(2);
    const VerifySignature = await ethers.getContractFactory("VerifySig");
    const verify = await VerifySignature.deploy();

    //     // const PRIV_KEY = "0x..."
    //     // const signer = new ethers.Wallet(PRIV_KEY)
    const signer = accounts[0];
    const signerAddress = accounts[0].address;
    const to = accounts[1].address;
    const amount = 999;

    console.log(
      "\n signerAddress: ",
      signerAddress,
      "\n to: ",
      to,
      "\n amount: ",
      amount
    );

    // hash = signature without contract
    // contractHash = signature with contract
    // they both match
    const hash = ethers.utils.solidityKeccak256(
      ["address", "uint256"],
      [to, amount]
    );

    // append \x19Ethereum Signed Message:\n32 to hash

    // sign the hash with the signer
    const signature = await signer.signMessage(ethers.utils.arrayify(hash));

    // replicate getEthSignedMessageHash
    const ethSignedHash = ethers.utils.solidityKeccak256(
      ["string", "bytes"],
      ["\x19Ethereum Signed Message:\n32", signature]
    );

    console.log(
      "\n hash: ",
      hash,
      "\n signature: ",
      signature,
      "\n ethSignedHash: ",
      ethSignedHash
    );

    // verify that the message was signed by the signer
    const isValid = await verify.verify(signerAddress, to, amount, signature);
    expect(isValid).to.equal(true);
  });

  it("Claims 999 tokens from the contract", async function () {
    const accounts = await ethers.getSigners(2);
    const VerifySignature = await ethers.getContractFactory("VerifySig");
    const verify = await VerifySignature.deploy();
    await verify.deployed();
    const MetaverseToken = await ethers.getContractFactory("MetaverseToken");
    const token = await MetaverseToken.deploy();
    await token.deployed();

    const signer = accounts[0];
    const signerAddress = accounts[0].address;
    const to = accounts[1].address;
    const amount = 999;

    const message = ethers.utils.solidityKeccak256(
      ["address", "uint256"],
      [to, amount]
    );

    const signature = await signer.signMessage(ethers.utils.arrayify(message));

    // log signers eth balance
    const ethBalance = await signer.getBalance();
    console.log("\n ethBalance: ", ethers.utils.formatEther(ethBalance));
  });
});

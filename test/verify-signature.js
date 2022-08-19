const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Verify Signature", function () {
  it("Check signature", async function () {
    const accounts = await ethers.getSigners(2);
    const VerifySignature = await ethers.getContractFactory("VerifySig");
    const verify = await VerifySignature.deploy();
    const MetaverseToken = await ethers.getContractFactory("MetaverseToken");
    const token = await MetaverseToken.deploy(accounts[0].address);

    //     // const PRIV_KEY = "0x..."
    //     // const signer = new ethers.Wallet(PRIV_KEY)
    const signer = accounts[0];
    const signerAddress = accounts[0].address;
    const to = "0x377acc3717a67e2f5d8e7818c0360bcdf0e17af4";
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

    // claim tokens from the contract
    await token.bootstrapClaim(to, amount, signature);

    // verify that 999 tokens were claimed
    const balance = await token.balanceOf(to);
    expect(balance.toNumber()).to.equal(amount);
  });
});

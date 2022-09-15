const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Verify Signature", function () {
  it("Claim", async function () {

    const accounts = await ethers.getSigners(2);
    const signer = accounts[0];
    const signerAddress = accounts[0].address;

    const MetaverseToken = await ethers.getContractFactory("MetaverseToken");
    const token = await MetaverseToken.deploy();
    const Distributor = await ethers.getContractFactory("Distributor");
    const distributor = await Distributor.deploy(signerAddress, token.address);

    const to = "0x377acc3717a67e2f5d8e7818c0360bcdf0e17af4";
    const amount = 999;

    await token.bootstrapMint([signerAddress], [amount]);
    await token.approve(distributor.address, amount);
    await distributor.refill(amount);

    // hash = signature without contract
    // contractHash = signature with contract
    // they both match
    const hash = ethers.utils.solidityKeccak256(
      ["address", "uint256"],
      [to, amount]
    );

    // sign the hash with the signer
    const signature = await signer.signMessage(ethers.utils.arrayify(hash));

    // claim tokens from the contract
    await distributor.claim(to, amount, signature);

    // verify that 999 tokens were claimed
    const balance = await token.balanceOf(to);
    expect(balance.toNumber()).to.equal(amount);
  });

  it("Claim, refill then try to claim again with OG signature", async function () {
    const accounts = await ethers.getSigners(2);
    const signer = accounts[0];
    const signerAddress = accounts[0].address;

    const MetaverseToken = await ethers.getContractFactory("MetaverseToken");
    const token = await MetaverseToken.deploy();
    const Distributor = await ethers.getContractFactory("Distributor");
    const distributor = await Distributor.deploy(signerAddress, token.address);

    const to = "0x377acc3717a67e2f5d8e7818c0360bcdf0e17af4";
    const amount = 999;

    await token.bootstrapMint([signerAddress], [amount]);
    await token.approve(distributor.address, amount);
    await distributor.refill(amount);

    // hash = signature without contract
    // contractHash = signature with contract
    // they both match
    const hash = ethers.utils.solidityKeccak256(
      ["address", "uint256"],
      [to, amount]
    );

    // sign the hash with the signer
    const signature = await signer.signMessage(ethers.utils.arrayify(hash));

    // claim tokens from the contract
    await distributor.claim(to, amount, signature);

    // verify that 999 tokens were claimed
    const balance = await token.balanceOf(to);
    expect(balance.toNumber()).to.equal(amount);

    // mint to signer, refill distributor
    await token.bootstrapMint([signerAddress], [amount]);
    await token.approve(distributor.address, amount);
    await distributor.refill(amount);

    // claim again, expect failure

    await expect(distributor.claim(to, amount, signature)).to.be.revertedWith("You have claimed all owed tokens");

  });

  it("Claim, refill then try to claim again with new signature", async function () {
    const accounts = await ethers.getSigners(2);
    const signer = accounts[0];
    const signerAddress = accounts[0].address;

    const MetaverseToken = await ethers.getContractFactory("MetaverseToken");
    const token = await MetaverseToken.deploy();
    const Distributor = await ethers.getContractFactory("Distributor");
    const distributor = await Distributor.deploy(signerAddress, token.address);

    const to = "0x377acc3717a67e2f5d8e7818c0360bcdf0e17af4";
    const amount = 999;

    await token.bootstrapMint([signerAddress], [amount]);
    await token.approve(distributor.address, amount);
    await distributor.refill(amount);

    // hash = signature without contract
    // contractHash = signature with contract
    // they both match
    const hash = ethers.utils.solidityKeccak256(
      ["address", "uint256"],
      [to, amount]
    );

    // sign the hash with the signer
    const signature = await signer.signMessage(ethers.utils.arrayify(hash));

    // claim tokens from the contract
    await distributor.claim(to, amount, signature);

    // verify that 999 tokens were claimed
    const balance = await token.balanceOf(to);
    expect(balance.toNumber()).to.equal(amount);

    // write new signature for double last amount. it should only allow 'to' to claim the difference between OG signature and new signature

    const newHash = ethers.utils.solidityKeccak256(
      ["address", "uint256"],
      [to, amount * 2]
    );

    const newSignature = await signer.signMessage(ethers.utils.arrayify(newHash));

    // mint to signer, refill distributor
    await token.bootstrapMint([signerAddress], [amount]);
    await token.approve(distributor.address, amount);
    await distributor.refill(amount);

    // claim again with new signature, expect success

    await distributor.claim(to, amount * 2, newSignature);

  });
});

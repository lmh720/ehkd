const { ethers } = require("ethers");

// Connect to provider and signer
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const userAddress = await signer.getAddress();

// Token and contract addresses
const tokenAddress = "0xTokenAddress";
const contractAddress = "0xYourContractAddress";

// 1. Get token details
const tokenContract = new ethers.Contract(
  tokenAddress,
  ["function name() view returns (string)", "function nonces(address) view returns (uint256)"],
  provider
);

const tokenName = await tokenContract.name();
const chainId = (await provider.getNetwork()).chainId;
const nonce = await tokenContract.nonces(userAddress);

// 2. Set up EIP-712 domain
const domain = {
  name: tokenName,
  version: "1",
  chainId: chainId,
  verifyingContract: tokenAddress
};

// 3. Define the permit message
const amount = ethers.utils.parseUnits("1.0", 18); // 1 token (adjust decimals)
const deadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

const message = {
  owner: userAddress,
  spender: contractAddress,
  value: amount.toString(),
  nonce: nonce.toString(),
  deadline: deadline
};

// 4. Get the signature
const signature = await signer._signTypedData(
  {
    name: tokenName,
    version: "1",
    chainId: chainId,
    verifyingContract: tokenAddress
  },
  {
    Permit: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
      { name: "value", type: "uint256" },
      { name: "nonce", type: "uint256" },
      { name: "deadline", type: "uint256" }
    ]
  },
  message
);

// 5. Split the signature
const { v, r, s } = ethers.utils.splitSignature(signature);

console.log("Signature components:");
console.log("v:", v);
console.log("r:", r);
console.log("s:", s);
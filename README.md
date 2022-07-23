# Park2Earn smart contracts

- copy .env.example properties to .env and populate them

Harhdat common commands:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

### Deploy to local node

npx hardhat run --network hardhat scripts/deploy.ts

## Verify smart contract

npx hardhat verify --constructor-args arguments.js DEPLOYED_SMART_CONTRACT_ADDRESS

- put arguments.js file in root folder
- populate with:
  `module.exports = ["arg 1", "arg 2"...]`;

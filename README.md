# Smart Contract for Tournaments

### Contains:
- The contract, supporting upgradeability
- Explorer Verification script
- Upgrade script

### Setup 
- `npm install`
- create a `.env` in the root directory. Refer `.env_sample`
- `npx hardhat compile`

### To deploy (Auto verification):
```
npx hardhat run --network polygonTestnet scripts/deploy.js
```

### To upgrade
```
npx hardhat run --network polygonTestnet scripts/upgrade.js
```
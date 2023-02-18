import hardhat, { ethers, upgrades } from "hardhat"

async function main() {
  await hardhat.run("compile")

  const Tournaments = await ethers.getContractFactory("Tournaments")

  const tournaments = await upgrades.upgradeProxy("0x3dD526E032b176173669F83F362e2AEfD23e0422", Tournaments) // , {timeout:0}
  console.log("Tournaments upgraded")

  // verification
  await new Promise(r => setTimeout(r, 10000));
  await hardhat.run("verify:verify", {
    address: tournaments.address, constructorArguments: []
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

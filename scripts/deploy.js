import hardhat, { ethers, upgrades } from "hardhat"

const tournamentParams = {
  games: [
    [3, "Trio"],
    [2, "Duo"]
  ],
}


async function main() {
  await deploy()
}

const deploy = async () => {
  await hardhat.run("compile")
  const tournamentFactory = await ethers.getContractFactory("Tournaments")

  console.log("Deploying:")

  const initializerArguments = [
    tournamentParams.games,
  ]
  const tournaments = await upgrades.deployProxy(tournamentFactory, initializerArguments, {
    initializer: "__Tournaments_init",
  })
  await tournaments.deployed()
  console.log("--------Contract deployed at:", tournaments.address)

  // verification
  await new Promise(r => setTimeout(r, 10000));
  await hardhat.run("verify:verify", {
    address: tournaments.address, constructorArguments: []
  })

  return tournaments.address
}


if (require.main == module) {
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
}

module.exports = deploy
import { FoundryDeployer } from "@adraffy/blocksmith";
import { createInterface } from "node:readline/promises";
import { readFile } from "node:fs/promises";
import { JsonRpcProvider } from "ethers";

const rl = createInterface({
	input: process.stdin,
	output: process.stdout,
});

const payloads = JSON.parse(
	await readFile(new URL("../payload.json", import.meta.url))
);

const deployer = await FoundryDeployer.load({
	provider: new JsonRpcProvider("https://sepolia.drpc.org", 11155111, {
		staticNetwork: true,
	}),
	privateKey: await rl.question("Private Key (empty to simulate): "),
});

const deployable = await deployer.prepare({ file: "Florentines" });

if (deployer.privateKey) {
	await rl.question("Ready? (abort to stop) ");
	const { contract } = await deployable.deploy();
	const apiKey = await rl.question("Etherscan API Key: ");
	if (apiKey) {
		await deployable.verifyEtherscan({ apiKey });
	}
	for (const p of payloads) {
		const tx = await contract.loadPayload(p);
		console.log(tx.hash);
		await tx.wait();
	}
}
rl.close();

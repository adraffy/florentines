import { Foundry } from "@adraffy/blocksmith";
import { readFile, writeFile } from "node:fs/promises";

const foundry = await Foundry.launch({
	//procLog: true
	infoLog: true,
});

const Florentines = await foundry.deploy({ file: "Florentines" });

const payloads = JSON.parse(
	await readFile(new URL("../payload.json", import.meta.url))
);

for (const p of payloads) {
	await foundry.confirm(Florentines.loadLayerData(p), { silent: true });
}

// function rng(max, min = 0) {
// 	return min + Math.floor(Math.random() * max);
// }

// const dna = hexlify(new Uint8Array([
// 	rng(35, 1), // bg
// 	rng(7, 1), // guy
// 	rng(9), // neck
// 	rng(40), // head
// 	rng(38), // eyes
// 	rng(28) // mouth
// ]));

// console.log(dna);

//foundry.provider.on('debug', x => console.log(x));

for (let i = 0; i < 5; i++) {
	await foundry.confirm(Florentines.mint({ gasLimit: 150000n }));
}

if (1) {
	const metadata = await Florentines.tokenURI(0);

	await writeFile(
		new URL("../preview.html", import.meta.url),
		`<!DOCTYPE html>
	<html>
	<body>
	<script type="module">
	const {image, ...rest} = await fetch("${metadata}").then(r => r.json());
	const pre = document.createElement('pre');
	pre.innerText = JSON.stringify(rest, null, '  ');
	const img = new Image();
	img.src = image;
	document.body.append(pre, img);
	</script>
	</body>
	</html>`
	);
}

//await writeFile(new URL('../data-url.txt', import.meta.url), svg);

await foundry.shutdown();

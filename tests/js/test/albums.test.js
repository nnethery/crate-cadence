import path from "path";

import { emulator, init, getAccountAddress, shallPass, shallResolve, shallRevert } from "flow-js-testing";

import { getAdminAddress } from "../src/common";
import {
	deployAlbums,
	getAlbum,
	getAlbumCount,
	getAlbumSupply,
	mintAlbum,
	setupAlbumsOnAccount,
	transferAlbum,
	typeID1,
} from "../src/albums";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(50000);

describe("Albums", () => {
	// Instantiate emulator and path to Cadence files
	beforeEach(async () => {
		const basePath = path.resolve(__dirname, "../../../");
		const port = 7002;
		await init(basePath, { port });
		return emulator.start(port, false);
	});

	// Stop emulator, so it could be restarted
	afterEach(async () => {
		return emulator.stop();
	});

	it("shall deploy KittyItems contract", async () => {
		await deployAlbums();
	});

	it("supply shall be 0 after contract is deployed", async () => {
		// Setup
		await deployAlbums();
		const Admin = await getAdminAddress();
		await shallPass(setupAlbumsOnAccount(Admin));

		await shallResolve(async () => {
			const supply = await getAlbumSupply();
			expect(supply).toBe(0);
		});
	});

	it("shall be able to mint a kittyItems", async () => {
		// Setup
		await deployAlbums();
		const Alice = await getAccountAddress("Alice");
		await setupAlbumsOnAccount(Alice);
		const itemIdToMint = typeID1;
		const serialNo = '1';

		// Mint instruction for Alice account shall be resolved
		await shallPass(mintAlbum(itemIdToMint, serialNo, Alice));
	});

	it("shall be able to create a new empty NFT Collection", async () => {
		// Setup
		await deployAlbums();
		const Alice = await getAccountAddress("Alice");
		await setupAlbumsOnAccount(Alice);

		// shall be able te read Alice collection and ensure it's empty
		await shallResolve(async () => {
			const itemCount = await getAlbumCount(Alice);
			expect(itemCount).toBe(0);
		});
	});

	it("shall not be able to withdraw an NFT that doesn't exist in a collection", async () => {
		// Setup
		await deployAlbums();
		const Alice = await getAccountAddress("Alice");
		const Bob = await getAccountAddress("Bob");
		await setupAlbumsOnAccount(Alice);
		await setupAlbumsOnAccount(Bob);

		// Transfer transaction shall fail for non-existent item
		await shallRevert(transferAlbum(Alice, Bob, 1337));
	});

	it("shall be able to withdraw an NFT and deposit to another accounts collection", async () => {
		await deployAlbums();
		const Alice = await getAccountAddress("Alice");
		const Bob = await getAccountAddress("Bob");
		await setupAlbumsOnAccount(Alice);
		await setupAlbumsOnAccount(Bob);

		const serialNo = '1';

		// Mint instruction for Alice account shall be resolved
		await shallPass(mintAlbum(typeID1, serialNo, Alice));

		// Transfer transaction shall pass
		await shallPass(transferAlbum(Alice, Bob, 0));
	});
});

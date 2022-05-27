import path from "path";

import { emulator, init, getAccountAddress, shallPass, shallResolve, shallRevert } from "flow-js-testing";

import { toUFix64, getAdminAddress } from "../src/common";
import {
	setupCrateUtilityCoinOnAccount,
	getCrateUtilityCoinBalance,
	getCrateUtilityCoinSupply,
	mintCrateUtilityCoin,
	transferCrateUtilityCoin,
	deployCrateUtilityCoin,
} from "../src/crate-utlity-coin";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(500000);

describe("CrateUtilityCoin", () => {
	// Instantiate emulator and path to Cadence files
	beforeEach(async () => {
		const basePath = path.resolve(__dirname, "../../../");
		const port = 7001;
		await init(basePath, { port });
		return emulator.start(port, false);
	});

	// Stop emulator, so it could be restarted
	afterEach(async () => {
		return emulator.stop();
	});

	it("shall have initialized supply field correctly", async () => {
		// Deploy contract
		await shallPass(deployCrateUtilityCoin());

		await shallResolve(async () => {
			const supply = await getCrateUtilityCoinSupply();
			expect(supply).toBe(toUFix64(0));
		});
	});

	it("shall be able to create empty Vault that doesn't affect supply", async () => {
		// Setup
		await deployCrateUtilityCoin();
		const Alice = await getAccountAddress("Alice");
		await shallPass(setupCrateUtilityCoinOnAccount(Alice));

		await shallResolve(async () => {
			const supply = await getCrateUtilityCoinSupply();
			const aliceBalance = await getCrateUtilityCoinBalance(Alice);
			expect(supply).toBe(toUFix64(0));
			expect(aliceBalance).toBe(toUFix64(0));
		});
	});

	it("shall not be able to mint zero tokens", async () => {
		// Setup
		await deployCrateUtilityCoin();
		const Alice = await getAccountAddress("Alice");
		await setupCrateUtilityCoinOnAccount(Alice);

		// Mint instruction with amount equal to 0 shall be reverted
		await shallRevert(mintCrateUtilityCoin(Alice, toUFix64(0)));
	});

	it("shall mint tokens, deposit, and update balance and total supply", async () => {
		// Setup
		await deployCrateUtilityCoin();
		const Alice = await getAccountAddress("Alice");
		await setupCrateUtilityCoinOnAccount(Alice);
		const amount = toUFix64(50);

		// Mint Kibble tokens for Alice
		await shallPass(mintCrateUtilityCoin(Alice, amount));

		// Check Kibble total supply and Alice's balance
		await shallResolve(async () => {
			// Check Alice balance to equal amount
			const balance = await getCrateUtilityCoinBalance(Alice);
			expect(balance).toBe(amount);

			// Check Kibble supply to equal amount
			const supply = await getCrateUtilityCoinSupply();
			expect(supply).toBe(amount);
		});
	});

	it("shall not be able to withdraw more than the balance of the Vault", async () => {
		// Setup
		await deployCrateUtilityCoin();
		const KittyAdmin = await getAdminAddress();
		const Alice = await getAccountAddress("Alice");
		await setupCrateUtilityCoinOnAccount(KittyAdmin);
		await setupCrateUtilityCoinOnAccount(Alice);

		// Set amounts
		const amount = toUFix64(1000);
		const overflowAmount = toUFix64(30000);

		// Mint instruction shall resolve
		await shallResolve(mintCrateUtilityCoin(KittyAdmin, amount));

		// Transaction shall revert
		await shallRevert(transferCrateUtilityCoin(KittyAdmin, Alice, overflowAmount));

		// Balances shall be intact
		await shallResolve(async () => {
			const aliceBalance = await getCrateUtilityCoinBalance(Alice);
			expect(aliceBalance).toBe(toUFix64(0));

			const KittyAdminBalance = await getCrateUtilityCoinBalance(KittyAdmin);
			expect(KittyAdminBalance).toBe(amount);
		});
	});

	it("shall be able to withdraw and deposit tokens from a Vault", async () => {
		await deployCrateUtilityCoin();
		const KittyAdmin = await getAdminAddress();
		const Alice = await getAccountAddress("Alice");
		await setupCrateUtilityCoinOnAccount(KittyAdmin);
		await setupCrateUtilityCoinOnAccount(Alice);
		await mintCrateUtilityCoin(KittyAdmin, toUFix64(1000));

		await shallPass(transferCrateUtilityCoin(KittyAdmin, Alice, toUFix64(300)));

		await shallResolve(async () => {
			// Balances shall be updated
			const KittyAdminBalance = await getCrateUtilityCoinBalance(KittyAdmin);
			expect(KittyAdminBalance).toBe(toUFix64(700));

			const aliceBalance = await getCrateUtilityCoinBalance(Alice);
			expect(aliceBalance).toBe(toUFix64(300));

			const supply = await getCrateUtilityCoinSupply();
			expect(supply).toBe(toUFix64(1000));
		});
	});
});

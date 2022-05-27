import { deployContractByName, executeScript, mintFlow, sendTransaction } from "flow-js-testing";
import { getAdminAddress } from "./common";

/*
 * Deploys Kibble contract to KittyAdmin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployCrateUtilityCoin = async () => {
	const Admin = await getAdminAddress();
	await mintFlow(Admin, "10.0");

	return deployContractByName({ to: Admin, name: "CrateUtilityCoin" });
};

/*
 * Setups Kibble Vault on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupCrateUtilityCoinOnAccount = async (account) => {
	const name = "crateUtilityCoin/setup_account"; // Note, name of the filepath of .cdc
	const signers = [account];

	return sendTransaction({ name, signers });
};

/*
 * Returns Kibble balance for **account**.
 * @param {string} account - account address
 * @throws Will throw an error if execution will be halted
 * @returns {UFix64}
 * */
export const getCrateUtilityCoinBalance = async (account) => {
	const name = "crateUtilityCoin/get_balance";
	const args = [account];

	return executeScript({ name, args });
};

/*
 * Returns Kibble supply.
 * @throws Will throw an error if execution will be halted
 * @returns {UFix64}
 * */
export const getCrateUtilityCoinSupply = async () => {
	const name = "crateUtilityCoin/get_supply";
	return executeScript({ name });
};

/*
 * Mints **amount** of Kibble tokens and transfers them to recipient.
 * @param {string} recipient - recipient address
 * @param {string} amount - UFix64 amount to mint
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const mintCrateUtilityCoin = async (recipient, amount) => {
	const Admin = await getAdminAddress();

	const name = "crateUtilityCoin/mint_tokens";
	const args = [recipient, amount];
	const signers = [Admin];

	return sendTransaction({ name, args, signers });
};

/*
 * Transfers **amount** of Kibble tokens from **sender** account to **recipient**.
 * @param {string} sender - sender address
 * @param {string} recipient - recipient address
 * @param {string} amount - UFix64 amount to transfer
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const transferCrateUtilityCoin = async (sender, recipient, amount) => {
	const name = "crateUtilityCoin/transfer_tokens";
	const args = [amount, recipient];
	const signers = [sender];

	return sendTransaction({ name, args, signers });
};

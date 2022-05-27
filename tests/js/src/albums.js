import { deployContractByName, executeScript, mintFlow, sendTransaction } from "flow-js-testing";

import { getAdminAddress } from "./common";

// KittyItems types
export const typeID1 = '1000';

/*
 * Deploys NonFungibleToken and KittyItems contracts to KittyAdmin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployAlbums = async () => {
	const Admin = await getAdminAddress();
	await mintFlow(Admin, "10.0");

	await deployContractByName({ to: Admin, name: "NonFungibleToken" });

	const addressMap = { NonFungibleToken: Admin };
	return deployContractByName({ to: Admin, name: "Albums", addressMap });
};

/*
 * Setups KittyItems collection on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupAlbumsOnAccount = async (account) => {
	const name = "albums/setup_account";
	const signers = [account];

	return sendTransaction({ name, signers });
};

/*
 * Returns KittyItems supply.
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64} - number of NFT minted so far
 * */
export const getAlbumSupply = async () => {
	const name = "albums/get_albums_supply";

	return executeScript({ name });
};

/*
 * Mints KittyItem of a specific **itemType** and sends it to **recipient**.
 * @param {UInt64} itemType - type of NFT to mint
 * @param {string} recipient - recipient account address
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const mintAlbum = async (itemType, serialNo, recipient) => {
	const Admin = await getAdminAddress();

	const name = "albums/mint_album";
	const args = [recipient, itemType, serialNo];
	const signers = [Admin];

	return sendTransaction({ name, args, signers });
};

/*
 * Transfers KittyItem NFT with id equal **itemId** from **sender** account to **recipient**.
 * @param {string} sender - sender address
 * @param {string} recipient - recipient address
 * @param {UInt64} itemId - id of the item to transfer
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const transferAlbum = async (sender, recipient, itemId) => {
	const name = "albums/transfer_album";
	const args = [recipient, itemId];
	const signers = [sender];

	return sendTransaction({ name, args, signers });
};

/*
 * Returns the KittyItem NFT with the provided **id** from an account collection.
 * @param {string} account - account address
 * @param {UInt64} itemID - NFT id
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getAlbum = async (account, itemID) => {
	const name = "albums/get_album";
	const args = [account, itemID];

	return executeScript({ name, args });
};

/*
 * Returns the number of Kitty Items in an account's collection.
 * @param {string} account - account address
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getAlbumCount = async (account) => {
	const name = "albums/get_collection_length";
	const args = [account];

	return executeScript({ name, args });
};

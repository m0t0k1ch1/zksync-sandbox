// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.23;

import {BOOTLOADER_FORMAL_ADDRESS} from "@matterlabs/zksync-contracts/l2/system-contracts/Constants.sol";
import {ACCOUNT_VALIDATION_SUCCESS_MAGIC, IAccount} from "@matterlabs/zksync-contracts/l2/system-contracts/interfaces/IAccount.sol";
import {Transaction} from "@matterlabs/zksync-contracts/l2/system-contracts/libraries/TransactionHelper.sol";

import "@openzeppelin/contracts/interfaces/IERC1271.sol";

import "./Constants.sol";

error InvalidBootloader(address bootloader);

contract MinimalZKSyncAccount is IAccount, IERC1271 {
    modifier onlyBootloader() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS) {
            revert InvalidBootloader(msg.sender);
        }
        _;
    }

    function validateTransaction(
        bytes32,
        bytes32,
        Transaction calldata
    ) external payable override onlyBootloader returns (bytes4) {
        return ACCOUNT_VALIDATION_SUCCESS_MAGIC;
    }

    function executeTransaction(
        bytes32,
        bytes32,
        Transaction calldata
    ) external payable override onlyBootloader {}

    function executeTransactionFromOutside(
        Transaction calldata
    ) external payable override {}

    function payForTransaction(
        bytes32,
        bytes32,
        Transaction calldata
    ) external payable override onlyBootloader {}

    function prepareForPaymaster(
        bytes32,
        bytes32,
        Transaction calldata
    ) external payable override onlyBootloader {}

    function isValidSignature(
        bytes32,
        bytes memory
    ) external pure override returns (bytes4) {
        return EIP1271_SUCCESS_MAGIC;
    }
}

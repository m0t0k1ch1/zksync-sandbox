// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.23;

import {BOOTLOADER_FORMAL_ADDRESS, DEPLOYER_SYSTEM_CONTRACT, NONCE_HOLDER_SYSTEM_CONTRACT} from "@matterlabs/zksync-contracts/l2/system-contracts/Constants.sol";
import {ACCOUNT_VALIDATION_SUCCESS_MAGIC, IAccount} from "@matterlabs/zksync-contracts/l2/system-contracts/interfaces/IAccount.sol";
import {INonceHolder} from "@matterlabs/zksync-contracts/l2/system-contracts/interfaces/INonceHolder.sol";
import {SystemContractsCaller} from "@matterlabs/zksync-contracts/l2/system-contracts/libraries/SystemContractsCaller.sol";
import {Transaction, TransactionHelper} from "@matterlabs/zksync-contracts/l2/system-contracts/libraries/TransactionHelper.sol";
import {Utils} from "@matterlabs/zksync-contracts/l2/system-contracts/libraries/Utils.sol";

import "@openzeppelin/contracts/interfaces/IERC1271.sol";

import "./Constants.sol";

error InvalidBootloader(address);
error InsufficientBalance(uint256 available, uint256 required);
error TransactionFailed();

contract MinimalAccount is IAccount, IERC1271 {
    using TransactionHelper for Transaction;

    modifier onlyBootloader() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS) {
            revert InvalidBootloader(msg.sender);
        }
        _;
    }

    function validateTransaction(
        bytes32,
        bytes32,
        Transaction calldata tx_
    ) external payable override onlyBootloader returns (bytes4) {
        return _validateTransaction(tx_);
    }

    function executeTransaction(
        bytes32,
        bytes32,
        Transaction calldata tx_
    ) external payable override onlyBootloader {
        _executeTransaction(tx_);
    }

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

    function _validateTransaction(
        Transaction calldata tx_
    ) private returns (bytes4) {
        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()),
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0,
            abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (tx_.nonce))
        );

        uint256 availableBalance = address(this).balance;
        uint256 requiredBalance = tx_.totalRequiredBalance();

        if (availableBalance < requiredBalance) {
            revert InsufficientBalance(availableBalance, requiredBalance);
        }

        return ACCOUNT_VALIDATION_SUCCESS_MAGIC;
    }

    function _executeTransaction(Transaction calldata tx_) private {
        address to = address(uint160(tx_.to));
        uint128 value = Utils.safeCastToU128(tx_.value);
        bytes memory data = tx_.data;

        if (to == address(DEPLOYER_SYSTEM_CONTRACT)) {
            SystemContractsCaller.systemCallWithPropagatedRevert(
                Utils.safeCastToU32(gasleft()),
                to,
                value,
                data
            );
        } else {
            bool success;
            assembly {
                success := call(
                    gas(),
                    to,
                    value,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
            }
            if (!success) {
                revert TransactionFailed();
            }
        }
    }
}

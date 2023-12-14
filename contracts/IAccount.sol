// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.23;

import "./Transaction.sol";

bytes4 constant ACCOUNT_VALIDATION_SUCCESS_MAGIC = IAccount
    .validateTransaction
    .selector;

interface IAccount {
    function validateTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable returns (bytes4 magic);

    function executeTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable;

    function executeTransactionFromOutside(
        Transaction calldata _transaction
    ) external payable;

    function payForTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable;

    function prepareForPaymaster(
        bytes32 _txHash,
        bytes32 _possibleSignedHash,
        Transaction calldata _transaction
    ) external payable;
}

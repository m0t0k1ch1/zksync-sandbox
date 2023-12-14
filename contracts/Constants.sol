// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.23;

uint160 constant SYSTEM_CONTRACTS_OFFSET = 0x8000;

address payable constant BOOTLOADER_FORMAL_ADDRESS = payable(
    address(SYSTEM_CONTRACTS_OFFSET + 0x01)
);

bytes4 constant EIP1271_SUCCESS_MAGIC = 0x1626ba7e;

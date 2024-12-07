// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IFluentToken} from "../interfaces/token/IFluentToken.sol";
import {IFluentProvider} from "../interfaces/provider/IFluentProvider.sol";
import {IFluentHost} from "../interfaces/host/IFluentHost.sol";
import {FluentHostable} from "../host/FluentHostable.sol";

import "hardhat/console.sol";

contract FluentToken is
    IFluentToken,
    ERC20Upgradeable,
    FluentHostable,
    UUPSUpgradeable
{
    using SafeERC20 for IERC20Metadata;

    IERC20Metadata public underlying;

    mapping(address => uint256) buffer;

    function initialize(
        IFluentHost host_,
        IERC20Metadata token_,
        string calldata name_,
        string calldata symbol_
    ) external initializer {
        underlying = token_;

        __Context_init();
        __UUPSUpgradeable_init();
        __ERC20_init(name_, symbol_);
        __FluentHostable_init(host_);
    }

    /**
     * @dev Allow a user to deposit, and wrap the underlying token
     */
    function deposit(uint256 value) external {
        address sender = _msgSender();

        SafeERC20.safeTransferFrom(underlying, sender, address(this), value);
        _mint(sender, value);
    }

    /**
     * @dev Allow a user to unwrap and withdraw the underlying token
     */
    function withdraw(uint256 value) external {
        address account = _msgSender();

        _burn(account, value);

        SafeERC20.safeTransfer(underlying, account, value);
    }

    /**
     * @dev Allow the host to decrease the account buffer.
     */
    function decreaseBuffer(
        address account,
        uint256 value
    ) external override onlyHost {
        uint256 current = buffer[account];

        if (current < value) {
            revert InsufficientBuffer(account, current, value);
        }

        buffer[account] = current - value;
        _mint(account, value);
    }

    /**
     * @dev Allow the host to increase the account buffer.
     */
    function increaseBuffer(
        address account,
        uint256 value
    ) external override onlyHost {
        _burn(account, value);
        buffer[account] += value;
    }

    /**
     * @dev Allow the host to process transactions
     */
    function transact(
        address from,
        address to,
        uint256 value
    ) external onlyHost {
        _update(from, to, value);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}
}

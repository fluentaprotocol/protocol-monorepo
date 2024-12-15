// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IFluentToken} from "./IFluentToken.sol";
import {Bucket} from "../libraries/Bucket.sol";
import {Interval} from "../libraries/Interval.sol";

interface IFluentProvider {
    function getBucket(
        bytes32 provider,
        bytes4 bucket
    ) external returns (uint256 value, address token, address recipient, Interval interval);
}
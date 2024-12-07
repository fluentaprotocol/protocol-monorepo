// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IFluentToken} from "../token/IFluentToken.sol";
import {IFluentTokenFactory} from "../token/IFluentTokenFactory.sol";
import {IFluentProviderFactory} from "../provider/IFluentProviderFactory.sol";

interface IFluentHost {
    // function registerStream(bytes32 stream, IFluentToken token) external;
    // function deleteStream(bytes32 stream, IFluentToken token) external;
    // function tokenFactory() external view returns (IFluentTokenFactory);
    function providerFactory() external view returns (address);
}

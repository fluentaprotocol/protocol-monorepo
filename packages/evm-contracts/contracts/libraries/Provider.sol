// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import {Bucket, BucketUtils} from "./Bucket.sol";
import {BucketCollection, CollectionUtils} from "./Collection.sol";

struct Provider {
    bytes32 id;
    string name;
    address owner;
    // mapping(bytes4 group => uint) _groups;

    // groups
    BucketCollection buckets;
}

library ProviderUtils {
    using BucketUtils for Bucket;
    using CollectionUtils for *;

    error BucketAlreadyExists();
    error BucketDoesNotExist();

    event BucketCreated(bytes32 indexed provider, bytes4 bucket);

    function id(
        string calldata name,
        address account
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(account, name));
    }

    function open(
        Provider storage self,
        address owner,
        string calldata name,
        Bucket[] calldata buckets
    ) internal {
        // Update provider details
        self.id = id(name, owner);
        self.name = name;
        self.owner = owner;

        // Cache length for efficiency and iterate buckets
        uint len = buckets.length;
        for (uint i; i < len; ) {
            addBucket(self, buckets[i]);

            unchecked {
                ++i;
            }
        }
    }

    function close(Provider storage self) internal {
        delete self.owner;
        delete self.name;
        delete self.id;

        self.buckets.clear();
    }

    function exists(Provider storage self) internal view returns (bool) {
        return self.owner != address(0);
    }

    // function hasBucket(
    //     Provider storage self,
    //     bytes4 tag
    // ) internal view returns (bool) {
    //     return self.buckets.contains(tag);
    // }

    function getBucket(
        Provider storage self,
        bytes4 tag
    ) internal view returns (Bucket storage) {
        if (!self.buckets.contains(tag)) {
            revert BucketDoesNotExist();
        }

        return self.buckets.get(tag);
    }

    function addBucket(
        Provider storage self,
        Bucket calldata data
    ) internal returns (bytes4) {
        bytes4 tag = data.tag();

        if (self.buckets.contains(tag)) {
            revert BucketAlreadyExists();
        }

        self.buckets.add(tag, data);

        emit BucketCreated(self.id, tag);

        return tag;
    }

    function removeBucket(Provider storage self, bytes4 tag) internal {
        if (!self.buckets.contains(tag)) {
            revert BucketDoesNotExist();
        }

        self.buckets.remove(tag);
    }

    function modifyBucket(Provider storage self, bytes4 bucket) internal {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
/// @notice This contract is gas and security simple optimized, further improvements are appreciated
/// @dev The main purpose of this contract is to create new ERC-20 tokens to support sells
/// @custom:project This contract is part of a entire project

/// @notice Standard import for customizable ERC-20 mint
/// @dev The standard was developed by our team
import "https://github.com/insignia-assets/InsigCoop-ASSET_TOKEN/blob/main/Contracts/Asset_Token.sol";
//import "./Asset_Token.sol";

/// @title Factory to create new ERC-20 Tokens
/// @author Gustavo Henrique / gustavo@useinsignia.com
/// @notice VariableTokenFactory contract
contract AssetTokenFactory {
    /// @notice New token minted
    event NewTokenGenerated(address creator, address newTokenAddress);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    AssetToken[] public _assetTokens;

    mapping(address => uint256) public _indexOfTokensByAddress;

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    /**
     * @dev Modifier that checks that if account is the contract owner. Reverts
     * with a standardized message.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    /// @notice Method for creating new custom tokens
    /// @param _tokenName  The token name , e.g. bitcoin
    /// @param _tokenSymbol The symbol of the token , e.g. BTC
    /// @dev This contract creates other contracts, be aware of the address of the tokens generated

    function createAssetTokens(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _amountMinted,
        address payable _owner,
        address payable _feeAddress
    ) public onlyOwner {
        AssetToken newToken = new AssetToken(
            _tokenName,
            _tokenSymbol,
            _amountMinted,
            _owner,
            _feeAddress
        );

        _assetTokens.push(newToken);
        _indexOfTokensByAddress[newToken.getAddress()] = (_assetTokens.length -
            1);
        emit NewTokenGenerated(msg.sender, newToken.getAddress());
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership (address payable newOwner)
        public
        virtual
        onlyOwner
    {
        require(owner == msg.sender, "Only the owner can transfer");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address payable newOwner) internal virtual onlyOwner{
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

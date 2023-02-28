// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AssetToken is ERC20, ERC20Burnable, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant FEE_ROLE = keccak256("FEE_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    event SetWhitelistByAddress(address indexed account, bool enable);
    event SetFeeValue(uint256 feeValue);
    event SetFeeAddress(address indexed acount);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    mapping(address => bool) private _whitelist;
    address private _feeAddress;
    uint256 private _feeValue = 50; //0.5%
    uint256 public constant FEE_BASE = 10000;

    address public _owner;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _amountMinted,
        address payable owner,
        address feeAddress
    ) ERC20(_tokenName, _tokenSymbol) {
        
        _owner = owner;
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(WHITELIST_ROLE, _owner);
        _grantRole(FEE_ROLE, _owner);

        _feeAddress = feeAddress;

        _setWhitelist(_owner, true);
        _setWhitelist(_feeAddress, true);        

        _mint(_owner, _amountMinted * 10**decimals()); 
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev Returns fee
     */
    function getFee() public view returns (uint256) {
        return _feeValue;
    }

    /// @notice Public method to retrieve contract's address
    /// @return _tokenAddress Address of the token
    /// @dev This method supports VariableTokenFactory contract
    function getAddress() public view returns (address _tokenAddress) {
        _tokenAddress = address(this);
    }

    /**
     * @dev Set a new fee value.
     */
    function setFeeValue(uint256 newFee)
        public
        onlyRole(FEE_ROLE)
        returns (bool)
    {
        _feeValue = newFee;
        emit SetFeeValue(newFee);
        return true;
    }

    /**
     * @dev Set a new fee address.
     */
    function setFeeAddress(address account)
        public
        onlyRole(FEE_ROLE)
        returns (bool)
    {
        _feeAddress = account;
        emit SetFeeAddress(account);
        return true;
    }

    /**
     * @dev Returns fee address
     */
    function getFeeAddress() public view returns (address) {
        return _feeAddress;
    }

    /**
     * @dev Returns if the address belongs to the whitelist
     */
    function _isWhitelist(address account) private view returns (bool) {
        return _whitelist[account];
    }

    /**
     * @dev Returns if the address belongs to the whitelist
     */
    function isWhitelist(address account) public view returns (bool) {
        return _isWhitelist(account);
    }

    /**
     * @dev Set the address to the whitelist
     */
    function setWhitelist(address account, bool enable)
        public
        onlyRole(WHITELIST_ROLE)
        returns (bool)
    {
        _setWhitelist(account, enable);
        return true;
    }

    /**
     * @dev Sets a new account to whitelist.
     * Internal function without access restriction.
     */
    function _setWhitelist(address account, bool enable) internal {
        _whitelist[account] = enable;
        emit SetWhitelistByAddress(account, enable);
    }

    /**
     * @dev Override function on transfer to allow charge fees
     * Internal function without access restriction.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (_isWhitelist(from) || _isWhitelist(to)) {
            super._transfer(from, to, amount);
        } else {
            uint256 fee = (amount / FEE_BASE) * _feeValue;
            super._transfer(from, _feeAddress, fee);
            super._transfer(from, to, amount - fee);
        }
    }

    /**
     * @dev Override function on renounceRole to avoid the contract beeing withuot any admin
     */
    function renounceRole(bytes32 role, address account)
        public
        virtual
        override
    {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );
        require(_owner != account, "Impossible let the contract with no admin");
        super._revokeRole(role, account);
    }

    /**
     * @dev Override function on revokeRole to avoid the contract beeing withuot any admin
     */

    function revokeRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_owner != account, "Impossible let the contract with no admin");
        super._revokeRole(role, account);
    }

   
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner)
        public
        virtual
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_owner == msg.sender, "Only the owner can transfer");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    
}

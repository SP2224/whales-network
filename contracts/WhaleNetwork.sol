// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract WhaleNetwork is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private _serviceFeeCollector;

    string private _name;
    string private _symbol;

    uint8 private _decimals;

    uint256 public _maxTxAmount = 10 * 10**6 * 10**18;
    uint256 public _taxFee = 5;
    uint256 public _burnFee = 5;
    uint256 public _serviceFee = 10;
    uint256 private _previousBurnFee = _burnFee;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousServiceFee = _serviceFee;
    uint256 private _tFeeTotal;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private INDEX_R_AMOUNT = 0;
    uint256 private INDEX_R_TRANSFER_AMOUNT = 1;
    uint256 private INDEX_R_FEE = 2;

    constructor() {
        _name = "Whales Network";
        _symbol = "WHALES";
        _tTotal = 21 * 10**6 * 10**18;
        _rTotal = (MAX - (MAX % _tTotal));
        _decimals = 18;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tTotal;
    }

    function serviceFeeCollector() public view returns (address) {
        return _serviceFeeCollector;
    }

    function setServiceFeeCollector(address collector)
        public
        onlyOwner
        returns (bool)
    {
        _serviceFeeCollector = collector;
        return true;
    }

    function setMaxTxAmount(uint256 maxTxAmount)
        public
        onlyOwner
        returns (bool)
    {
        _maxTxAmount = maxTxAmount;
        return true;
    }

    function setTaxFee(uint256 taxFee) public onlyOwner returns (bool) {
        _taxFee = taxFee;
        return true;
    }

    function setServiceFee(uint256 serviceFee) public onlyOwner returns (bool) {
        _serviceFee = serviceFee;
        return true;
    }

    function setBurnFee(uint256 burnFee) public onlyOwner returns (bool) {
        _burnFee = burnFee;
        return true;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount, false);
        return true;
    }

    function payment(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount, true);
        return true;
    }

    function customPayment(
        address recipient,
        uint256 amount,
        uint256 taxFee,
        uint256 burnFee,
        uint256 serviceFee
    ) public returns (bool) {
        _transferCustomPayment(
            _msgSender(),
            recipient,
            amount,
            [taxFee, burnFee, serviceFee]
        );
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount, false);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount,
        bool isPayment
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (sender != owner() && recipient != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        //transfer amount, it will take tax & burn
        _tokenTransfer(sender, recipient, amount, isPayment);
    }

    function _transferCustomPayment(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256[3] memory fees
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");

        if (sender != owner() && recipient != owner())
            require(
                tAmount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tServiceFee,
            uint256 tBurn
        ) = _getValuesCustom(tAmount, fees);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeServiceFee(tServiceFee, tBurn);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _removeAllFee() private {
        if (_taxFee == 0 && _serviceFee == 0 && _burnFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousServiceFee = _serviceFee;
        _previousBurnFee = _burnFee;

        _taxFee = 0;
        _serviceFee = 0;
        _burnFee = 0;
    }

    function _restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
        _serviceFee = _previousServiceFee;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool isPayment
    ) private {
        if (!isPayment) _removeAllFee();
        _transferFinal(sender, recipient, amount, isPayment);
        if (!isPayment) _restoreAllFee();
    }

    function _getValues(uint256 tAmount, bool isPayment)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (!isPayment) {
            (
                uint256 tTransferAmount,
                uint256 tFee,
                uint256 tServiceFee
            ) = _getTValues(tAmount);
            (
                uint256 rAmount,
                uint256 rTransferAmount,
                uint256 rFee
            ) = _getRValues(tAmount, tFee, _getRate());
            return (
                rAmount,
                rTransferAmount,
                rFee,
                tTransferAmount,
                tFee,
                tServiceFee,
                0
            );
        } else {
            (
                uint256 tTransferAmount,
                uint256 tFee,
                uint256 tServiceFee,
                uint256 tBurn
            ) = _getPaymentTValues(tAmount);
            uint256[3] memory rValues = _getPaymentRValues(
                tAmount,
                tFee,
                tServiceFee,
                _getRate(),
                tBurn
            );
            return (
                rValues[INDEX_R_AMOUNT],
                rValues[INDEX_R_TRANSFER_AMOUNT],
                rValues[INDEX_R_FEE],
                tTransferAmount,
                tFee,
                tServiceFee,
                tBurn
            );
        }
    }

    function _getValuesCustom(uint256 tAmount, uint256[3] memory fees)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tServiceFee,
            uint256 tBurn
        ) = _getTValuesCustom(tAmount, fees);
        uint256[3] memory rValues = _getRValuesCustom(
            tAmount,
            tFee,
            tServiceFee,
            _getRate(),
            tBurn
        );
        return (
            rValues[INDEX_R_AMOUNT],
            rValues[INDEX_R_TRANSFER_AMOUNT],
            rValues[INDEX_R_FEE],
            tTransferAmount,
            tFee,
            tServiceFee,
            tBurn
        );
    }

    function _getTValuesCustom(uint256 tAmount, uint256[3] memory fee)
        private
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = _calculateCustomTaxFee(tAmount, fee[0]);
        uint256 tBurn = _calculateCustomBurnAmount(tAmount, fee[1]);
        uint256 tServiceFee = _calculateCustomServiceFee(tAmount, fee[2]);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tServiceFee).sub(tBurn);
        return (tTransferAmount, tFee, tServiceFee, tBurn);
    }

    function _getRValuesCustom(
        uint256 tAmount,
        uint256 tFee,
        uint256 tServiceFee,
        uint256 currentRate,
        uint256 tBurn
    ) private pure returns (uint256[3] memory) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rServiceFee = tServiceFee.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rServiceFee).sub(rBurn);
        return [rAmount, rTransferAmount, rFee];
    }

    function _calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function _calculateCustomTaxFee(uint256 _amount, uint256 taxFee)
        private
        pure
        returns (uint256)
    {
        return _amount.mul(taxFee).div(10**2);
    }

    function _calculateServiceFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_serviceFee).div(10**2);
    }

    function _calculateCustomServiceFee(uint256 _amount, uint256 serviceFee)
        private
        pure
        returns (uint256)
    {
        return _amount.mul(serviceFee).div(10**2);
    }

    function _calculateBurnAmount(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_burnFee).div(10**2);
    }

    function _calculateCustomBurnAmount(uint256 _amount, uint256 burnFee)
        private
        pure
        returns (uint256)
    {
        return _amount.mul(burnFee).div(10**2);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = _calculateTaxFee(tAmount);
        uint256 tServiceFee = _calculateServiceFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee, tServiceFee);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getPaymentTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = _calculateTaxFee(tAmount);
        uint256 tServiceFee = _calculateServiceFee(tAmount);
        uint256 tBurn = _calculateBurnAmount(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tServiceFee).sub(tBurn);
        return (tTransferAmount, tFee, tServiceFee, tBurn);
    }

    function _getPaymentRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tServiceFee,
        uint256 currentRate,
        uint256 tBurn
    ) private pure returns (uint256[3] memory) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rServiceFee = tServiceFee.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rServiceFee).sub(rBurn);
        return [rAmount, rTransferAmount, rFee];
    }

    function _transferFinal(
        address sender,
        address recipient,
        uint256 tAmount,
        bool isPayment
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tServiceFee,
            uint256 tBurn
        ) = _getValues(tAmount, isPayment);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (isPayment) _takeServiceFee(tServiceFee, tBurn);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeServiceFee(uint256 tServiceFee, uint256 tBurn) private {
        uint256 currentRate = _getRate();
        uint256 rServiceFee = tServiceFee.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[_serviceFeeCollector] = _rOwned[_serviceFeeCollector].add(
            rServiceFee
        );
        emit Transfer(_msgSender(), _serviceFeeCollector, tServiceFee);
        _rOwned[address(0)] = _rOwned[address(0)].add(rBurn);
        emit Transfer(_msgSender(), address(0), tBurn);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}

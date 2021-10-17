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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract WhaleNetworkGovernance is Context, Ownable {
    using SafeMath for uint256;

    enum ProposalStatus {
        VALID,
        FORFEITED,
        EXECUTED
    }

    enum Vote {
        AGAINST,
        FOR
    }

    struct VoteStatus {
        uint256 against;
        uint256 support;
    }

    struct Proposal {
        string title;
        string details;
        address creator;
        uint256 startBlock;
        uint256 endBlock;
        uint256 id;
        ProposalStatus status;
    }

    IERC20 public _token;

    uint256 private _minTokenForVoting;
    uint256 private _minTokenForProposal;
    uint256 public _nextProposalId = 1;

    mapping(uint256 => Proposal) _proposals;
    mapping(uint256 => VoteStatus) _votes;
    mapping(uint256 => mapping(address => bool)) _proposalVotingStatus;

    event ProposalCreated(address indexed creatorAddress, string title);
    event VoteCast(address indexed voter, uint256 weight, Vote status);
    event ProposalExecuted(uint256 proposalId);
    event ProposalForfeited(uint256 proposalId);

    constructor(
        IERC20 token,
        uint256 minForVoting,
        uint256 minForProposal
    ) {
        require(
            address(token) != address(0),
            "WhaleNetworkGovernance: Token address can not be zero address"
        );
        require(
            minForVoting > 0,
            "WhaleNetworkGovernance: Minimum tokens for voting must be greater then zero."
        );
        require(
            minForProposal > 0,
            "WhaleNetworkGovernance: Minimum tokens for creating proposals must be greater then zero."
        );
        _token = token;
        _minTokenForProposal = minForProposal * 1 ether;
        _minTokenForVoting = minForVoting * 1 ether;
    }

    function minimumTokenRequiredVoting() public view returns (uint256) {
        return _minTokenForVoting;
    }

    function minimumTokenRequiredProposal() public view returns (uint256) {
        return _minTokenForProposal;
    }

    function setMinimumTokenRequiredVoting(uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        require(
            amount > 0,
            "WhaleNetworkGovernance: Minimum tokens for voting must be greater then zero."
        );
        _minTokenForVoting = amount;
        return true;
    }

    function setMinimumTokenRequiredProposal(uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        require(
            amount > 0,
            "WhaleNetworkGovernance: Minimum tokens for creating proposals must be greater then zero."
        );
        _minTokenForProposal = amount;
        return true;
    }

    function createProposal(
        string memory proposalTitle,
        string memory proposalDetails,
        uint256 start,
        uint256 end
    ) external returns (bool) {
        require(
            bytes(proposalTitle).length > 0,
            "WhaleNetworkGovernance: Proposal Title cannot be empty"
        );
        require(
            bytes(proposalDetails).length > 0,
            "WhaleNetworkGovernance: Proposal Title cannot be empty"
        );
        require(
            _token.balanceOf(_msgSender()) >= _minTokenForProposal,
            "WhaleNetworkGovernance: Insufficient tokens for creating a proposal"
        );

        require(
            start > block.number,
            "WhaleNetworkGovernance: Start time of proposal must be in future."
        );
        require(
            end > start,
            "WhaleNetworkGovernance: End time of proposal must be after start time."
        );

        _proposals[_nextProposalId] = Proposal(
            proposalTitle,
            proposalDetails,
            _msgSender(),
            start,
            end,
            _nextProposalId,
            ProposalStatus.VALID
        );
        _nextProposalId += 1;
        emit ProposalCreated(_msgSender(), proposalTitle);
        return true;
    }

    function getProposal(uint256 proposalId)
        public
        view
        returns (Proposal memory)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        return _proposals[proposalId];
    }

    function castVote(uint256 proposalId, uint256 vote)
        external
        returns (bool)
    {
        //vote = 0 - NO
        //vote = 1 - YES
        require(
            _token.balanceOf(_msgSender()) >= _minTokenForVoting,
            "WhaleNetworkGovernance: Insufficient tokens for voting"
        );
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        require(
            !_proposalVotingStatus[proposalId][_msgSender()],
            "WhaleNetworkGovernance: You have already voted on this proposal"
        );

        VoteStatus storage proposalVote = _votes[proposalId];
        Proposal memory proposal = _proposals[proposalId];

        require(
            block.number > proposal.startBlock &&
                block.number < proposal.endBlock,
            "WhaleNetworkGovernance: Voting is not active on the proposal"
        );

        require(
            proposal.status == ProposalStatus.VALID,
            "WhaleNetworkGovernance: Votes can be casted only on the valid proposals."
        );

        _proposalVotingStatus[proposalId][_msgSender()] = true;
        if (vote == 1) {
            proposalVote.support += _token.balanceOf(_msgSender());
            emit VoteCast(
                _msgSender(),
                _token.balanceOf(_msgSender()),
                Vote.FOR
            );
        }
        if (vote == 0) {
            proposalVote.against += _token.balanceOf(_msgSender());
            emit VoteCast(
                _msgSender(),
                _token.balanceOf(_msgSender()),
                Vote.AGAINST
            );
        }
        return true;
    }

    // whether user has voted or not
    function hasVoted(address voter, uint256 proposalId)
        public
        view
        returns (bool)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        return _proposalVotingStatus[proposalId][voter];
    }

    function getResult(uint256 proposalId)
        public
        view
        returns (VoteStatus memory)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        return _votes[proposalId];
    }

    function isVotingActive(uint256 proposalId) public view returns (bool) {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        Proposal memory proposal = _proposals[proposalId];
        if (
            block.number > proposal.startBlock &&
            block.number < proposal.endBlock
        ) {
            return true;
        } else {
            return false;
        }
    }

    function isProposalPassed(uint256 proposalId) public view returns (bool) {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        VoteStatus memory voteStatus = getResult(proposalId);
        uint256 circulatingTokenSupply = _token.totalSupply().sub(
            _token.balanceOf(address(0))
        );
        if (voteStatus.support > circulatingTokenSupply.div(2)) {
            return true;
        } else {
            return false;
        }
    }

    function executeProposal(uint256 proposalId)
        external
        onlyOwner
        returns (bool)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );

        require(
            isProposalPassed(proposalId),
            "WhaleNetworkGovernance: Proposal has not passed the voting"
        );
        Proposal memory proposal = _proposals[proposalId];
        proposal.status = ProposalStatus.EXECUTED;
        _proposals[proposalId] = proposal;
        emit ProposalExecuted(proposalId);
        return true;
    }

    function forfeitProposal(uint256 proposalId) public returns (bool) {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        Proposal memory proposal = _proposals[proposalId];
        require(
            block.number < proposal.startBlock,
            "WhaleNetworkGovernance: Voting on the proposal has started and it can not be forfeited"
        );
        require(
            proposal.creator == _msgSender(),
            "WhaleNetworkGovernance: Proposal can be forfeited only by the proposal creator."
        );
        proposal.status = ProposalStatus.FORFEITED;
        _proposals[proposalId] = proposal;
        emit ProposalForfeited(proposalId);
        return true;
    }

    function proposalStartBlock(uint256 proposalId)
        public
        view
        returns (uint256)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        Proposal memory proposal = _proposals[proposalId];
        return proposal.startBlock;
    }

    function proposalEndBlock(uint256 proposalId)
        public
        view
        returns (uint256)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        Proposal memory proposal = _proposals[proposalId];
        return proposal.endBlock;
    }

    function getProposalStatus(uint256 proposalId)
        public
        view
        returns (ProposalStatus)
    {
        require(
            proposalId > 0 && proposalId < _nextProposalId,
            "WhaleNetworkGovernance: Invalid proposal Id"
        );
        Proposal memory proposal = _proposals[proposalId];
        return proposal.status;
    }
}

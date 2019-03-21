pragma solidity ^0.4.24;


/**
* @title ThorNetwork
* @author Leo
* @dev Exchange two ERC20 tokens including ETH
*/

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    uint ownerIndex = 0;                        //Owner index, the current owner number
    uint constant OWNERNUMBER = 3;              //Owner number up to 5
    address[OWNERNUMBER] owners;                //All owners
    bool public paused = false;                 //When paused = true, the contract triggers stopped state
    
    address[] operators;
    mapping(address => bool) isOperator;

    mapping (string => address) authorizedFuncOwner;    //The authorization that the owner has achieved to implement the function

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AddOwner(address indexed newOwner);
    event RemoveOwner(address indexed oldOwner);
    event AuthorizeOwner(string func, address operatingOwner);
    

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owners[0] = msg.sender;
        operators.push(msg.sender);
        isOperator[msg.sender] = true;
        ownerIndex++;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        bool isOwner = false;
        for (uint i = 0; i < OWNERNUMBER; i++) {
            if (owners[i] == msg.sender){
                isOwner = true;
                break;
            }
        }
        require(isOwner);
        _;
    }

    modifier onlyOwnerAuthorized(string func) {
        if(1 < ownerIndex){
            require(authorizedFuncOwner[func] == msg.sender);
            authorizedFuncOwner[func] = address(0);
            _;            
        }else{
            _;
        }

    }

    modifier onlyOperator() {
        require(isOperator[msg.sender]);
        _;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner onlyOwnerAuthorized("pause") whenNotPaused {
        paused = true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner onlyOwnerAuthorized("unpause") whenPaused{
        paused = false;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner onlyOwnerAuthorized("transferOwnership") {
        require(newOwner != address(0));
        for (uint i = 0; i < ownerIndex; i++) {
            if(msg.sender == owners[i]) {
                owners[i] = newOwner;
                break;
            }
        }
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    /**
     * @dev Add a new owner with ownership.
     * @param newOwner The address to ownership added
     */
    function addOwner(address newOwner) public onlyOwner onlyOwnerAuthorized("addOwner") returns(bool) {
        require(OWNERNUMBER > ownerIndex);
        require(newOwner != address(0));
        owners[ownerIndex] = newOwner;
        ownerIndex++;

        if(!isOperator[newOwner]) {
            operators.push(newOwner);
            isOperator[newOwner] = true;
        }

        emit AddOwner(newOwner);
        return true;
    }

    /**
     * @dev Remove an owner from Owners
     * @param oldOwner The owner will be removed
     */
    function removeOwner(address oldOwner) public onlyOwner onlyOwnerAuthorized("removeOwner") returns(bool) {
        require(ownerIndex >= 3);               //An owner could be removed only when there are 3 owners
        require(oldOwner != msg.sender);
        for (uint i = 0; i < ownerIndex; i++) {
            if(oldOwner != owners[i]){
                continue;
            }else {
                owners[i] = owners[ownerIndex-1];
                owners[ownerIndex-1] = address(0);
                break;
            }
        }
        ownerIndex--;

        emit RemoveOwner(oldOwner);
        return true;
    }

    /**
     * @dev Return authorizedFunc result
     * @param func Function will be carried out
     * @return Number of authorizations
     */
    function retAuthorizedFunc(string func) public view onlyOwner returns(address) {
        return authorizedFuncOwner[func];
    }

    /**
     * @dev An owner authorizes another owner to operate functions
     * @param func Function will be implemented
     * @param operatingOwner Owner who will implement the function
     * @return true
     */
    function authorizeOwner(string func, address operatingOwner) public onlyOwner returns(bool) {
        require(operatingOwner != msg.sender);               // An owner cannot authorize to himself
        require(address(0) != msg.sender);
        for(uint i = 0; i < ownerIndex; i++){                //The operatingOwner must belong to owners
            if(owners[i] == operatingOwner)
                break;
            if(i == ownerIndex-1)
                return false;
        }
        authorizedFuncOwner[func] = operatingOwner;

        emit AuthorizeOwner(func, operatingOwner);
        return true;
    }

    /**
     * @dev return a owner's address
     * @param _ownerIndex < OWNERNUMBER
     */
    function retOwners(uint _ownerIndex) onlyOwner public view returns(address) {
        require((OWNERNUMBER > _ownerIndex) && ( 0 <= _ownerIndex));
        return owners[_ownerIndex];
    }

    function addOperator(address _newOperator) public onlyOwner returns(bool) {
        require(_newOperator != address(0));
        require(!isOperator[_newOperator]);

        operators.push(_newOperator);
        isOperator[_newOperator] = true;
        return true;
    }

    function delOperator(address _oldOperator) public onlyOwner returns(bool) {
        require(isOperator[_oldOperator]);
        uint operatorNum = operators.length;
        for (uint i = 0; i < operatorNum; i++) {
            if(_oldOperator != operators[i]){
                continue;
            }else {
                operators[i] = operators[operatorNum-1];
                operators[operatorNum-1] = address(0);
                break;
            }
        }
        isOperator[_oldOperator] = false;
        operators.length--;
        return true;
    }

    function retOperators() public view onlyOwner returns(address[]) {
        return operators;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity
 */
contract StandardToken is Ownable{

    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) internal allowed;

    mapping(address => uint256) public balances;

    uint256 public totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _from, uint256 _value);

    /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    /**
     * @dev total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view whenNotPaused returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) whenNotPaused returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize (2 * 32) whenNotPaused returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public whenNotPaused {
        _burn(msg.sender, _value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param _from address The address which you want to send tokens from
     * @param _value uint256 The amount of token to be burned
     */
    function burnFrom(address _from, uint256 _value) public whenNotPaused {
        require(_value <= allowed[_from][msg.sender]);
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }

    function _burn(address _from, uint256 _value) internal {
        require(_value <= balances[_from]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public  whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


// https://github.com/ethereum/EIPs/issues/20
interface Token {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Utils {
    Token constant internal TOKEN_ETH_ADDRESS = Token(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa);
    uint constant internal ETH_DECIMALS = 18;
    uint constant internal MAX_DECIMALS = 18;

    uint constant internal MAX_PRICE_PRODUCT = 10 ** 16;
    uint constant internal PRICE_PRODUCT = 10 ** 8;

    uint constant internal MAX_VALUE = 2 ** 255 - 1;

    mapping(address => uint) tokenDecimals;

    function setTokenDecimals(Token _token) public {
        if (TOKEN_ETH_ADDRESS == _token) {
            tokenDecimals[_token] = ETH_DECIMALS;
        } else {
            tokenDecimals[_token] = _token.decimals();
        }
    }

    function getTokenDecimals(Token _token) public view returns(uint) {
        if (TOKEN_ETH_ADDRESS == _token) {
            return MAX_DECIMALS;
        } else {
            return _token.decimals();
        }
    }

    function getBalance(Token _token, address _user) public view returns(uint) {
        if(TOKEN_ETH_ADDRESS == _token) {
            return _user.balance;
        } else {
            return _token.balanceOf(_user);
        }
    }
}

/**
 * @title Contracts that should be able to recover tokens or ethers
 * @dev This allows to recover any tokens or Ethers received in a contract.
 */
contract Withdrawable is Ownable {

    event TokenWithdraw(Token _token, uint _amount, address _sendTo);

    /**
     * @dev Withdraw all ERC20 compatible tokens
     * @param _token The address of the token contract
     * @param _amount The amount of token
     * @param _sendTo The address of the token send to
     */
    function withdrawToken(Token _token, uint _amount, address _sendTo) external onlyOwner {
        require(_token.transfer(_sendTo, _amount));
        emit TokenWithdraw(_token, _amount, _sendTo);
    }

    event EtherWithdraw(uint _amount, address _sendTo);

    /**
     * @dev Withdraw Ethers
     * @param _amount The amount of Ethers
     * @param _sendTo The address of the token send to
     */
    function withdrawEther(uint _amount, address _sendTo) external onlyOwner {
        _sendTo.transfer(_amount);
        emit EtherWithdraw(_amount, _sendTo);
    }
}

contract THORToken is StandardToken {
    using SafeMath for uint256;

    string public constant name = "THORToken";   //Token name
    string public constant symbol = "THT";            //Token symbol
    uint8 public decimals = 18;
    uint256 public INITIAL_SUPPLY = 10000000000 * 10 ** uint256(decimals);     //Token initial_supply 10 billion

    event Mint(address indexed _to, uint256 _value);    //Mint tokens

    constructor() public payable{
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
    }
}

interface ThorNetworkInterface {
    function exchange(Token _fromToken, uint _fromAmount, Token _toToken, address _toAddress, uint minRate, address _walletId) external payable returns(uint);
    function getMaxGasPrice() external view returns(uint);
    function findBestRate(Token _fromToken, Token _toToken, uint _fromAmount, uint _maxAmount, uint _minRate) external view returns(uint, uint);
    function getUserQuota(address _user) external returns(uint);
    function getTokensIncluded() external view returns(address[]);
    function getTokenPairAndPrice(Token _fromToken, Token _toToken) external view returns(uint);
    function calculatePlatformFeeInWei(Token _fromToken, uint _fromAmount) external view returns(uint);
}

contract ThorNetworkProxy is Ownable, Utils, Withdrawable {
    using SafeMath for uint256;
    ThorNetworkInterface public thorNetwork;
    string public contractName;

    constructor() public payable {
        contractName = "ThorNetworkProxy";
    }

    /**
     * @dev makes a trade between src and dest token and send dest token to destAddress
     * @param _fromToken fromToken address
     * @param _fromAmount amount of fromToken
     * @param _toToken toToken address
     * @param _minRate the min rate user coule accept
     * @param _walletId the wallet's address
     * @return uint the actual amount of toToken
     */
    function exchange(Token _fromToken, uint _fromAmount, Token _toToken, uint _minRate, address _walletId) public payable whenNotPaused returns(uint) {
        require(_fromToken != _toToken);
        uint256 fromAmount = _fromAmount.div(10 ** (MAX_DECIMALS - getTokenDecimals(_fromToken)));

        return doExchange(_fromToken, fromAmount, _toToken, msg.sender, _minRate, _walletId);
    }

    event ThorNetworkProxyExchange(address indexed trader, Token src, Token dest, uint actualSrcAmount, uint actualDestAmount);

    /**
     * @dev makes a trade between src and dest token and send dest token to destAddress
     * @param _fromToken fromToken address
     * @param _fromAmount amount of fromToken
     * @param _toToken toToken address
     * @param _destAddress the user's address
     * @param _minRate the min rate user coule accept
     * @param _walletId the wallet's address
     * @return uint the actual amount of toToken
     */
    function doExchange(Token _fromToken, uint _fromAmount, Token _toToken, address _destAddress, uint _minRate, address _walletId) internal returns(uint) {
        require(TOKEN_ETH_ADDRESS == _fromToken || msg.value == 0);

        if(TOKEN_ETH_ADDRESS == _fromToken) {
            require(_fromAmount == msg.value);
        }

        //send tokens to ThorNetwork
        if (TOKEN_ETH_ADDRESS != _fromToken) {
            require(_fromToken.transferFrom(msg.sender, thorNetwork, _fromAmount));
        }

        //send eth(msg.value) to ThorNetwork
        //call thorNetwork.exchage to get tokens(_toToken)
        uint actualAmount = thorNetwork.exchange.value(msg.value)(_fromToken, _fromAmount, _toToken, _destAddress, _minRate, _walletId);

        emit ThorNetworkProxyExchange(msg.sender, _fromToken, _toToken, _fromAmount, actualAmount);

        return actualAmount;
    }

    event SetThorNetworkContract(ThorNetworkInterface _thorNetworkContract);
    /**
     * @dev set the ThorNetwork contract
     * @param _thorNetworkContract the ThorNetwork contract
     * @return address ThorNetwork contract
     */
    function setThorNetworkContract(ThorNetworkInterface _thorNetworkContract) public onlyOwner {
        require(_thorNetworkContract != address(0));
        thorNetwork = _thorNetworkContract;

        emit SetThorNetworkContract(_thorNetworkContract);
    }

    /**
     * @dev return the ThorNetwork contract
     * @return address ThorNetwork contract
     */
    function getThorNetworkContract() public view onlyOwner returns(address) {
        return thorNetwork;
    }

    /**
     * @dev return the max GasPrice
     * @return uint the max GasPrice
     */
    function getMaxGasPrice() public view returns(uint) {
        return thorNetwork.getMaxGasPrice();
    }

    /**
     * @dev find the best reserve
     * @param _fromToken token address
     * @param _toToken token address
     * @param _fromAmount token amount of fromToken
     * @param _minRate the min rate user coule accept
     * @return uint reserveId
     * @return uint actual rate
     */
    function findBestRate(Token _fromToken, Token _toToken, uint _fromAmount, uint _minRate) public view returns(uint, uint) {
        return thorNetwork.findBestRate(_fromToken, _toToken, _fromAmount, MAX_VALUE, _minRate);
    }

    /**
     * @dev calculate platformFee
     * @param _fromToken token address
     * @param _fromAmount token amount of fromToken
     * @return uint
     */
    function calculatePlatformFeeInWei(Token _fromToken, uint _fromAmount) public view returns(uint) {
        return thorNetwork.calculatePlatformFeeInWei(_fromToken, _fromAmount);
    }

    /**
     * @dev return token amount of toToken
     * @param _fromToken token address
     * @param _toToken token address
     * @param _fromAmount token amount of fromToken
     * @return uint
     */
    function calculateToTokenAmount(Token _fromToken, Token _toToken, uint _fromAmount) public view returns(uint) {
        uint actualPrice = getTokenPairAndPrice(_fromToken, _toToken);
        uint toAmount = _fromAmount.mul(actualPrice).div(PRICE_PRODUCT);
        toAmount = toAmount.div(10 ** (MAX_DECIMALS - getTokenDecimals(_toToken)));

        return toAmount;
    }

    /**
     * @dev return two tokens price
     * @param _fromToken token address
     * @param _toToken token address
     * @return uint
     */
    function getTokenPairAndPrice(Token _fromToken, Token _toToken) public view returns(uint) {
        return thorNetwork.getTokenPairAndPrice(_fromToken, _toToken);
    }

    /**
     * @dev return a user's quota
     * @param _user a user
     * @return uint
     */
    function getUserQuota(address _user) public returns(uint) {
        return thorNetwork.getUserQuota(_user);
    }

    /**
     * @dev return all tokens in ThorSwap
     * @return address[], a list of tokens
     */
    function getTokensIncluded() public view returns(address[]) {
        return thorNetwork.getTokensIncluded();
    }
}

interface ThorReserveInterface {
    function exchange(Token _fromToken, Token _toToken, address _to, uint _actualAmount, uint _actualRate) external payable returns(bool);
    function getExchangeRate(Token _fromToken, Token _toToken, uint _toAmount) external view returns(uint);
    function getTokensIncluded() external view returns(address[]);
}

interface ThorUserInfoInterface {
    function getUserQuota(address _user) external view returns(uint);
}

interface ThorFeeInterface {
    function handleFee(uint _platformFee, address _walletId) external payable returns(bool);
}

interface ThorPriceInterface {
    function addTokenPairAndPrice(Token _fromToken, Token _toToken, uint _rate) external returns(bool);
    function modifyTokenPairPrice(Token _fromToken, Token _toToken, uint _rate) external returns(bool);
    function setTokenPairsPrice(Token[] _fromTokens, Token[] _toTokens, uint[] _rates) external returns(bool);
    function getTokenPairAndPrice(Token _fromToken, Token _toToken) external view returns(uint);
    function getTokenTransactionPrice(Token _token) external view returns(uint, uint);
}

contract ThorNetwork is Ownable, Utils, Withdrawable {
    using SafeMath for uint256;

    string public contractName;

    uint internal numTransaction = 0;
    uint internal numTokenToToken = 0;
    uint internal numTokenToETH = 0;
    uint internal numETHToToken = 0;

    address public thorNetworkProxy;

    address[] tokensIncluded;
    mapping(address => bool) internal isTokenIncluded;       // when two tokens could be exchanged, true
    
    address[] internal tokensToExchange;
    mapping(address => bool) internal isTokenToExchange;     // tokens included in ThorNetwork, true

    uint public maxGasPrice = 50 * 1000 * 1000 * 1000; // 50 gwei

    uint internal feeRateDenominator = 1000;
    uint internal feeRateMolecular = 1;

    uint internal minTransactionAmount = 10 ** 15;
    uint internal maxTransactionAmount = 10 ** 19;

    uint internal minRate = 9500;
    uint internal standardRate = 10000;
    uint internal maxRate = 10500;

    ThorPriceInterface internal thorPrice;
    ThorUserInfoInterface internal thorUserInfo;
    ThorFeeInterface internal thorFee;
    ThorReserveInterface[] internal thorReserves;
    ThorReserveInterface internal thorReserve1;
    ThorReserveInterface internal thorReserve2;
    mapping(address => bool) isReserve;

    struct BestRateResult {
        uint reserveId1;
        uint reserveId2;
        uint reserveRate1;
        uint reserveRate2;
        uint actualAmount1;
        uint actualAmount2;
        uint actualRate;
    }

    constructor () public {
        contractName = "ThorNetwork";
    }

    event EtherReceival(address indexed sender, uint amount);

    /* solhint-disable no-complex-fallback */
    // Only reserve contract could send Ether to network contract directly.
    function() public payable {
        require(isReserve[msg.sender]);
        emit EtherReceival(msg.sender, msg.value);
    }
    /* solhint-enable no-complex-fallback */

    event ThorNetworkTestEvent(string test);
    /**
     * @dev makes a trade between src and dest token and send dest token to toAddress
     * @param _fromToken fromToken address
     * @param _fromAmount amount of fromToken
     * @param _toToken toToken address
     * @param _toAddress the user's address
     * @param _minRate the min rate user coule accept
     * @param _walletId the wallet's address
     * @return uint the actual amount of toToken
     */
    function exchange(Token _fromToken, uint _fromAmount, Token _toToken, address _toAddress, uint _minRate, address _walletId)
        public
        payable
        whenNotPaused
        returns(uint)
    {
        require(msg.sender == address(thorNetworkProxy));
        require(tx.gasprice <= maxGasPrice);
        emit ThorNetworkTestEvent("test1");
        require(isTokenToExchange[_fromToken] && isTokenToExchange[_toToken]);
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        emit ThorNetworkTestEvent("test2");

        if(TOKEN_ETH_ADDRESS == _fromToken) {
            require(minTransactionAmount <= _fromAmount && _fromAmount <= maxTransactionAmount);
        } else {
            uint amountInEth = calculateToTokenAmount(_fromToken, TOKEN_ETH_ADDRESS, _fromAmount);
            require(minTransactionAmount <= amountInEth && amountInEth <= maxTransactionAmount);
        }

        uint maxAmount = calculateToTokenAmount(_fromToken, _toToken, _fromAmount);

        uint actualAmount = doExchange(_fromToken, _fromAmount, _toToken, _toAddress, maxAmount, _minRate, _walletId);
        require(actualAmount >= maxAmount.mul(_minRate).div(standardRate));
        require(actualAmount <= maxAmount.mul(maxRate).div(standardRate));

        return actualAmount;
    }

    event ThorNetworkExchange(Token _fromToken, uint _fromAmount, Token _toToken, uint _actualAmount, address _toAddress, uint _actualRate, address _walletId);

    /**
     * @dev makes a trade between src and dest token and send dest token to toAddress
     * @param _fromToken fromToken address
     * @param _fromAmount amount of fromToken
     * @param _toToken toToken address
     * @param _toAddress the user's address
     * @param _maxAmount the max amount of toToken
     * @param _minRate the min rate user coule accept
     * @param _walletId the wallet's address
     * @return uint the actual amount of toToken
     */
    function doExchange(Token _fromToken, uint _fromAmount, Token _toToken, address _toAddress, uint _maxAmount, uint _minRate, address _walletId)
        internal
        returns(uint)
    {
        BestRateResult memory bestRateResult;
        (bestRateResult.reserveId1, bestRateResult.reserveId2, bestRateResult.reserveRate1, bestRateResult.reserveRate2, bestRateResult.actualRate) = findBestRate(_fromToken, _toToken, _fromAmount, _maxAmount, _minRate);
        thorReserve1 = thorReserves[bestRateResult.reserveId1];
        thorReserve2 = thorReserves[bestRateResult.reserveId2];
        uint actualRate = bestRateResult.actualRate;
        uint actualAmount1 = 0;
        uint actualAmount2 = 0;

        require(_minRate <= actualRate && actualRate <= maxRate);

        if(_fromToken != TOKEN_ETH_ADDRESS) {
            if(_toToken != TOKEN_ETH_ADDRESS) {                                                                 // ERC20 <=> ETH <=> ERC20
                numTokenToToken++;
                actualAmount1 = reserveExchange(_fromToken, _fromAmount, TOKEN_ETH_ADDRESS, this, bestRateResult.reserveRate1, thorReserve1, false, _walletId);
                actualAmount2 = reserveExchange(TOKEN_ETH_ADDRESS, actualAmount1, _toToken, _toAddress, bestRateResult.reserveRate2, thorReserve2, true, _walletId);
            } else {                                                                                            // ERC20 <=> ETH
                numTokenToETH++;
                actualAmount2 = reserveExchange(_fromToken, _fromAmount, TOKEN_ETH_ADDRESS, _toAddress, bestRateResult.reserveRate1, thorReserve1, true, _walletId); 
            }
        } else {                                                                                                // ETH <=> ERC20
            numETHToToken++;
            actualAmount2 = reserveExchange(_fromToken, _fromAmount, _toToken, _toAddress, bestRateResult.reserveRate2, thorReserve2, true, _walletId); 
        }

        numTransaction++;

        emit ThorNetworkExchange(_fromToken, _fromAmount, _toToken, actualAmount2, _toAddress, actualRate, _walletId);

        return actualAmount2;
    }

    event ReserveExchange(Token _fromToken, uint _fromAmount, uint fromAmount, address _toAddress, uint actualAmount, uint _platformFee);

    /**
     * @dev makes a trade between src and dest token and send dest token to toAddress
     * @param _fromToken fromToken address
     * @param _fromAmount amount of fromToken
     * @param _toToken toToken address
     * @param _toAddress the user's address
     * @param _actualRate the actual rate of toToken
     * @param _thorReserve the reserve
     * @param isHandleFee true, handle the platform fee; false, do not handle platform fee
     * @param _walletId wallet address
     * @return uint the actual amount of toToken
     */
    function reserveExchange(
        Token _fromToken,
        uint _fromAmount,
        Token _toToken,
        address _toAddress,
        uint _actualRate,
        ThorReserveInterface _thorReserve,
        bool isHandleFee,
        address _walletId
    )
        internal
        returns(uint)
    {
        uint callValue = 0;
        uint platformFee = 0;
        uint fromAmount = 0;

        if(isHandleFee && TOKEN_ETH_ADDRESS == _fromToken) {
            platformFee = _fromAmount.mul(feeRateMolecular).div(feeRateDenominator);
        }

        fromAmount = _fromAmount.sub(platformFee);

        uint actualAmount = calculateToTokenAmount(_fromToken, _toToken, fromAmount) * _actualRate / standardRate;

        if (TOKEN_ETH_ADDRESS != _fromToken) {
            //network send tokens to reserve
            _fromToken.transfer(_thorReserve, fromAmount);
        } else {
            callValue = fromAmount;
        }

        //network send eth to reserve
        //reserve send tokens/eth to network.
        require(_thorReserve.exchange.value(callValue)(_fromToken, _toToken, this, actualAmount, _actualRate));
        
        if(isHandleFee && TOKEN_ETH_ADDRESS == _toToken) {
            platformFee = actualAmount.mul(feeRateMolecular).div(feeRateDenominator);
            actualAmount = actualAmount.sub(platformFee);
        }

        //network send it to destination
        if(_toAddress != address(this)) {
            if(TOKEN_ETH_ADDRESS == _toToken) {
                _toAddress.transfer(actualAmount);
            } else {
                _toToken.transfer(_toAddress, actualAmount);
            }
        }

        if(isHandleFee) {
            //network send platformFee to ThorFee contract
            require(thorFee.handleFee.value(platformFee)(platformFee, _walletId));
        }

        emit ReserveExchange(_fromToken, _fromAmount, fromAmount, _toAddress, actualAmount, platformFee);

        return actualAmount;
    }

    function findBestRate(Token _fromToken, Token _toToken, uint _fromAmount, uint _maxAmount, uint _minRate) 
        public view returns(uint, uint, uint, uint, uint) 
    {
        BestRateResult memory result;

        uint maxAmount1 = calculateToTokenAmount(_fromToken, TOKEN_ETH_ADDRESS, _fromAmount);
        (result.reserveId1, result.reserveRate1) = findBestRateTokenToToken(_fromToken, TOKEN_ETH_ADDRESS, maxAmount1, _minRate);
        result.actualAmount1 = maxAmount1.mul(result.reserveRate1).div(standardRate);

        uint maxAmount2 = calculateToTokenAmount(TOKEN_ETH_ADDRESS, _toToken, result.actualAmount1);        
        (result.reserveId2, result.reserveRate2) = findBestRateTokenToToken(TOKEN_ETH_ADDRESS, _toToken, maxAmount2, _minRate);
        result.actualAmount2 = maxAmount2.mul(result.reserveRate2).div(standardRate);

        result.actualRate = result.reserveRate1.mul(result.reserveRate2).div(standardRate);
        require(result.actualAmount2 >= _maxAmount * _minRate / standardRate);
        require(_minRate <= result.actualRate);

        return (result.reserveId1, result.reserveId2, result.reserveRate1, result.reserveRate2, result.actualRate);
    }

    /**
     * @dev find the best reserve
     * @param _fromToken token address
     * @param _toToken token address
     * @param _toAmount token amount of toToken
     * @param _minRate the min rate user coule accept
     * @return uint reserveId
     * @return uint actual rate
     */
    function findBestRateTokenToToken(Token _fromToken, Token _toToken, uint _toAmount, uint _minRate) public view returns(uint, uint) {
        if(_fromToken == _toToken) {
            return (0, standardRate);
        }

        uint bestRate = 0;
        uint bestReserve = 0;
        
        uint numberReserve = thorReserves.length;
        uint[] memory rates = new uint[](numberReserve);
        uint[] memory reserveCandiates = new uint[](numberReserve);
        uint reserveCandiateIndex = 0;
        uint random = 0;

        for(uint i = 0; i < numberReserve; i++) {
            rates[i] = thorReserves[i].getExchangeRate(_fromToken, _toToken, _toAmount);

            if(rates[i] > bestRate){
                bestRate = rates[i];
            }
        }
        
        require(_minRate <= bestRate);

        for(i = 0; i < numberReserve; i++) {
            if(rates[i] == bestRate) {
                reserveCandiates[reserveCandiateIndex++] = i;
            }
        }

        if(reserveCandiateIndex > 1) {
            random = uint(keccak256(abi.encodePacked(now, msg.sender))) % reserveCandiateIndex;
        }

        bestReserve = reserveCandiates[random];      

        return (bestReserve, bestRate);
    }

    function getExchangeRate(ThorReserveInterface reserve, Token _fromToken, Token _toToken, uint _toAmount) public view returns(uint) {
        return reserve.getExchangeRate(_fromToken, _toToken, _toAmount);
    }

    event AddTokensToExchange(Token[] tokens, uint length);

    /**
     * @dev add tokens to exchange
     * @param tokens tokens address
     * @param length tokens' length
     */
    function addTokensToExchange(Token[] tokens, uint length) public onlyOwner {
        require(tokens.length == length && length > 0);
        for(uint i = 0; i < length; i++) {
            if(!isTokenToExchange[tokens[i]]) {
                tokensToExchange.push(tokens[i]);
                isTokenToExchange[tokens[i]] = true;
            }
        }

        emit AddTokensToExchange(tokens, length);
    }

    function getTokenToExchangeIsEnable(address _token) public view returns(bool) {
        return isTokenToExchange[_token];
    }

    event SetTokensIncludedEnable(string isGood, bool res);
    /**
     * @dev enable all tokens in ThorSwap 
     * @return address[], a list of tokens
     */
    function setTokensIncludedEnable() public onlyOwner returns(address[]) {
        for(uint i = 0; i < thorReserves.length; i++) {
            address[] memory tokensIncludedReserve = thorReserves[i].getTokensIncluded();
            for(uint j = 0; j < tokensIncludedReserve.length; j++) {
                if(!isTokenIncluded[tokensIncludedReserve[j]]) {
                    tokensIncluded.push(tokensIncludedReserve[j]);
                    isTokenIncluded[tokensIncludedReserve[j]] = true;
                }
            }
        }

        emit SetTokensIncludedEnable("good", true);
        return tokensIncluded;
    }

    /**
     * @dev return all tokens in ThorSwap
     * @return address[], a list of tokens
     */
    function getTokensIncluded() public view returns(address[]) {
        return tokensIncluded;
    }

    event AddReserve(ThorReserveInterface _newReserve);
    /**
     * @dev add a reserve
     * @param _newReserve address of a reserve contract
     * @return bool
     */
    function addReserve(ThorReserveInterface _newReserve) public onlyOwner returns(bool) {
        require(!isReserve[_newReserve]);
        thorReserves.push(_newReserve);
        isReserve[_newReserve] = true;

        emit AddReserve(_newReserve);

        return true;
    }

    event RemoveReserve(ThorReserveInterface _oldReserve);
    /**
     * @dev remove a reserve
     * @param _oldReserve address of a reserve contract
     * @return bool
     */
    function removeReserve(ThorReserveInterface _oldReserve) public onlyOwner {
        require(isReserve[_oldReserve]);
        require(1 <= thorReserves.length);
        for(uint i = 0; i < thorReserves.length; i++){
            if(thorReserves[i] == _oldReserve){
                thorReserves[i] = thorReserves[thorReserves.length - 1];
                thorReserves.length--;
                break;
            }
        }
        isReserve[_oldReserve] = false;

        emit RemoveReserve(_oldReserve);
    }

    /**
     * @dev return two tokens price
     * @param _fromToken token address
     * @param _toToken token address
     * @return uint
     */
    function getTokenPairAndPrice(Token _fromToken, Token _toToken) public view returns(uint) {
        require(_fromToken != _toToken);
        require(isTokenIncluded[_fromToken]);
        require(isTokenIncluded[_toToken]);
        return thorPrice.getTokenPairAndPrice(_fromToken, _toToken);
    }

    function getTokenTransactionPrice(Token _token) public view returns(uint, uint) {
        require(isTokenIncluded[_token]);
        require(isTokenToExchange[_token]);
        return thorPrice.getTokenTransactionPrice(_token);
    }

    function addTokenPairAndPrice(Token _fromToken, Token _toToken, uint _price) public onlyOperator returns(bool) {
        return thorPrice.addTokenPairAndPrice(_fromToken, _toToken, _price);
    }

    function modifyTokenPairPrice(Token _fromToken, Token _toToken, uint _price) public onlyOperator returns(bool) {
        return thorPrice.modifyTokenPairPrice(_fromToken, _toToken, _price);
    }

    function setTokenPairsPrice(Token[] _fromTokens, Token[] _toTokens, uint[] _prices) public onlyOperator returns(bool) {
        return thorPrice.setTokenPairsPrice(_fromTokens, _toTokens, _prices);
    }

    event SetParamsRate(uint _feeRateMolecular, uint _feeRateDenominator, uint _minRate, uint _standardRate, uint _maxRate);
    /**
     * @dev set params including feeRateDenominator, feeRateMolecular, minRate, standardRate and maxRate
     * @param _feeRateMolecular token address
     * @param _feeRateDenominator token amount
     * @return bool
     */
    function setParamsRate(uint _feeRateMolecular, uint _feeRateDenominator, uint _minRate, uint _standardRate, uint _maxRate) public onlyOwner {
        feeRateDenominator = _feeRateDenominator;
        feeRateMolecular = _feeRateMolecular;
        minRate = _minRate;
        standardRate = _standardRate;
        maxRate = _maxRate;

        emit SetParamsRate(_feeRateMolecular, _feeRateDenominator, _minRate, _standardRate, _maxRate);
    }

    function getParamsRate() public view onlyOwner returns(uint, uint, uint, uint, uint) {
        return (feeRateDenominator, feeRateMolecular, minRate, standardRate, maxRate);
    }

    /**
     * @dev return token amount of toToken
     * @param _fromToken token address
     * @param _toToken token address
     * @param _fromAmount token amount of fromToken
     * @return uint
     */
    function calculateToTokenAmount(Token _fromToken, Token _toToken, uint256 _fromAmount) public view returns(uint) {
        if(_fromToken == _toToken) {
            return _fromAmount;
        }
        uint256 actualPrice = getTokenPairAndPrice(_fromToken, _toToken);
        require(actualPrice != 0);
        uint256 toAmount = _fromAmount.mul(actualPrice).div(PRICE_PRODUCT);
        toAmount = toAmount.div(10 ** (MAX_DECIMALS - getTokenDecimals(_toToken)));

        return toAmount;
    }

    /**
     * @dev return platformFee
     * @param _fromToken token address
     * @param _fromAmount token amount of fromToken
     * @return uint
     */
    function calculatePlatformFeeInWei(Token _fromToken, uint _fromAmount) public view returns(uint) {
        return calculateToTokenAmount(_fromToken, TOKEN_ETH_ADDRESS, _fromAmount).mul(feeRateMolecular).div(feeRateDenominator);
    }


    event SetTokenIsEnable(Token _token, bool isEnable);
    /**
     * @dev Set function of two token swap
     * @param _token toToken address
     * @param isEnable true, function normal; false, function stop.
     */
    function setTokenIsEnable(Token _token, bool isEnable) public onlyOwner {
        isTokenIncluded[_token] = isEnable;
        emit SetTokenIsEnable(_token, isEnable);
    }

    /**
     * @dev return function of two token swap
     * @param _token toToken address
     * @return bool
     */
    function getTokenIsEnable(Token _token) public view onlyOwner returns(bool) {
        return isTokenIncluded[_token];
    }

    /**
     * @dev ret ThorReserves contracts
     * @return address[], a list of ThorReserve contracts
     */
    function getThorReserve() public view onlyOwner returns(ThorReserveInterface[]) {
        return thorReserves;
    }

    event SetContracts(address _thorNetworkProxy, ThorPriceInterface _thorPrice, ThorUserInfoInterface _thorUserInfo, ThorFeeInterface _thorFee);
    /**
     * @dev set relative contracts
     * @param _thorNetworkProxy ThorNetworkProxy contract
     * @param _thorPrice ThorPrice contract
     * @param _thorUserInfo ThorUserInfo contract
     * @param _thorFee ThorFee contract
     * @return bool
     */
    function setContracts(address _thorNetworkProxy, ThorPriceInterface _thorPrice, ThorUserInfoInterface _thorUserInfo, ThorFeeInterface _thorFee) 
        public
        onlyOwner
    {
        require(_thorNetworkProxy != address(0));
        require(_thorPrice != address(0));
        require(_thorUserInfo != address(0));
        require(_thorFee != address(0));

        thorNetworkProxy = _thorNetworkProxy;
        thorPrice = _thorPrice;
        thorUserInfo = _thorUserInfo;
        thorFee = _thorFee;

        emit SetContracts(_thorNetworkProxy, _thorPrice, _thorUserInfo, _thorFee);
    }

    /**
     * @dev return relative contracts
     * @return address ThorNetworkProxy contract
     * @return address ThorPrice contract
     * @return address ThorUserInfo contract
     * @return address ThorFee contract
     */
    function getContracts() public view onlyOwner returns(address, address, address, address) {
        return (thorNetworkProxy, thorPrice, thorUserInfo, thorFee);
    }

    event SetMaxGasPrice(uint _maxGasPrice);
    /**
     * @dev set the max GasPrice
     * @param _maxGasPrice the max GasPrice
     * @return uint the max GasPrice
     */
    function setMaxGasPrice(uint _maxGasPrice) public onlyOwner {
        maxGasPrice = _maxGasPrice;
        emit SetMaxGasPrice(_maxGasPrice);
    }

    /**
     * @dev return the max GasPrice
     * @return uint the max GasPrice
     */
    function getMaxGasPrice() public view returns(uint) {
        return maxGasPrice;
    }

    /**
     * @dev get transactions number
     */
    function getTransactionsNumber() public view onlyOwner returns(uint, uint, uint, uint) {
        return (numTransaction, numTokenToToken, numTokenToETH, numETHToToken);
    }

    /**
     * @dev return a user's quota
     * @param _user address of a user
     * @return uint
     */
    function getUserQuota(address _user) public view returns(uint) {
        return thorUserInfo.getUserQuota(_user);
    }
}


interface ThorNetworkReserveInterface {
    function getTokenTransactionPrice(Token _token) external view returns(uint, uint);
    function getTokenToExchangeIsEnable(Token _token) external returns(bool);
}

contract ThorReserve is Ownable, Utils, Withdrawable{
    using SafeMath for uint256;
    string public contractName;

    ThorNetworkReserveInterface public thorNetwork;

    bool public isEnabled = false;

    uint public numTransaction;

    uint constant internal minRate = 9500;
    uint constant internal maxRate = 10500;
    uint constant internal standardRate = 10000;

    uint constant internal targetRatio = 100;

    address[] tokensIncluded;
    mapping(address => bool) isTokenIncluded;

    mapping(bytes32 => bool) isPairToken;       // when two tokens could be exchanged, true

    struct PairTokenRate {
        uint blockNumber;                       // the block when rate was modified
        uint rate;                              // two tokens min rate
    }
    mapping(bytes32 => PairTokenRate) pairTokenRates;

    struct TokenReserveInfo {
        uint targetAmount;
        uint depositRatio;                      //inform reserve to deposit token when ratio < depositRatio
        uint stopRatio;                         //reserve's function pause when current ratio < stopRatio
    }
    mapping(address => TokenReserveInfo) tokenReserveInfos;

    constructor(ThorNetworkReserveInterface _thorNetwork) public {
        contractName = "ThorReserve";
        isEnabled = true;
        thorNetwork = _thorNetwork;
    }

    modifier onlyEnabled() {
        require(isEnabled);
        _;
    }

    event DepositToken(Token token, uint amount);

    function() public payable {
        emit DepositToken(TOKEN_ETH_ADDRESS, msg.value);
    }

    event ThorReserveExchange(Token _fromToken, Token _toToken, address _to, uint _actualAmount, uint _actualRate);
    /**
     * @dev makes a trade between src and dest token and send dest token to toAddress
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _to the user's address
     * @param _actualAmount the actual amount of toToken
     * @param _actualRate the actual rate of toToken
     * @return bool
     */
    function exchange(Token _fromToken, Token _toToken, address _to, uint _actualAmount, uint _actualRate) public payable returns(bool) {
        require(thorNetwork == msg.sender);

        require(_actualRate == pairTokenRates[keccak256(abi.encodePacked(_fromToken, _toToken))].rate);

        emit ThorReserveExchange(_fromToken, _toToken, _to, _actualAmount, _actualRate);
        return doExchange(_fromToken, _toToken, _to, _actualAmount);
    }

    /**
     * @dev makes a trade between src and dest token and send dest token to toAddress
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _to the user's address
     * @param _actualAmount the actual amount of toToken
     * @return bool
     */
    function doExchange(Token _fromToken, Token _toToken, address _to, uint _actualAmount) internal returns(bool) {
        numTransaction++;

        require(isPairToken[keccak256(abi.encodePacked(_fromToken, _toToken))]);

        //send tokens/ETH to thorNetwork
        if(TOKEN_ETH_ADDRESS == _toToken) {
            _to.transfer(_actualAmount);
        } else {
            _toToken.transfer(_to, _actualAmount);
        }

        //balance the reserve token
        balanceToken(_toToken);
        return true;
    }

    /**
     * @dev return the reserve rate of two tokens
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _toAmount the actual amount of toToken
     * @return bool
     */
    function getExchangeRate(Token _fromToken, Token _toToken, uint _toAmount) public view returns(uint)
    {
        bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
        PairTokenRate memory pairTokenRate = pairTokenRates[tokenPair];
        if(!isEnoughToken(_toToken, _toAmount)) {
            return 0;                                                                   //reserve does not have enough _toToken tokens
        } else {
            return pairTokenRate.rate;
        }
        return 0;
    }

    /**
     * @dev return all tokens in the reserve
     * @return address[], a list of tokens
     */
    function getTokensIncluded() public view returns(address[]) {
        return tokensIncluded;
    }

    /**
     * @dev The reserve has enough tokens
     * @param _targetToken toToken address
     * @param _targetAmount the actual amount of toToken
     * @return bool
     */
    function isEnoughToken(Token _targetToken, uint256 _targetAmount) public view returns(bool) {
        uint tokenAmount = getBalance(_targetToken, address(this));
        uint stopAmount = tokenReserveInfos[_targetToken].stopRatio * tokenReserveInfos[_targetToken].targetAmount / targetRatio;
        //require(tokenAmount >= _targetAmount);
        if(tokenAmount >= _targetAmount && tokenAmount - _targetAmount >= stopAmount) {     // make sure that reserve has enough balance. 
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev add a new pair of token
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _rate the new rate between two tokens
     * @return bool
     */
    function addTokenPairAndRate(Token _fromToken, Token _toToken, uint _rate) public onlyOwner {
        require(thorNetwork.getTokenToExchangeIsEnable(_fromToken) && thorNetwork.getTokenToExchangeIsEnable(_toToken));
        require(minRate <= _rate && _rate <= maxRate);
        require(TOKEN_ETH_ADDRESS == _fromToken || TOKEN_ETH_ADDRESS == _toToken);
        require(_fromToken != _toToken);
        require(!isTokenIncluded[_fromToken] || !isTokenIncluded[_toToken]);

        if(!isTokenIncluded[_fromToken]) {
            isTokenIncluded[_fromToken] = true;
            tokensIncluded.push(_fromToken);
        }
        
        if(!isTokenIncluded[_toToken]) {
            isTokenIncluded[_toToken] = true;
            tokensIncluded.push(_toToken);
        }

        setTokenPairAndRate(_fromToken, _toToken, _rate);
    }

    /**
     * @dev modify a pair of token
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _rate the new rate between two tokens
     * @return bool
     */
    function modifyTokenPairRate(Token _fromToken, Token _toToken, uint _rate) public onlyOwner {
        require(minRate <= _rate && _rate <= maxRate);
        require(TOKEN_ETH_ADDRESS == _fromToken || TOKEN_ETH_ADDRESS == _toToken);
        require(_fromToken != _toToken);
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        setTokenPairAndRate(_fromToken, _toToken, _rate);
    }

    event SetTokenPairAndRate(Token _fromToken, Token _toToken, uint _rate);
    /**
     * @dev set a pair of token
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _rate the new rate between two tokens
     * @return bool
     */
    function setTokenPairAndRate(Token _fromToken, Token _toToken, uint _rate) internal {
        PairTokenRate memory pairTokenRate = PairTokenRate(block.number, _rate);
        bytes32 tokenPair1 = keccak256(abi.encodePacked(_fromToken, _toToken));
        bytes32 tokenPair2 = keccak256(abi.encodePacked(_toToken, _fromToken));
        pairTokenRates[tokenPair1] = pairTokenRate;
        pairTokenRates[tokenPair2] = pairTokenRate;

        isPairToken[tokenPair1] = true;
        isPairToken[tokenPair2] = true;

        emit SetTokenPairAndRate(_fromToken, _toToken, _rate);
    }

    /**
     * @dev return a pair of token
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @return uint The rate between two tokens
     * @return uint The current blockNumber when the rate was set
     * @return uint The current blockNumber
     */
    function getTokenPairAndRate(Token _fromToken, Token _toToken) public view returns(uint, uint, uint) {
        bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
        require(isPairToken[tokenPair]);
        return (pairTokenRates[tokenPair].rate, pairTokenRates[tokenPair].blockNumber, block.number);
    }

    event SetTokenReserveInfo(Token _token, uint _targetAmount, uint _depositRatio, uint _stopRatio);
    /**
     * @dev set a token's info
     * @param _token toToken address
     * @param _targetAmount Target number of token
     * @param _depositRatio Ratio to deposit
     * @param _stopRatio Ratio to stop
     * @return bool
     */
    function setTokenReserveInfo(Token _token, uint _targetAmount, uint _depositRatio, uint _stopRatio) public onlyOwner {
        require(0 <= _targetAmount);
        require(0 <= _stopRatio && _stopRatio <= _depositRatio);
        require(isTokenIncluded[_token]);
        tokenReserveInfos[_token].targetAmount = _targetAmount;
        tokenReserveInfos[_token].depositRatio = _depositRatio;
        tokenReserveInfos[_token].stopRatio = _stopRatio;

        emit SetTokenReserveInfo(_token, _targetAmount, _depositRatio, _stopRatio);
    }

    /**
     * @dev ret a token's info
     * @param _token toToken address
     * @return _targetAmount Target number of token
     * @return _depositRatio Ratio to deposit
     * @return _stopRatio Ratio to stop
     */
    function getTokenReserveInfo(Token _token) 
        public 
        onlyOwner
        view 
        returns
        (uint marketPrice, uint transactionPrice, uint tokenPairRate, uint decimalsToken, uint currentAmount, uint targetAmount, uint depositRatio, uint stopRatio)
    {
        require(isTokenIncluded[_token]);
        TokenReserveInfo storage tokenReserveInfo = tokenReserveInfos[_token];

        decimalsToken = getTokenDecimals(_token);
        currentAmount = getBalance(_token, address(this));

        if(TOKEN_ETH_ADDRESS == _token) {
            marketPrice = PRICE_PRODUCT;
            transactionPrice = PRICE_PRODUCT;
            tokenPairRate = standardRate;
        } else {
            (marketPrice, transactionPrice) = thorNetwork.getTokenTransactionPrice(_token);
            bytes32 tokenPair = keccak256(abi.encodePacked(TOKEN_ETH_ADDRESS, _token));
            require(isPairToken[tokenPair]);
            tokenPairRate = pairTokenRates[tokenPair].rate;
        }

        targetAmount = tokenReserveInfo.targetAmount;
        depositRatio = tokenReserveInfo.depositRatio;
        stopRatio = tokenReserveInfo.stopRatio;
    }

    event BalanceToken(Token _token, uint _depositAmount);
    /**
     * @dev inform the reserve of the current tokens number 
     * @param _token toToken address
     * @return bool
     */
    function balanceToken(Token _token) internal returns(bool) {
        require(isTokenIncluded[_token]);
        uint depositTokenAmount = tokenReserveInfos[_token].targetAmount.mul(tokenReserveInfos[_token].depositRatio).div(targetRatio);
        uint currentTokenAmount = getBalance(_token, address(this));
        if(currentTokenAmount < depositTokenAmount) {
            uint depositAmount = depositTokenAmount.sub(currentTokenAmount);
            emit BalanceToken(_token, depositAmount);
            return true;
        } else {
            return false;
        }
    }

    event SetTokenPairIsEnable(Token _fromToken, Token _toToken, bool isEnable);
    /**
     * @dev Set function of two token swap
     * @param _toToken toToken address
     * @param _toToken toToken address
     * @param isEnable true, function normal; false, function stop.
     */
    function setTokenPairIsEnable(Token _fromToken, Token _toToken, bool isEnable) public onlyOwner {
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
        isPairToken[tokenPair] = isEnable;

        emit SetTokenPairIsEnable(_fromToken, _toToken, isEnable);
    }

    /**
     * @dev return function of two token swap
     * @param _toToken toToken address
     * @param _toToken toToken address
     * @return bool
     */
    function getTokenPairIsEnable(Token _fromToken, Token _toToken) public view onlyOwner returns(bool) {
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
        return isPairToken[tokenPair];
    }

    event SetThorNetworkContract(ThorNetworkReserveInterface _thorNetworkContract);
    /**
     * @dev set ThorNetwork contracts
     * @param _thorNetworkContract ThorNetwork contract
     */
    function setThorNetworkContract(ThorNetworkReserveInterface _thorNetworkContract) public onlyOwner {
        require(_thorNetworkContract != address(0));
        thorNetwork = _thorNetworkContract;

        emit SetThorNetworkContract(_thorNetworkContract);
    }

    /**
     * @dev return ThorNetwork contracts
     * @return _thorNetworkContract ThorNetwork contract
     */
    function getThorNetworkContract() public view onlyOwner returns(address) {
        return thorNetwork;
    }
}

contract ThorFee is Ownable, Utils{
    using SafeMath for uint256;

    string public contractName;

    address internal thorWalletAddress = address(0xe2a774bbab574837c9bc178ffd4d4f2e04841f5c);

    address public thorNetwork;

    uint internal walletFeeRatio = 4;
    uint internal thorWalletFeeRatio = 6;

    mapping(address => uint) walletsFee;

    constructor(address _thorNetwork) public {
        contractName = "ThorFee";
        thorNetwork = _thorNetwork;
    }

    event HandleFee(uint platformFee, address walletId);
    /**
     * @dev distribute fees to wallet and ThorNetwork
     * @param _platformFee the total of fee
     * @param _walletId address of wallet
     * @return bool
     */
    function handleFee(uint _platformFee, address _walletId) public payable returns(bool) {
        require(thorNetwork == msg.sender);

        uint walletFee = _platformFee.mul(walletFeeRatio).div(10);
        uint thornetworkFee = _platformFee.mul(thorWalletFeeRatio).div(10);

        walletsFee[_walletId] = walletsFee[_walletId].add(walletFee);
        walletsFee[thorWalletAddress] = walletsFee[thorWalletAddress].add(thornetworkFee);

        emit HandleFee(_platformFee, _walletId);
        return true;
    }

    event EtherFeeWithdraw(uint _amount, address _sendTo);
    /**
     * @dev set wallet address of ThorNetwork
     * @param _sendTo wallet address of ThorNetwork
     * @param _amount wallet address of ThorNetwork
     * @return bool
     */
    function withdrawFee(address _sendTo, uint _amount) public returns(bool) {
        require(walletsFee[msg.sender] != 0);
        require(_sendTo != address(0));

        uint256 actualFeeAmount = walletsFee[msg.sender];
        uint256 sendAmount = _amount;

        if(sendAmount >= actualFeeAmount) {
            sendAmount = actualFeeAmount;
        }

        require(actualFeeAmount >= sendAmount);
        walletsFee[msg.sender] = actualFeeAmount.sub(sendAmount);

        _sendTo.transfer(sendAmount);

        emit EtherFeeWithdraw(sendAmount, _sendTo);

        return true;
    }

    /**
     * @dev return fee of a wallet
     * @param _walletAddress  address of a wallet
     * @return uint
     */
    function getWalletFee(address _walletAddress) public onlyOwner view returns(uint) {
        return walletsFee[_walletAddress];
    }

    function getSelfWalletFee() public view returns(uint) {
        return walletsFee[msg.sender];
    }

    event SetThorWalletAddress(address _thorWalletAddress);
    /**
     * @dev set wallet address of ThorNetwork
     * @param _thorWalletAddress wallet address of ThorNetwork
     * @return bool
     */
    function setThorWalletAddress(address _thorWalletAddress) public onlyOwner {
        require(_thorWalletAddress != address(0));
        thorWalletAddress = _thorWalletAddress;

        emit SetThorWalletAddress(_thorWalletAddress);
    }

    /**
     * @dev ret wallet address of ThorNetwork
     * @return wallet address of ThorNetwork
     */
    function getThorWalletAddress() public view onlyOwner returns(address) {
        return thorWalletAddress;
    }

    event SetThorNetworkContract(address _thorNetworkContract);
    /**
     * @dev set ThorNetwork contracts
     * @param _thorNetworkContract ThorNetwork contract
     */
    function setThorNetworkContract(address _thorNetworkContract) public onlyOwner {
        require(_thorNetworkContract != address(0));
        thorNetwork = _thorNetworkContract;

        emit SetThorNetworkContract(_thorNetworkContract);
    }

    /**
     * @dev return ThorNetwork contracts
     * @return _thorNetworkContract ThorNetwork contract
     */
    function getThorNetworkContract() public view onlyOwner returns(address) {
        return thorNetwork;
    }

    event SetFeeDistributionRatio(uint _walletFeeRatio, uint _thorWalletFeeRatio);
    /**
     * @dev set distribution ratio of wallet and ThorNetwork
     * @param _walletFeeRatio wallet get _walletFeeRatio/10 of fee
     * @param _thorWalletFeeRatio ThorNetwork get _thorWalletFeeRatio/10 of fee
     * @return bool
     */
    function setFeeDistributionRatio(uint _walletFeeRatio, uint _thorWalletFeeRatio) public onlyOwner {
        require((_walletFeeRatio + _thorWalletFeeRatio) == 10);
        walletFeeRatio = _walletFeeRatio;
        thorWalletFeeRatio = _thorWalletFeeRatio;

        emit SetFeeDistributionRatio(_walletFeeRatio, _thorWalletFeeRatio);
    }
}

contract ThorUserInfo is Ownable, Utils, Withdrawable {
    string public contractName;

    address public thorNetwork;

    mapping(address => uint) userQuotas;

    uint256 internal constant QUOTA = 10 ** 18;

    constructor (address _thorNetwork) public {
        contractName = "ThorUserInfo";
        thorNetwork = _thorNetwork;
    }

    event SetUserQuota(address _user, uint256 _quota);
    //0--10ETH, 1--20ETH, 2--30ETH
    /**
     * @dev Set a user's quota
     * @param _user The address of the token contract
     * @param _quota The amount of token
     * @return bool
     */
    function setUserQuota(address _user, uint256 _quota) public onlyOwner {
        userQuotas[_user] = _quota;
        emit SetUserQuota(_user, _quota);
    }

    /**
     * @dev Return a user's quota
     * @param _user The address of the token contract
     * @return uint The quota in wei
     */
    function getUserQuota(address _user) public view returns(uint) {
        require(thorNetwork == msg.sender);

        return 10 * (userQuotas[_user] + 1) * QUOTA;
    }

    event SetThorNetworkContract(address _thorNetworkContract);
    /**
     * @dev set ThorNetwork contracts
     * @param _thorNetworkContract ThorNetwork contract
     */
    function setThorNetworkContract(address _thorNetworkContract) public onlyOwner {
        require(_thorNetworkContract != address(0));
        thorNetwork = _thorNetworkContract;
        emit SetThorNetworkContract(_thorNetworkContract);
    }

    /**
     * @dev return ThorNetwork contracts
     * @return _thorNetworkContract ThorNetwork contract
     */
    function getThorNetworkContract() public view onlyOwner returns(address) {
        return thorNetwork;
    }
}

contract ThorPrice is Ownable, Utils, Withdrawable {
    string public contractName;

    using SafeMath for uint256;

    address public thorNetwork;

    address[] tokensIncluded;
    mapping(address => bool) isTokenIncluded;

    mapping(bytes32 => bool) isPairToken;       // when one ERC20 token could be exchanged with ETH, true

    uint internal moleculePrice = 100;
    uint internal denominatorPrice = 100;

    struct PairTokenPrice {
        uint blockNumber;                       // the block when Price was modified
        uint marketPrice;
        uint transactionPrice;                              // two tokens min Price
    }
    mapping(bytes32 => PairTokenPrice) pairTokenPrices;

    constructor (address _thorNetwork) public {
        contractName = "ThorPrice";
        thorNetwork = _thorNetwork;
    }

    /**
     * @dev return all tokens in the price
     * @return address[], a list of tokens
     */
    function getTokensIncluded() public view returns(address[]) {
        return tokensIncluded;
    }

    event SetPriceRate(uint _moleculePrice, uint _denominatorPrice);
    /**
     * @dev set price rate, actualPrice = price * _moleculePrice / _denominatorPrice
     * @param _moleculePrice actualPrice = price * _moleculePrice / _denominatorPrice
     * @param _denominatorPrice actualPrice = price * _moleculePrice / _denominatorPrice
     */
    function setPriceRate(uint _moleculePrice, uint _denominatorPrice) public onlyOwner {
        require(_denominatorPrice >= _moleculePrice);
        require(_moleculePrice >= 90);
        require(_denominatorPrice <= 100);
        moleculePrice = _moleculePrice;
        denominatorPrice = _denominatorPrice;
        emit SetPriceRate(_moleculePrice, _denominatorPrice);
    }

    function getPriceRate() public view returns(uint, uint) {
        return (moleculePrice, denominatorPrice);
    }

    event AddTokenPairAndPrice(Token _fromToken, Token _toToken, uint _price);
    /**
     * @dev add a price of new token, _price = actualPrice * 10 ** 8
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _price the new rate between two tokens
     * @return bool
     */
    function addTokenPairAndPrice(Token _fromToken, Token _toToken, uint _price) public onlyOperator {
        require(!isTokenIncluded[_fromToken] || !isTokenIncluded[_toToken]);

        if(!isTokenIncluded[_fromToken]) {
            isTokenIncluded[_fromToken] = true;
            tokensIncluded.push(_fromToken);
        }
        
        if(!isTokenIncluded[_toToken]) {
            isTokenIncluded[_toToken] = true;
            tokensIncluded.push(_toToken);
        }

        setTokenPairAndPrice(_fromToken, _toToken, _price);
        emit AddTokenPairAndPrice(_fromToken, _toToken, _price);
    }

    event AddTokenPairsAndPrice(Token[] _tokens, uint[] _prices);
    /**
     * @dev add a new price of tokens, _price = actualPrice * 10 ** 8
     * @param _tokens fromToken address
     * @param _prices the new rate between two tokens
     * @return bool
     */
    function addTokenPairsAndPrice(Token[] _tokens, uint[] _prices) public onlyOperator {
        require(_tokens.length == _prices.length);
        for (uint i = 0; i < _tokens.length; i++) {
            addTokenPairAndPrice(TOKEN_ETH_ADDRESS, _tokens[i], _prices[i]);
        }
        emit AddTokenPairsAndPrice(_tokens, _prices);
    }

    event ModifyTokenPairPrice(Token _fromToken, Token _toToken, uint _price);
    /**
     * @dev modify a new price of tokens
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _price the new rate between two tokens
     * @return bool
     */
    function modifyTokenPairPrice(Token _fromToken, Token _toToken, uint _price) public onlyOperator {
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        setTokenPairAndPrice(_fromToken, _toToken, _price);

        emit ModifyTokenPairPrice(_fromToken, _toToken, _price);
    }

    /**
     * @dev add a new price of token
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @param _price the new rate between two tokens
     * @return bool
     */
    function setTokenPairAndPrice(Token _fromToken, Token _toToken, uint _price) internal returns(bool) {
        require(TOKEN_ETH_ADDRESS == _fromToken || TOKEN_ETH_ADDRESS == _toToken);
        require(_fromToken != _toToken);
        uint marketPrice = _price;
        uint marketPriceInverse = MAX_PRICE_PRODUCT.div(marketPrice);

        uint transactionPrice = marketPrice.mul(moleculePrice).div(denominatorPrice);
        uint transactionInversePrice = marketPriceInverse.mul(moleculePrice).div(denominatorPrice);

        PairTokenPrice memory pairTokenPrice1 = PairTokenPrice(block.number, marketPrice, transactionPrice);
        PairTokenPrice memory pairTokenPrice2 = PairTokenPrice(block.number, marketPriceInverse, transactionInversePrice);
        bytes32 tokenPair1 = keccak256(abi.encodePacked(_fromToken, _toToken));
        bytes32 tokenPair2 = keccak256(abi.encodePacked(_toToken, _fromToken));
        pairTokenPrices[tokenPair1] = pairTokenPrice1;
        pairTokenPrices[tokenPair2] = pairTokenPrice2;

        isPairToken[tokenPair1] = true;
        isPairToken[tokenPair2] = true;
    }

    event SetTokenPairsPrice(Token[] _fromTokens, Token[] _toTokens, uint[] _Prices);
    /**
     * @dev set a list of tokens price
     * @param _fromTokens a list fromTokens address
     * @param _toTokens a list of toTokens address
     * @param _Prices a list of prices
     * @return bool
     */
    function setTokenPairsPrice(Token[] _fromTokens, Token[] _toTokens, uint[] _Prices) public onlyOperator returns(bool) {
        require(_fromTokens.length == _toTokens.length);
        require(_fromTokens.length == _Prices.length);
        for(uint i = 0; i < _fromTokens.length; i++){
            require(isTokenIncluded[_fromTokens[i]] && isTokenIncluded[_toTokens[i]]);
            setTokenPairAndPrice(_fromTokens[i], _toTokens[i], _Prices[i]);
        }

        emit SetTokenPairsPrice(_fromTokens, _toTokens, _Prices);
        return true;
    }

    /**
     * @dev return a price of tokens
     * @param _fromToken fromToken address
     * @param _toToken toToken address
     * @return bool
     */
    function getTokenPairAndPrice(Token _fromToken, Token _toToken) public view returns(uint) {
        if(TOKEN_ETH_ADDRESS == _fromToken || TOKEN_ETH_ADDRESS == _toToken) {
            bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
            require(isPairToken[tokenPair]);
            return pairTokenPrices[tokenPair].transactionPrice;
        } else {
            bytes32 tokenPair1 = keccak256(abi.encodePacked(_fromToken, TOKEN_ETH_ADDRESS));
            bytes32 tokenPair2 = keccak256(abi.encodePacked(TOKEN_ETH_ADDRESS, _toToken));
            require(isPairToken[tokenPair1] && isPairToken[tokenPair2]);
            uint256 tokenPairPrice1 = pairTokenPrices[tokenPair1].transactionPrice;
            uint256 tokenPairPrice2 = pairTokenPrices[tokenPair2].transactionPrice;

            return tokenPairPrice1.mul(tokenPairPrice2).div(PRICE_PRODUCT).mul(denominatorPrice).div(moleculePrice);
        }
    }

    function getTokenTransactionPrice(Token _token) public view returns(uint, uint) {
        require(TOKEN_ETH_ADDRESS != _token);
        bytes32 tokenPair = keccak256(abi.encodePacked(TOKEN_ETH_ADDRESS, _token));
        require(isPairToken[tokenPair]);
        return (pairTokenPrices[tokenPair].marketPrice, pairTokenPrices[tokenPair].transactionPrice);
    }

    event SetTokenPairIsEnable(Token _fromToken, Token _toToken, bool isEnable);
    /**
     * @dev Set function of two token swap
     * @param _toToken toToken address
     * @param _toToken toToken address
     * @param isEnable true, function normal; false, function stop.
     */
    function setTokenPairIsEnable(Token _fromToken, Token _toToken, bool isEnable) public onlyOwner {
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
        isPairToken[tokenPair] = isEnable;
        emit SetTokenPairIsEnable(_fromToken, _toToken, isEnable);
    }

    /**
     * @dev return function of two token swap
     * @param _toToken toToken address
     * @param _toToken toToken address
     * @return bool
     */
    function getTokenPairIsEnable(Token _fromToken, Token _toToken) public view onlyOwner returns(bool) {
        require(isTokenIncluded[_fromToken] && isTokenIncluded[_toToken]);
        bytes32 tokenPair = keccak256(abi.encodePacked(_fromToken, _toToken));
        return isPairToken[tokenPair];
    }

    event SetThorNetworkContract(address _thorNetworkContract);
    /**
     * @dev set ThorNetwork contracts
     * @param _thorNetworkContract ThorNetwork contract
     */
    function setThorNetworkContract(address _thorNetworkContract) public onlyOwner {
        require(_thorNetworkContract != address(0));
        thorNetwork = _thorNetworkContract;
        emit SetThorNetworkContract(_thorNetworkContract);
    }

    /**
     * @dev return ThorNetwork contracts
     * @return _thorNetworkContract ThorNetwork contract
     */
    function getThorNetworkContract() public view onlyOwner returns(address) {
        return thorNetwork;
    }

}

contract THORToken1 is StandardToken {
    using SafeMath for uint256;

    string public constant name = "THORToken1";   //Token name
    string public constant symbol = "THT1";            //Token symbol
    uint8 public decimals = 12;
    uint256 public INITIAL_SUPPLY = 10000000000 * 10 ** uint256(decimals);     //Token initial_supply 10 billion

    event Mint(address indexed _to, uint256 _value);    //Mint tokens

    constructor() public payable{
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
    }                                                         
}
pragma solidity ^0.4.18;

/*
VERSION 02/02/2018
*/

//import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol"";

/****************************************

 если проблема в заливкой, то можно убрать ввод address и вбить статично

*****************************************/



contract owned 
{
    address public owner;
    address public candidate;
	
    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) onlyOwner public {
        candidate = newOwner;
    }
	
	function confirmOwner() public {
        require(candidate == msg.sender); // run by name=candidate
		owner = candidate;
    }
}


// <ORACLIZE_API>

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}
contract usingOraclize {
	
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI 
	{
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool)
	{
		return oraclize_setNetwork();
		networkID; // silence the warning and remain backwards compatible
    }
	
    function oraclize_setNetwork() internal returns(bool)
	{
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
//            oraclize_setNetworkName("eth_mainnet");
            return true;
        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
//            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }

        return false;
    }


    function __callback(bytes32 myid, string result) public {
        __callback(myid, result, new bytes(0));
    }
    
    function __callback(bytes32 myid, string result, bytes proof) pure public {
      return;
      myid; result; proof; // Silence compiler warnings
    }

	/*
    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }
	*/

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
	

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }

	/*
    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }
	*/

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

	
    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

/*
    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal view returns (string) {
        return oraclize_network_name;
    }
*/
}

// </ORACLIZE_API>

contract ERC721 
{
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
 
	event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);
    // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);
}


contract SimpleLottery is ERC721, usingOraclize
{
// <ERC721>
    string public name = "CryptoSport";
    string public symbol = "CS";
	
	struct Token
	{
        uint256 price;			// цена токена
		uint256 combination;	// ставка
		bool payout;			// выплачен
        uint256 payment;		// сумма выплаты (выиграш или отмена лотерии)
	}
	Token[] public tokens;
	
	// A mapping from tokens IDs to the address that owns them. All tokens have some valid owner address
	mapping (uint256 => address) public tokenIndexToOwner;
	
	// A mapping from owner address to count of tokens that address owns.	
	mapping (address => uint256) ownershipTokenCount; 

	// A mapping from tokenIDs to an address that has been approved to call transferFrom().
    // Each token can only have one approved address for transfer at any time.
    // A zero value means no approval is outstanding.
    mapping (uint256 => address) public tokenIndexToApproved;
	
	function implementsERC721() public pure returns (bool)
    {
        return true;
	}
	
    function totalSupply() public view returns (uint) 
	{
        return tokens.length;
    }

	function balanceOf(address _owner) public view returns (uint256 count) 
	{
        return ownershipTokenCount[_owner];
    }
	
	function ownerOf(uint256 _tokenId) public view returns (address owner)
    {
        owner = tokenIndexToOwner[_tokenId];
        require(owner != address(0));
    }
	
	// Marks an address as being approved for transferFrom(), overwriting any previous approval. 
    // Setting _approved to address(0) clears all transfer approval.
    function _approve(uint256 _tokenId, address _approved) internal 
	{
        tokenIndexToApproved[_tokenId] = _approved;
    }
	
	// Checks if a given address currently has transferApproval for a particular token.
    // param _claimant the address we are confirming token is approved for.
    // param _tokenId token id, only valid when > 0
	function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToApproved[_tokenId] == _claimant;
    }
	
	function approve( address _to, uint256 _tokenId ) public
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }
	
	function transferFrom( address _from, address _to, uint256 _tokenId ) public
    {
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }
	
	function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }
	
    function _transfer(address _from, address _to, uint256 _tokenId) internal 
	{
        ownershipTokenCount[_to]++;
        tokenIndexToOwner[_tokenId] = _to;

        if (_from != address(0)) 
		{
			ownershipTokenCount[_from]--;
			// clear any previously approved ownership exchange
            delete tokenIndexToApproved[_tokenId];
		}
		
        Transfer(_from, _to, _tokenId);
    }
	
    function transfer( address _to, uint256 _tokenId ) public
    {
        require(_to != address(0));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
// </ERC721>

	function getTokenByID(uint256 _id) public view returns ( 
			uint256 price, 
			uint256 combination, 
			bool payout,
			uint256 payment, 
			address owner 
	){
        Token storage tkn = tokens[_id];
		price = tkn.price;
		combination = tkn.combination;
		payout = tkn.payout;
		payment = tkn.payment;
		if (desc.winCombination==combination) payment = desc.betsSumIn * tkn.price / betsAll[desc.winCombination].sum;
		if (status == Status.CANCELING) payment = tkn.price;
		
		owner = tokenIndexToOwner[_id];
    }
	
	function uint2str(uint i) internal pure returns (string)
	{
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
	
	function strConcat(string _a, string _b, bool comma) internal pure returns (string)
	{
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
		string memory ab;
        if (_ba.length!=0 && comma) ab = new string(_ba.length + _bb.length + 1);
							   else ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
		if (_ba.length!=0 && comma) bab[k++] = ",";
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }
	
	function getUserTokens(address user) public view returns ( string res ) 
	{
		res="";
		require(user!=0x0);
		for (uint256 i = 0; i < tokens.length; i++) 
		{
			if (user == tokenIndexToOwner[i]) res = strConcat( res, uint2str(i), true );
		}
    }
	
	
	
	enum Status 
	{
		CREATING,		//0 создание
		PLAYING,		//1 покупка билетов
		PROCESSING,		//2 ожидание результата
        PAYING,	 		//3 выдача выигрыша
		CANCELING		//4 аннулирование игры
    }

	
	uint256 private constant WEI = 10**18;
	uint256 private constant PELLER = 1 * WEI / 1000;

	
	struct Description {
		string  nameLottery;			// название
		uint256 countCombinations;		// количество комбинаций ставок в игре
		uint256 maxCountStakePerComb;	// максимальное количество ставок на каждую комбинацию
		uint256 dateStopBuy;
		uint256 minStake;				// 0.001 эфира
		uint256 fee;					// %
		uint256 betsSumIn;				// сумма всех поставленных ставок всех комбинаций
		uint256 betsSumOut;				// сумма розданных ставок
		uint256 winCombination;			// выигрышная комбинация
	}
	
	Status private status;
	Description public desc;
	
	struct Stake {
		uint256 sum;		// сумма комбинации
		uint256 count;		// кол-во ставок данной комбинации
	}
	mapping(uint256 => Stake) public betsAll;	// комбинация_ставки->[сумма_ставки,кол-во]

	
	event LogInitGame( string _nameLottery, address gameaddress );
	event LogBuyToken(address user, uint256 combination, uint256 userStake, uint256 tokenId);
	event LogSendMoney(string what, address user, uint256 value);
	event LogResolveLottery( uint256 winCombination );
	event LogOraclize( string msg, string value );
	

	address public owner;
	address public admin;

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
	
	modifier onlyPlayer {
        require(msg.sender != owner);
        _;
    }

	function getStatus() public view returns ( Status )
	{
		Status tmp = status;
		if ( tmp == Status.PLAYING && timenow() > desc.dateStopBuy ) tmp = Status.PROCESSING;
        return tmp;
	}
	
	function SimpleLottery(address _owner) public 
	{ 
	/*
		require( _owner != 0x0 );
		owner=_owner;
		status = Status.CREATING;
		*/
		admin = 0x230c9a8f235d88bbc8f9b589e17b4a4adbb286fc;
		if (_owner==0x0) owner = 0xaC5c6E5aCc19C23EE9f09cdD8F091e298d6C4931;
			else owner=_owner;
		status = Status.CREATING;
	}

	function initLottery( string _nameLottery, uint256 _countCombinations, 
						  uint256 _maxCountStakePerComb, uint256 _dateStopBuy
						) onlyOwner public {

		require( status == Status.CREATING );
						
		// проверить вводимые параметры на не 0
		require( _countCombinations > 0 );
		require( _maxCountStakePerComb > 0 );
		require( _dateStopBuy > timenow() );
		
		desc.nameLottery = _nameLottery;
		desc.countCombinations = _countCombinations;
		desc.maxCountStakePerComb = _maxCountStakePerComb;
		desc.dateStopBuy = _dateStopBuy;
		
		desc.betsSumIn = 0;
		desc.betsSumOut = 0;
		desc.winCombination = 0;
		
		desc.minStake 	= PELLER;
		desc.fee		= 4;
		status = Status.PLAYING;
		
		// временные переменные:
		// desc.dateStopBuy = timenow() + 24*60*60;				// 1 день

		LogInitGame( _nameLottery, this );
	}
	
	function timenow() public view returns(uint256) { return block.timestamp; }
//	function freezeLottery() public onlyOwner { isFreezing = true; }
//	function unfreezeLottery() public onlyOwner { isFreezing = false; }
	function () payable public { require (msg.value == 0x0); }
	
	/*
	// временнная функция 
	function updateTime(uint256 _dateStopBuy) onlyOwner public
	{
		desc.dateStopBuy = _dateStopBuy;
	}
	*/
	
	function buyToken(uint256 combination, address captainAddress) payable onlyPlayer public
	{
		require( status == Status.PLAYING );
		require( timenow() < desc.dateStopBuy );
		require( combination <= desc.countCombinations );
		require( combination != 0 );
		require( captainAddress != msg.sender );
		
		// проверить хватает ли денег на покупку
		require( msg.value >= desc.minStake );
		
		// проверить не вышли за предел кол-ва ставок
		require( betsAll[combination].count < desc.maxCountStakePerComb );
		
		uint256 userStake = msg.value;
		uint256 feeValue = userStake * desc.fee / 100;
		userStake = userStake - feeValue;
		
		uint256 captainValue = 0;
		if (captainAddress!=0x0)
		{
			captainValue = msg.value / 100;	// 1 %
			userStake = userStake - captainValue;
		}		
		
		// увеличиваю сумму ставок
		desc.betsSumIn = desc.betsSumIn + userStake;
		betsAll[combination].sum += userStake;
		
		// уменьшаю кол-во свободных билетов
		betsAll[combination].count += 1;
		
		Token memory _token = Token({
			price: userStake,
			combination: combination,
			payout : false,
			payment : 0
		});

		uint256 newTokenId = tokens.push(_token) - 1;
		_transfer(0, msg.sender, newTokenId);
		
		LogBuyToken( msg.sender, combination, userStake, newTokenId );

		// забираем комиссию
		admin.transfer(feeValue); 
		LogSendMoney( "FEECONTRACT", admin, feeValue );
		
		// отправляем бонус
		if (captainAddress!=0x0) 
		{
			captainAddress.transfer(captainValue);
			LogSendMoney( "CAPTAIN", captainAddress, captainValue );
		}
	}
	
	// лотерея отменена - возврат стоимости билета
	function returnToken(uint256 _tokenId) onlyPlayer public 
	{
		require( status == Status.CANCELING );
		require( msg.sender == tokenIndexToOwner[_tokenId] );	// хозяин текущий
		require( tokens[_tokenId].payout == false ); // еще не выплачен
			
		uint256 sumPayment = tokens[_tokenId].price;
			
		// обнуляю текущий токен
		tokens[_tokenId].payout = true;
		tokens[_tokenId].payment = sumPayment;
		
		desc.betsSumOut += sumPayment;
		
		// отправляю деньги отправителю
		msg.sender.transfer(sumPayment);
		LogSendMoney( "RETURN", msg.sender, sumPayment );
	}
		

	// выплата приза
	function claimPrize(uint256 _tokenId) onlyPlayer public 
	{
		require( status == Status.PAYING );

		require( msg.sender == tokenIndexToOwner[_tokenId] );	// хозяин текущий
		require( tokens[_tokenId].combination == desc.winCombination ); // Есть выигрышный токен		
		require( tokens[_tokenId].payout == false ); // еще не выплачен

		// вычисляю цену выигрыша
		uint256 sumPayment = desc.betsSumIn * tokens[_tokenId].price / betsAll[desc.winCombination].sum;

		// обнуляю текущий токен
		tokens[_tokenId].payout = true;
		tokens[_tokenId].payment = sumPayment;
	
		desc.betsSumOut += sumPayment;
		
		// отправляю деньги отправителю
		msg.sender.transfer(sumPayment); 
		LogSendMoney( "PRIZE", msg.sender, sumPayment );
	}

	
	function emergencyCancelLottery() public 
	{
		require( status == Status.PLAYING );
		require( timenow() > desc.dateStopBuy + 7 * 24*60*60 ); // after 7 days
		status = Status.CANCELING;
	}
	
	function cancelLottery() onlyOwner public 
	{
		require( status == Status.PLAYING );
		status = Status.CANCELING;
	}

	function checkNobodyWin() private
	{
		// никто не выиграл 
		if ( betsAll[desc.winCombination].count == 0 )
		{
			LogSendMoney( "NOBODYWIN", admin, this.balance );
			admin.transfer(this.balance);
		}
	}
	
	function __callback(bytes32 , string _result) public
	{
		require( status == Status.PLAYING );
		require( timenow() > desc.dateStopBuy );
        require (msg.sender == oraclize_cbAddress());

        desc.winCombination = parseInt(_result);
		
		status = Status.PAYING;
		LogResolveLottery( desc.winCombination  );
		
		checkNobodyWin();
    }

    function resolveLotteryByOraclize( string key ) onlyOwner public payable
	{
        LogOraclize("Oraclize query was sent, waiting for the answer..", key );
		
		string memory tmp;
		tmp = strConcat( "json(http://52.60.180.219/api/v1/game/", key, false );
		tmp = strConcat( tmp, "/result).result", false );
	
		oraclize_query("URL",tmp);
    }

	function resolveLotteryByHand( uint256 combination ) onlyOwner public 
	{
		require( status == Status.PLAYING );
		
		// возможность запуска через сутки, если не получилось через Oraclize
		require( timenow() > desc.dateStopBuy + 24*60*60 );
		
		// решение лотереи
		desc.winCombination = combination;
		
		status = Status.PAYING;
		LogResolveLottery( desc.winCombination );
		
		checkNobodyWin();
	}	
	
}

contract Lotterres is owned
{
	uint256 public countGames = 0;
	mapping (uint256 => SimpleLottery) public games;
	
	function Lotterres() public {}
	
	function addGame() public onlyOwner 
	{
		games[countGames++] = new SimpleLottery(msg.sender);
	}
	
}

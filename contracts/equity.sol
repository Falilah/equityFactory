//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract EquityFactory {
    //@notice: Equity Generator is a contract that allows company to gather capital
    // for the purpose of their business and  pay a dividend back halfyearly.
    uint256 public identifier;

    struct Equity {
        string name;
        uint256 capital;
        uint256 minimumStake;
        address companyAddress;
        address[] shareholder;
        uint256 expectedYield;
        uint256 totalMoneyGenerated;
        uint256 dividendPayable;
        uint256 time;
        mapping(address => uint256) balances;
        bool valid;
    }
    mapping(uint256 => Equity) public equity;
    uint256[] private identifiers;

    //the whitelisted functionalities can be added to give trust
    //to the company their integrity can be vouch for
    function addEquity(
        string memory _name,
        uint256 _capital,
        uint256 _minimumStake,
        uint256 _expectedYield
    ) external returns (uint256) {
        (uint256 _id, Equity storage _e) = setIdentifier(_expectedYield);
        _e.name = _name;
        _e.capital = _capital;
        _e.minimumStake = _minimumStake;
        _e.companyAddress = msg.sender;
        _e.expectedYield = (10000 * _expectedYield) / 100;

        _e.valid = true;
        return _id;
    }

    function shareholderStake(uint256 equityId)
        external
        payable
        returns (uint256 _expectedyield)
    {
        Equity storage e = getIdentifier(equityId);
        require(e.valid == true, "invalid ID");
        require(msg.value >= e.minimumStake, "too little to hold a stake");
        require(e.totalMoneyGenerated < e.capital, "Capital met");
        e.totalMoneyGenerated += msg.value;
        e.shareholder.push(msg.sender);
        e.balances[msg.sender] += msg.value;
        _expectedyield = e.balances[msg.sender] * e.expectedYield;
    }

    function withdrawCapital(uint256 equityId) external {
        Equity storage e = getIdentifier(equityId);
        require(msg.sender == e.companyAddress, "not the company's address");
        e.dividendPayable = (e.expectedYield * e.totalMoneyGenerated) / 10000;
        payable(e.companyAddress).transfer(e.totalMoneyGenerated);
        e.totalMoneyGenerated = 0;
        e.valid = false;
    }

    function payDividend(uint256 id) external payable {
        Equity storage e = getIdentifier(id);
        setTimer(id);
        require(msg.sender == e.companyAddress, "a wrong id ");
        require(msg.value == e.dividendPayable, "invalid amount");
        address[] memory s = getShareholders(id);
        for (uint256 i = 0; i < s.length; i++) {
            uint256 individualPayout = (e.balances[s[i]] * e.expectedYield) /
                10000;
            e.balances[s[i]] -= individualPayout;
            payable(s[i]).transfer(individualPayout);
        }
    }

    function setTimer(uint256 id) internal {
        Equity storage e = getIdentifier(id);
        //the pay day can be customised, this little time is for quick testin of the contract
        require(block.timestamp - e.time > 3 seconds, "Not the payday");
        e.time = block.timestamp;
    }

    function getValidIdentifiers()
        external
        view
        returns (uint256[] memory validId)
    {
        validId = identifiers;
    }

    function getpayout(uint256 id)
        public
        view
        returns (uint256 _id, uint256 yield)
    {
        _id = equity[id].dividendPayable;
        yield = equity[id].expectedYield;
    }

    function setIdentifier(uint256 _id)
        internal
        returns (uint256 id, Equity storage e)
    {
        id = generateRandomID(_id);
        e = getIdentifier(id);
        identifier += 10;
        return (id, e);
    }

    function getShareholders(uint256 id)
        internal
        view
        returns (address[] memory shareholders)
    {
        shareholders = equity[id].shareholder;
    }

    function generateRandomID(uint256 random) internal returns (uint256 id) {
        id = uint256(keccak256(abi.encodePacked(identifier++))) % random;
        identifier++;
        identifiers.push(id);
        return id;
    }

    function getIdentifier(uint256 id) internal view returns (Equity storage) {
        Equity storage e = equity[id];
        return e;
    }

    function getBalanec() external view returns (uint256 bal) {
        bal = address(this).balance;
    }
}

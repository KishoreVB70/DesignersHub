// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Designer hubs is a platform where creatives come to seek other designers from other fields and expertise to
//to join their creative abilities in carrying out and completing a particular project, the designers in turn 
//book a spot by buying gigs

contract Designershub {

    uint internal designersLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Designer {
        address payable owner;
        string expertise;
        string name;
        string onlinePortfolio;
        string location;
        uint yearsExperience;
        uint price;
        uint designTeam;
    }

    modifier onlyOwner(uint _index){
        require(msg.sender == designers[_index].owner, "Only the owner can access this function");
        _;
    }

    mapping (uint => Designer) internal designers;

    function addDesigner(
        string memory _expertise,
        string memory _name,
        string memory _onlinePortfolio,
        string memory _location,
        uint _yearsExperience, 
        uint _price
    ) public {
        uint _designTeam = 0;
        designers[designersLength] = Designer(
            payable(msg.sender),
            _expertise,
            _name,
            _onlinePortfolio,
            _location,
            _yearsExperience,
            _price,
            _designTeam
        );
        designersLength++;
    }

    // for designers to book design gigs
    function bookDesigners(uint _index) public payable  {
        require(msg.sender != designers[_index].owner, "Owner cannot buy");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            designers[_index].owner,
            designers[_index].price
          ),
          "Transfer failed."
        );
        designers[_index].designTeam++;
    }

// Function using which the owner can change the price 
    function changePrice(uint _index, uint _price) public onlyOwner(_index){
        designers[_index].price = _price;
    }

    function getDesigns(uint _index) public view returns (
        address payable,
        string memory, 
        string memory,
        string memory,
        string memory, 
        uint,
        uint, 
        uint
    ) {
        Designer memory d = designers[_index];
        return (

            d.owner,
            d.expertise, 
            d.name,
            d.onlinePortfolio,
            d.location, 
            d.yearsExperience,
            d.price,
            d.designTeam
        );
    }


// remove a remove design jobs
    function removeDesignjobs(uint _index) external onlyOwner(_index){   
            designers[_index] = designers[designersLength - 1];
            delete designers[designersLength - 1];
            designersLength--; 
	}

    //pay back designers who aren't qualified, or didn't meet up the criteria
    function refund(uint _index, address payable _address) public payable  {
        require(msg.sender == designers[_index].owner, "Not owner");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            payable (_address),
            designers[_index].price
          ),
          "Transfer failed."
        );
    }

    
    function getDesignersLength() public view returns (uint) {
        return (designersLength);
    }
}
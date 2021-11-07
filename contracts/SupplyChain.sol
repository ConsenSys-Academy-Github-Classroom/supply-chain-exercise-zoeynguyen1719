// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  // <owner>
  address owner 
  

  // <skuCount>
  uint private skuCount;

  // <items mapping>
  mapping(uint => Item) public items;

  // <enum State: ForSale, Sold, Shipped, Received>
  enum State{ForSale, Sold, Shipped, Received}


  // <struct Item: name, sku, price, state, seller, and buyer>
 struct Item {
        string name;
        uint sku;
        uint256 price;
        State state;
        address payable seller;
        address payable buyer;
    }

    
  
  /* 
   * Events
   */

  // <LogForSale event: sku arg>
    event LogForSale(uint sku, string name);
  // <LogSold event: sku arg>
    event LogSold(uint sku);
  // <LogShipped event: sku arg>
    event LogShipped(uint sku);
  // <LogReceived event: sku arg>
   event Received(uint sku);


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner
    modifier isOwner(){
        require(
            msg.sender == owner,
            "Only the owner can call this function"
            );
        _;
    }

  modifier verifyCaller (address _address) { 
    // require (msg.sender == _address); 
     require(
            msg.sender == _address,
            "Only verified role players can call this function"
            );
        _;
    _;
  }

  modifier paidEnough(uint _price) { 
    // require(msg.value >= _price); 
     require(
            msg.value >= _price,
            "You dont have enough money to make this purchase"
            );
        _;
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
      uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    // uint _price = items[_sku].price;
    // uint amountToRefund = msg.value - _price;
    // items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  // modifier forSale
  // modifier sold(uint _sku) 
  // modifier shipped(uint _sku) 
  // modifier received(uint _sku) 

  constructor() public {
     owner = msg.sender;
        skuCount = 0;
    // 1. Set the owner to the transaction sender
    // 2. Initialize the sku count to 0. Question, is this necessary?
  }


    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true
      function addItem(string memory _name, uint _price) public returns(bool){
        items[skuCount] = Item(_name, skuCount, _price, State.ForSale, msg.sender, address(0));
        emit ForSale(skuCount, _name);
        skuCount = skuCount + 1;
        return true;
    }

    // hint:
    // items[skuCount] = Item({
    //  name: _name, 
    //  sku: skuCount, 
    //  price: _price, 
    //  state: State.ForSale, 
    //  seller: msg.sender, 
    //  buyer: address(0)
    //});
    //
    //skuCount = skuCount + 1;
    // emit LogForSale(skuCount);
    // return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint sku) public payable {
      checkItemState(sku,State.ForSale)
      paidEnough(items[sku].price)
      restrictCaller(items[sku].seller)
      checkValue(sku)
    {
        items[sku].state = State.Sold;
        /*The address that calls the function is assigned as the buyer*/
        items[sku].buyer = msg.sender;
        emit Sold(items[sku].sku);
        items[sku].seller.transfer(items[sku].price);
    }}

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public {
      checkItemState(sku,State.Sold)
      verifyCaller(items[sku].seller)
    {
        items[sku].state = State.Shipped;
        emit Shipped(items[sku].sku);
    }
}

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public {   
      checkItemState(sku,State.Shipped)
      verifyCaller(items[sku].buyer)
    {
        items[sku].state = State.Received;
        emit Received(items[sku].sku);
    }}

  // Uncomment the following code block. it is needed to run tests
  /* function fetchItem(uint _sku) public view */ 
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }

  /*   returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) */ 
  /* { */
  /*   name = items[_sku].name; */
  /*   sku = items[_sku].sku; */
  /*   price = items[_sku].price; */
  /*   state = uint(items[_sku].state); */
  /*   seller = items[_sku].seller; */
  /*   buyer = items[_sku].buyer; */
  /*   return (name, sku, price, state, seller, buyer); */
  /* } */
}

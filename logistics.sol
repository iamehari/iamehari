pragma solidity ^0.4.23;
contract logistics {
    address public owner;
    address registerid;
    address[]  totalitems;
    address[]  totalorders;
    address[]  carrierrequests;
    struct package 
    {
        uint itemid;
        string itemname;
        string transitstatus;
        uint orderstatus; //1=orderd;2=in-transit;3=delivered;4=cancel;
        uint ordertime;
        address customer;
        address carrier1;
        uint carrier1_time;
        address carrier2;
        uint carrier2_time;
        address carrier3;
        uint carrier3_time;
    }
    struct items {
        uint itemid;
        string itemname;
        string itemtype;
    }
    mapping(address => bool) public carriers;
    mapping(address => package) public  packagemap;
    mapping(address => items) public itemslist;
    constructor() 
    {
     owner=msg.sender;    
    }
    modifier onlyowner 
    {
        require(msg.sender==owner);
        _;
    }
  /*  modifier notorderowner 
    {
    }*/ 
    function item_insert(uint _itemid,string _itemname,string _itemtype) onlyowner returns(address)
    {
        registerid = address(sha256(msg.sender,now));
        itemslist[registerid].itemid=_itemid;
        itemslist[registerid].itemname=_itemname;
        itemslist[registerid].itemtype=_itemtype;
       // itemslist[uniqueid].price=_price;
        totalitems.push(registerid);
        return registerid;
    }
    
    function order_item(address _registerid) 
    {
    for(uint i=0;i<=totalitems.length-1;i++)
       {
           if( _registerid == totalitems[i])
          {
        packagemap[_registerid].itemid = itemslist[_registerid].itemid;
        packagemap[_registerid].itemname = itemslist[_registerid].itemname;
        packagemap[_registerid].transitstatus = "your package is ordered and is under processing";
        packagemap[_registerid].orderstatus = 1;
        packagemap[_registerid].customer = msg.sender;
        packagemap[_registerid].ordertime=now;
        totalorders.push(_registerid);
        delete totalitems[i];
          }
       }
    }
    function managecarriers(address _carrieraddress) onlyowner public  returns(string)
    {
        if(!carriers[_carrieraddress])
        {
           /* for(uint i=0;i<=carrierrequests.length-1;i++)
            {
                if(carrierrequests[i] == _carrieraddress)
                {
                carriers[_carrieraddress] = true;
                for (uint j=i;j<=carrierrequests.length-1;j++)
                {
                carrierrequests[j]=carrierrequests[j+1];
                }
                }
                
            }
            delete carrierrequests[carrierrequests.length-1];
            carrierrequests.length--;
        }*/
        carriers[_carrieraddress]=true;
        }
        else {
            carriers[_carrieraddress] = false;
        }
        return "carrier status  is updated";
    }
    function request_as_carrier() public 
    {
        uint i;
        uint counter=0;
        if(carrierrequests.length == 0 )
          {
            carrierrequests.push(msg.sender);
          }
          else {
              for(i=0;i<carrierrequests.length;i++)
              {
                  require(msg.sender != carrierrequests[i]);
                  counter++;
              }
              require(counter == carrierrequests.length);
              carrierrequests.push(msg.sender);
              }
        }
    function cancelorder(address _uniqueid) public returns(string)
    {
       // require(packagemap[_uniqueid].isuidgenerated);
        require(packagemap[_uniqueid].customer == msg.sender);
        require(packagemap[_uniqueid].orderstatus != 3);
        packagemap[_uniqueid].orderstatus = 4;
        packagemap[_uniqueid].transitstatus = "your order has been canceled";
        return "your order has been canceled succuessfully";
    }
    function carrier1report(address _uniqueid,string _transitstatus)
    {
        // require(packagemap[_uniqueid].isuidgenerated);
         require(carriers[msg.sender]);
         require(packagemap[_uniqueid].orderstatus == 1);
         packagemap[_uniqueid].transitstatus = _transitstatus;
         packagemap[_uniqueid].carrier1=msg.sender;
         packagemap[_uniqueid].carrier1_time= now;
         packagemap[_uniqueid].orderstatus =2;
         carriers[msg.sender]=false;
    }
     function carrier2report(address _uniqueid,string _transitstatus)
    {
        // require(packagemap[_uniqueid].isuidgenerated);
         require(carriers[msg.sender]);
         require(packagemap[_uniqueid].orderstatus == 2);
         packagemap[_uniqueid].transitstatus = _transitstatus;
         packagemap[_uniqueid].carrier2=msg.sender;
         packagemap[_uniqueid].carrier2_time= now;
         packagemap[_uniqueid].orderstatus =2;
         carriers[msg.sender]=false;
    }
     function carrier3report(address _uniqueid,string _transitstatus)
    {
        // require(packagemap[_uniqueid].isuidgenerated);
         require(carriers[msg.sender]);
         require(packagemap[_uniqueid].orderstatus == 2);
         packagemap[_uniqueid].transitstatus = _transitstatus;
         packagemap[_uniqueid].carrier3=msg.sender;
         packagemap[_uniqueid].carrier3_time= now;
         packagemap[_uniqueid].orderstatus =3;
         carriers[msg.sender]=false;
    }

    function orderlist() public view returns(address[])
    {
            return totalorders;
    }
    function carrier_requests() public view returns(address[])
    {
        return carrierrequests;
     }
     function itemlist() public view returns(address[])
     {
         return totalitems;
     }
}
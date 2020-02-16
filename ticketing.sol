pragma solidity ^0.4.23;
contract eventticketing {
        string  eventname;
        string  place;
        string  date;
        string time;
        uint contactno;
    struct register{
        uint amount;
        uint totaltickets;
        string email;
        string name;
        uint phoneno;
        uint tamount;
    }
    address public owner;
    address ticketowner;
    uint public ticketsold;
    uint public ticketsremain;
    uint public quota;
    uint public price=1 ether;
    mapping(address=>register) registerpaid;
    event deposit(address _from,uint _amount);
    event refund(address _to,uint _amount);
    modifier onlyowner()
    {
        require(msg.sender==owner);
        _;
        
    }
    modifier onlyauthorised()
    {
      require(msg.sender==ticketowner);
      _;
    }
    modifier soldout()
    {
        require(ticketsold < quota);
        _;
    }
    constructor (uint _quota,string _eventname,string _place,string _date,string _time,uint _contactno)  public
    {
        owner=msg.sender;
        ticketsold=0;
        ticketsremain=_quota;
        quota=_quota;
        eventname=_eventname;
        place=_place;
        date=_date;
        time=_time;
        contactno=_contactno;
    }
    function buyticket(string name,uint phoneno,string email,uint totaltickets) soldout payable public
        {
            ticketowner=msg.sender;
            uint totalamount=price*totaltickets;
            require(msg.value>=totalamount);
            if(registerpaid[msg.sender].amount>0)
            {
                registerpaid[msg.sender].name=name;
                registerpaid[msg.sender].phoneno=phoneno;
                registerpaid[msg.sender].amount +=totalamount;
                registerpaid[msg.sender].email=email;
                registerpaid[msg.sender].totaltickets +=totaltickets;
            }
            else{
                register storage r=registerpaid[msg.sender];
                r.name=name;
                r.phoneno=phoneno;
                r.amount=totalamount;
                r.email=email;
                r.totaltickets=totaltickets;
            }
            ticketsold=ticketsold+totaltickets;
            if(msg.value>totalamount)
            {
                uint refundamount=msg.value-totalamount;
                require(msg.sender.send(refundamount));
            }
           emit deposit(msg.sender,msg.value);
           ticketsremain=totaltickets-ticketsold;
        }
    function refundticket(address buyer1) onlyowner public payable 
    {
            if(registerpaid[buyer1].amount>0)
            {
                if(this.balance >= registerpaid[buyer1].amount)
                {
                   require(buyer1.send(registerpaid[buyer1].amount));
                  emit  refund(buyer1,registerpaid[buyer1].amount);
                   ticketsold -=registerpaid[buyer1].totaltickets;
                   ticketsremain=ticketsremain+registerpaid[buyer1].totaltickets;
                        registerpaid[buyer1].amount=0;
                }
            }
        }
        function withdrawfunds() onlyowner public payable  {
            require(owner.send(this.balance));
        }
           function buyer(address buyer2)  public onlyauthorised returns(string eventname,string place,string date,string time,uint contactno,string ticketername,uint totaltickets)
            {
                register memory rd=registerpaid[buyer2];
                return (eventname,place,date,time,contactno,
                        rd.name,
                        rd.totaltickets);
            }
            function kill() onlyowner public
            {
                suicide(owner);
            }
}
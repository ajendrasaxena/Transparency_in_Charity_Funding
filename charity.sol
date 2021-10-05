pragma solidity >=0.7.0 <0.9.0;

struct user{
        uint tokens;
        string name;
        bool flag;
    }

struct donation{
        address donor;
        uint tokens;
    }
    
struct Reciever{
    address reciever;
    string name;
    uint tokens;
}

contract Charity_Funding{
    
    address curr_user;
    user u;
    mapping(address => user) users;
    mapping(address => uint) pending_donation;
    address[] total_users;
    mapping(address => Reciever[]) donations;
    user[] temp;
    
    constructor() public{
        curr_user=msg.sender;
    }
    
    function my_name() public view returns(string memory t){
        
        require(users[msg.sender].flag,"User doesn't exist");
        
        t=users[msg.sender].name;
    }
    
    function register(string memory name) public {    //  to register
        require(!users[msg.sender].flag,"User Already exist");
        
        users[msg.sender].name=name;
        users[msg.sender].flag=true;
        total_users.push(msg.sender);
    }
    
    function add_token(uint t) public{   // to add token
        require(users[msg.sender].flag,"User doesn't exist");
        
        users[msg.sender].tokens+=t;
    }
    
    function my_tokens() public view returns(uint t){  // To see current tokens in account
        require(users[msg.sender].flag,"User doesn't exist");
        
        t=users[msg.sender].tokens;
    }
    
    function donate(uint t) public{   // to Donate
        
        require(users[msg.sender].flag,"User doesn't exist");
        require(t>0,"Donation amount should be greater than zero!!");
        require(users[msg.sender].tokens >= t,"USer doesn't have enough tokens");
       
        users[msg.sender].tokens-=t;
        pending_donation[msg.sender]+=t;
        
    }
    
    function my_pending_donations() public view returns(uint t){  //for finding donations which are already pending
        
        require(users[msg.sender].flag,"User doesn't exist");
        
        t=pending_donation[msg.sender];
        
    }
    
    function total_pending_donation() public view returns(uint t){ // for finding total pending donation
        uint n=total_users.length;
        uint total_pending=0;
        for(uint i=0;i<n;i++){
            total_pending+=pending_donation[total_users[i]];
        }
        t=total_pending;
    }
    
    function revert_my_pending_donation() public {
         require(users[msg.sender].flag,"User doesn't exist");
         require(pending_donation[msg.sender]>0,"There is no pending donation belonging to you!!");
         
         users[msg.sender].tokens+=pending_donation[msg.sender];
         pending_donation[msg.sender]=0;
    }
    
    donation d;
    Reciever r;
    
    function Require(uint t) public {   // Requirement of donation
        
        require(users[msg.sender].flag,"User doesn't exist");
        
        uint total=total_pending_donation();
        
        require(total>=t,"Not enough donations!!");
        
        users[msg.sender].tokens+=t;
        
        uint n=total_users.length;
        
        for(uint i=0;i<n;i++){
            if(t>0){
                if(pending_donation[total_users[i]]>=t){
                    pending_donation[total_users[i]]-=t;
                    r.reciever=msg.sender;
                    r.tokens=t;
                    r.name=users[msg.sender].name;
                    donations[total_users[i]].push(r);
                    t=0;
                }
                else {
                    r.reciever=msg.sender;
                    r.tokens=pending_donation[total_users[i]];
                    r.name=users[msg.sender].name;
                    donations[total_users[i]].push(r);
                    t-=pending_donation[total_users[i]];
                    pending_donation[total_users[i]]=0;
                }
            }
        }
        
    }
    
    function my_donations() public view returns(Reciever[] memory t){ //finding donation for particular message
        require(users[msg.sender].flag,"User doesn't exist");
        t=donations[msg.sender];
    }
    
}

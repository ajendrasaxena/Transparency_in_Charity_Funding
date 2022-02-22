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
    mapping(address => uint) public donation_done;
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
    
    function revert_my_pending_donation() public {  // reversing the smart contract
         
         require(users[msg.sender].flag,"User doesn't exist");
         require(pending_donation[msg.sender]>0,"There is no pending donation belonging to you!!");
         
         users[msg.sender].tokens+=pending_donation[msg.sender];
         pending_donation[msg.sender]=0;
         
    }
    
    donation d;
    Reciever r;
    
    function Require(uint t) public {   // Recieve tokens thorugh FCFS
        
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
                    donation_done[total_users[i]]+=t;
                    r.tokens=t;
                    r.name=users[msg.sender].name;
                    donations[total_users[i]].push(r);
                    t=0;
                    //users[total_users[i]].tokens+=1;
                }
                else {
                    r.reciever=msg.sender;
                    r.tokens=pending_donation[total_users[i]];
                    r.name=users[msg.sender].name;
                    donations[total_users[i]].push(r);
                    donation_done[total_users[i]]+=pending_donation[total_users[i]];
                    t-=pending_donation[total_users[i]];
                    pending_donation[total_users[i]]=0;
                    //users[total_users[i]].tokens+=1;
                }
            }
        }
        
    }
    
    function Require2(uint t) public { // Recieve with some other algorithm
        
        require(users[msg.sender].flag,"User doesn't exist");
        
        uint total=total_pending_donation();
        
        require(total>=t,"Not enough donations!!");
        
        users[msg.sender].tokens+=t;
        
        uint n=total_users.length;
        
        while(t>0){
            for(uint i=0;i<n && t>0;i++){
                
                if(pending_donation[total_users[i]]>0&&t>0){
                    pending_donation[total_users[i]]-=1;
                    donation_done[total_users[i]]+=1;
                    t--;
                    r.reciever=msg.sender;
                    r.tokens=1;
                    r.name=users[msg.sender].name;
                    donations[total_users[i]].push(r);
                }
                
            }
        }
        
    } 
    
    function Require3(uint t) public {

        require(users[msg.sender].flag,"User doesn't exist");
        
        uint total=total_pending_donation();
        
        require(total>=t,"Not enough donations!!");
        
        users[msg.sender].tokens+=t;
        
        uint n=total_users.length;

        uint x=0;

        uint j=0;

        for(uint i=0;i<n;i++){
            if(pending_donation[total_users[i]]>=t){
                if(x>=pending_donation[total_users[i]]){
                    x=pending_donation[total_users[i]];
                    j=i;
                }
                else if(x==0){
                    x=pending_donation[total_users[i]];
                    j=i;
                }
            }
        }
        if(x!=0){
            pending_donation[total_users[j]]-=t;
            donation_done[total_users[j]]+=1;
            r.reciever=msg.sender;
            r.tokens=t;
            r.name=users[msg.sender].name;
            donations[total_users[j]].push(r);
        }
        else {
            Require2(t);
        }

    }

    function my_donations() public view returns(Reciever[] memory t){ //finding donation for particular message
        
        require(users[msg.sender].flag,"User doesn't exist");
        
        t=donations[msg.sender];
        
    }
    
}


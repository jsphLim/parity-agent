pragma solidity ^0.4.16;

import "./PermissionTree.sol";
contract CopyrightManage{

    enum CopyrightStatus {publish, lock, cancel,onSellOwnership,onSellPermission}

    using PermissionTree for PermissionTree.Tree;

    struct Copyright{
        string watermarking;
        uint256 registTime;
    }

    struct CopyrightUser{
        uint256 startTime;
        uint256 durations;
        string userWatermarking;
    }

    struct CopyrightManagement{
        // the man who create this copyright
        address creater;
        // current owner of this copyright
        address owner;
        // copyright
        Copyright cr;
        PermissionTree.Tree tree;
        //the users of this copyright
        mapping(address => CopyrightUser) users;
        // addressPool is used to store the user address
        address[] addressPool;



        //the status of the CopyrightUser
        CopyrightStatus copyrightStatus;
    }

    string[] private crPools;


    mapping(string => CopyrightManagement) private manages;


    event ErrorEvent(string id, uint256 amount);
    event ReportStatusEvent(string id, CopyrightStatus);
    event RegisterEvent(string id, address buyer, string watermarking);
    event TransferOwnerShipEvent(string id, address buyer, string watermarking, uint256 amount);
    event TransferPermissionEvent(string id,uint256 startTime,uint256 durations,string userWatermarking,uint256 amout, uint64 buyerId,uint level);
    event GetEvent(string id, string);

    /**
    * @param id the id of copyright
    * @param statusId the status of this copyright
   */
    function setCopyrightStatus(string id, uint64 statusId) public{
        CopyrightManagement storage m = manages[id];
        require(m.owner == msg.sender);
        require(statusId < 5);
        if(statusId == 0){
            require(m.copyrightStatus != CopyrightStatus.cancel);
            m.copyrightStatus = CopyrightStatus.publish;
        }
        if(statusId == 1){
            require(m.copyrightStatus != CopyrightStatus.cancel);
            m.copyrightStatus = CopyrightStatus.lock;
        }
        if(statusId == 2){
            require(m.copyrightStatus != CopyrightStatus.cancel);
            delete m.cr;
            delete m.addressPool;
            delete m.owner;
            delete m.tree;
            m.copyrightStatus = CopyrightStatus.cancel;
        }
        if(statusId == 3){
            require(m.copyrightStatus != CopyrightStatus.cancel);
            m.copyrightStatus = CopyrightStatus.onSellOwnership;
        }
        if(statusId == 4){
            require(m.copyrightStatus != CopyrightStatus.cancel);
            m.copyrightStatus = CopyrightStatus.onSellPermission;
        }
    }


    /**
     * register the copyright
     * @param id identify the copyright
     * @param watermarking creater's copyright watermarking
    */
    function register(string id,string watermarking) public{
        if(manages[id].creater == address(0)){
            manages[id].creater = msg.sender;
            manages[id].owner = msg.sender;
            manages[id].cr = Copyright({watermarking:watermarking,registTime:now});
            manages[id].copyrightStatus = CopyrightStatus.publish;
            manages[id].tree.initTree(msg.sender);
            crPools.push(id);
            RegisterEvent(id, msg.sender,watermarking);
        }
        else if(manages[id].copyrightStatus == CopyrightStatus.cancel){
            manages[id].creater = msg.sender;
            manages[id].owner = msg.sender;
            manages[id].tree.initTree(msg.sender);
            manages[id].cr = Copyright({watermarking:watermarking,registTime:now});
            manages[id].copyrightStatus = CopyrightStatus.publish;
        }
    }


    function transferOwnerShip(string id,string newWatermarking,uint256 amount) payable public{
        CopyrightManagement storage m = manages[id];
        address seller = m.owner;
        require(msg.value >= amount);
        require(m.copyrightStatus == CopyrightStatus.onSellOwnership);
        m.owner = msg.sender;
        m.cr.watermarking = newWatermarking;
        m.copyrightStatus = CopyrightStatus.publish;
        if(m.owner == msg.sender){
            seller.transfer(amount);
            m.tree.updateOwner(msg.sender);
            TransferOwnerShipEvent(id, msg.sender,newWatermarking,amount);
        }
        else{
            (msg.sender).transfer(msg.value);

        }
    }

    /**
     * transfer permision
     * @param id identity copyright
     * @param durations the permission continue time
     * @param userWatermarking the watermarking of id copyright of the user
     * @param amout the value of the permission of the copyright
    */
    function transferPermission(string id,uint256 startTime,uint256 durations,string userWatermarking,uint256 amout, uint64 buyerId,uint level) payable public{
        CopyrightManagement storage m = manages[id];
        address seller = m.owner;
        require(msg.value >= amout);
        require(m.copyrightStatus == CopyrightStatus.onSellPermission);
        m.users[msg.sender] = CopyrightUser({startTime:startTime,durations:durations,userWatermarking:userWatermarking});
        uint256 len = (m.addressPool).length;
        m.addressPool.push(msg.sender);
        if(m.addressPool[len] == msg.sender ){
            m.tree.insert(buyerId, seller,msg.sender, level);
            seller.transfer(amout);
            // function insert(Tree storage tree, uint64 id, address owner_1, address owner_2, uint value)
            //TransferPermissionEvent(id, msg.sender,userWatermarking, durations, amout);
        }
        else{
            (msg.sender).transfer(msg.value);

        }
    }

    /*
     * transfer permission in permission tree
     *
    */
    function transferPermission_2(string id, uint256 durations, string userWatermarking, uint256 amout, address seller,  uint64 buyerId, uint level) payable public{
        CopyrightManagement storage m = manages[id];
        require(msg.value >= amout);
        require(m.copyrightStatus != CopyrightStatus.cancel);
        m.users[msg.sender] = CopyrightUser({startTime:now,durations:durations,userWatermarking:userWatermarking});
        uint256 len = (m.addressPool).length;
        m.addressPool.push(msg.sender);
        if(m.addressPool[len] == msg.sender){
            m.tree.insert(buyerId, seller, msg.sender, level);
            seller.transfer(amout);
            // function insert(Tree storage tree, uint64 id, address owner_1, address owner_2, uint value)
            //TransferPermissionEvent(id, msg.sender,userWatermarking, durations, amout);
        }
        else{
            (msg.sender).transfer(msg.value);
        }

    }

    /*
        update Value
    */
    function transferPermission_3(string id, address seller, uint256 amout, uint level) payable public{
        CopyrightManagement storage m = manages[id];
        require(msg.value >= amout);
        m.tree.updateValue(msg.sender, level);
        seller.transfer(amout);
    }

    /**
    * get a copyright from a copyright id
    * @param id identify the copyright
    * return a copyright:current copyright watermarking, registTime
   */
    function getCopyright(string id) public returns(address createrAddress,string wm,uint256 rt){
        CopyrightManagement storage m = manages[id];
        require(m.owner == msg.sender);
        Copyright storage cp = m.cr;
        createrAddress = m.creater;
        wm = cp.watermarking;
        rt = cp.registTime;
    }

    /**
     * get current copyright status
     * @param id identify the copyright
     * return copyright status
    */
    function getStatus(string id) public returns(CopyrightStatus cs){
        CopyrightManagement storage m = manages[id];
        require(m.owner == msg.sender);
        cs = m.copyrightStatus;
    }

    /**
     * get the number of register copyright
     * return the number of register copyright
    */
    function getNum() public returns(uint256 registerNum){
        registerNum = crPools.length;
    }

    /**
    * get id owner
    * return address
    */
    function getOwner(string id) public returns(address ownerAddress){
        CopyrightManagement storage m = manages[id];
        ownerAddress = m.owner;
    }

    function setOwner(string id, address ownerAddress) public{
        CopyrightManagement storage m = manages[id];
        m.owner = ownerAddress;
    }

    /**
     * get a copyright id
     * return a copyright id
    */
    function getId(uint256 index) public returns(string cpId){
        require(index < crPools.length);
        cpId = crPools[index];
    }

    /**
     * get the use number of the copyright
     * @param id identity copyright
     * return user number
    */
    function getUersNum(string id) public returns(uint256 size){
        CopyrightManagement storage m = manages[id];
        require(msg.sender == m.owner);
        size = (m.addressPool).length;
    }

    /**
     * get copyright user address from address pool
     * @param id identity copyright
     * @param index the index in addressPool
     * return user address
    */
    function getUserAddress(string id,uint256 index) public returns(address userAddress){
        CopyrightManagement storage m = manages[id];
        uint256 len = m.addressPool.length;
        require(index < len);
        userAddress = m.addressPool[index];
    }

    /**
     * get a user watermarking
     * @param id identity copyright
     * return watermarking
    */
    function getUserWatermarking(string id) public returns(string uw){
        CopyrightUser storage user = manages[id].users[msg.sender];
        uw = user.userWatermarking;
        GetEvent(id, uw);
    }

    function getNode(string id, uint64 treeId) public returns(uint64 parent,uint64[] childrens,address own, uint value){
        CopyrightManagement storage m = manages[id];
        require(msg.sender == m.owner);
        PermissionTree.Node memory node = m.tree.nodes[treeId];
        parent = node.parent;
        childrens = node.childrens;
        own = node.owner;
        value = node.value;
    }

    function getUseTime(string id) public returns(uint256 startTime, uint256 endTime){
        CopyrightUser memory user = manages[id].users[msg.sender];
        startTime = user.startTime;
        endTime =startTime + user.durations;
    }

    function delRight(string id, uint256 endTime, address userAddress) public{
        CopyrightManagement storage m = manages[id];
        CopyrightUser memory user = m.users[userAddress];
        if(endTime - user.startTime > user.durations){
            delete m.users[userAddress];
            uint256 size = m.addressPool.length;
            uint256 index;
            for(uint256 i = 0; i< size; i++){
                if(m.addressPool[i] == userAddress){
                    index = i;
                    break;
                }
            }
            for(uint256 j = index; j < size -1; j++){
                m.addressPool[j] = m.addressPool[j+1];
            }
            delete m.addressPool[size-1];
            m.addressPool.length --;

            uint64 treeId = m.tree.find(userAddress);
            m.tree.remove(treeId);
        }
    }

}


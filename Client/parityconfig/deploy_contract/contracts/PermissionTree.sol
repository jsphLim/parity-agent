pragma solidity ^0.4.16;


library PermissionTree{

    struct Node{
        uint64 parent;
        uint64[] childrens;
        address owner;
        //if value == 1, can be authorized down; if value = 0 ,can not be authorized down
        uint value ;
    }

    struct Tree{
        uint64 root;
        uint64[] list;
        mapping(uint64 => Node) nodes;
    }

    function search(uint64[] list, uint64 target) private returns(uint256 index){
        for(uint256 i = 0 ; i < list.length; i++){
            if(list[i] == target){
                index = i;
                return index;
                break;
            }
        }
    }


    function getNode(Tree storage tree, uint64 id) public constant returns(uint64 parent,uint64[] childrens,address owner, uint value){
        require(id != 0);
        parent = tree.nodes[id].parent;
        childrens = tree.nodes[id].childrens;
        owner = tree.nodes[id].owner;
        value = tree.nodes[id].value;
    }


    function find(Tree storage tree, address owner) public constant returns(uint64 parentId){
        uint64 id = tree.root;
        uint64[] storage temp;
        temp.push(id);
        while(temp.length != 0){
            id = temp[temp.length-1];
            if(owner == tree.nodes[id].owner){
                return id;
            }else{
                delete temp[temp.length-1];
                temp.length--;
                if(tree.nodes[id].childrens.length!=0){
                    for(uint256 i = 0; i < tree.nodes[id].childrens.length; i++){
                        temp.push(tree.nodes[id].childrens[i]);
                    }
                }
            }
        }
    }

    function placeAfter(Tree storage tree, uint64 parent, uint64 id, address owner, uint value) internal{
        Node memory node;
        node.owner = owner;
        node.parent = parent;
        node.value = value;
        if(parent != 0){
            tree.nodes[parent].childrens.push(id);
        }else{
            tree.root = id;
        }
        tree.nodes[id] = node;
    }

    function initTree(Tree storage tree,address owner) internal{
        tree.root = 0;
        tree.nodes[tree.root].parent = 0;
        tree.nodes[tree.root].owner = owner;
        tree.nodes[tree.root].value = 1;
    }

    function insert(Tree storage tree, uint64 id, address owner_1, address owner_2, uint value) internal{
        uint64 parent = find(tree, owner_1);
        require(tree.nodes[parent].value == 1);
        placeAfter(tree, parent, id, owner_2,value);
    }

    function remove(Tree storage tree, uint64 id) internal{
        if(id == 0){
            delete tree.nodes[id];
        }
        uint64 parent = tree.nodes[id].parent;
        uint64[] temp = tree.nodes[parent].childrens;
        uint256 index = search(temp,id);
        for(uint256 i = index; i < temp.length; i++){
            temp[i] = temp[i+1];
        }
        delete temp[temp.length-1];
        temp.length--;
        delete tree.nodes[id];
    }

    function updateValue(Tree storage tree, address owner, uint value) internal{
        uint64 id = find(tree, owner);
        tree.nodes[id].value = value;
    }

    function updateOwner(Tree storage tree, address owner) internal{
        tree.nodes[0].owner = owner;
    }
}


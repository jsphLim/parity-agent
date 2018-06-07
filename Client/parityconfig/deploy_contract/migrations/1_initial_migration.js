var Migrations = artifacts.require("./Migrations.sol");

var PermiessionTree = artifacts.require("./PermissionTree.sol");

var CopyrightManage = artifacts.require("./CopyrightManage.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(PermissionTree);
  deployer.link(PermissionTree, CopyrightManage);
  deployer.deploy(CopyrightManage);
};

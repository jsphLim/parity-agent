#!/bin/bash
## create account in parity

value=$(cd `dirname $0`;pwd)
genesis_path=${value}"/genesis.json"
data=${value}"./data/keys"
node=${value}"/node.pwds"

engine_signer=$(parity account new --chain ${genesis_path} --keys-path ${data} --password ${node})
#engine_signer="0xtestestete"
echo "text:$engine_signer"

tempstr="/\[mining\]/a\engine_signer=\"$engine_signer\""
## append the engine_signer string in node.toml
sed -i $tempstr ${node}
 ## append the validator string and  accounts in genesis.json

 ## to do

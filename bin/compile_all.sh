#!/bin/bash
USAGE="USAGE: compile_all.sh [network] \n \t---service_name: noly 'thorswap' for now\n \t---network: 'development' for ganache(local test env); 'rinkeby' for test net rinkeby; 'ropsten' for test net ropsten; 'main' for main-net"

if [ $# -ne 1 ] 
then
    echo -e $USAGE
    exit 1
fi

truffle compile --all --network $1
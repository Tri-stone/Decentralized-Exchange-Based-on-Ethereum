#!/bin/bash
USAGE="USAGE: test.sh [service_name] [network] \n \t---service_name: noly 'thorswap' for now\n \t---network: 'development' for ganache(local test env); 'rinkeby' for test net rinkeby; 'ropsten' for test net ropsten; 'main' for main-net"

if [ $# -ne 2 ] 
then
    echo -e $USAGE
    exit 1
fi

if [ $1 == "thorswap" ] 
then
    truffle test test/thorswap/* --network $2
else
    echo -e $USAGE
fi
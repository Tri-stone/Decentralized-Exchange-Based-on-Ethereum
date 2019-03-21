#!/bin/bash
bin=`dirname "${BASH_SOURCE-$0}"`
CURR_PATH=`cd "$bin"; pwd`
USAGE="USAGE: deployer.sh [action] [service_name] [network] \n \t---action: 'deploy' to deploy contracts for some service; 'test' to test the contracts; 'compile' to compile all contracts\n \t---service_name: only 'thorswap' for now\n \t---network: 'development' for ganache(local test env); 'rinkeby' for test net rinkeby; 'ropsten' for test net ropsten; 'main' for main-net"

if [ $# -ne 3 ] 
then
    echo -e $USAGE
    exit 1
fi

if [ $1 == "deploy" ] 
then
    $CURR_PATH/deploy.sh $2 $3
elif [ $1 == "test" ] 
then
    $CURR_PATH/test.sh $2 $3
elif [ $1 == "compile" ] 
then
    rm -rf $CURR_PATH/../build
    $CURR_PATH/compile_all.sh $3 
elif [ $1 == "help"] 
then
    echo -e $USAGE
else
    echo -e $USAGE
fi
#!/bin/bash
#
#
   #===================================================================================
   #
   #         FILE: orclDocker.sh
   #
   #        USAGE: select an option or do all
   #
   #  DESCRIPTION:
   #      OPTIONS:  
   # REQUIREMENTS: 
   #       AUTHOR: Matt D
   #      CREATED: 11.10.2021
   #      UPDATED: 11.10.2021
   #      VERSION: 1.0
   #
   #
   #
   #
   #
   #
   #===================================================================================


function start_up()
{
    clear screen
    echo "##########################################################"
    echo "# This will manage your Oracle Database Docker container #"
    echo "##########################################################"

    echo
    echo
    echo 

    echo "################################################"
    echo "#                                              #"
    echo "#    What would you like to do ?               #"
    echo "#                                              #"
    echo "#          1 ==   Start Oracle docker image    #"
    echo "#                                              #"
    echo "#          2 ==   Stop Oracle docker image     #"
    echo "#                                              #"
    echo "#          3 ==   Bash access                  #"
    echo "#                                              #"
    echo "#          4 ==   SQLPlus nolog connect        #"
    echo "#                                              #"
    echo "#          5 ==   SQLPlus SYSDBA               #"
    echo "#                                              #"
    echo "#          6 ==   SQLPlus user                 #"
    echo "#                                              #"
    echo "#          7 ==   Do NOTHING                   #"
    echo "#                                              #"
    echo "################################################"
    echo 
    echo "Please enter in your choice:> "
    read whatwhat

#   if [ $whatwhat -gt 9 ]
#       then
#       echo "Please enter a valid choice"
#       sleep 3
#       start_up
#   fi
    
}

function do_nothing()
{
    echo "################################################"
    echo "You don't want to do nothing...lazy..."
    echo "So...you want to quit...yes? "
    echo "Enter yes or no"
    echo "################################################"
    read doWhat
    if [[ $doWhat = yes ]]; then
        echo "Yes"
        echo "Bye! ¯\_(ツ)_/¯ " 
        exit 1
    else
        echo "No"
        start_up
    fi
    
}

function checkDocker()
{
    # open Docker, only if is not running...super hacky
    if (! docker stats --no-stream ); then
        open /Applications/Docker.app
    while (! docker stats --no-stream ); do
        echo "Waiting for Docker to launch..."
        sleep 1
    done
    fi
}

function checkOrclexists()
{
    checkDocker
    # get oracle image if present
    export uThere=$(docker images --no-trunc | grep oracle | awk '{print $3}' | cut -d : -f 2 )
    echo $uThere

    if [ -z "$uThere" ]; then
        echo "Oracle docker image not found."
    else
        echo "Oracle docker image present."
        echo "Would you like to start it?"
        echo "Enter yes or no:"
        read theChoice
        if [ $theChoice = yes ]; then
            echo "Yes"
        else
            echo "No"
            start_up
        fi

    fi
}

function startOracle()
{
    export orclImage=$(docker images --no-trunc | grep oracle | awk '{print $3}' | cut -d : -f 2 )
    echo $orclImage
    docker run -itd $orclImage
    export runningOrcl=$(docker ps --no-trunc --format '{"name":"{{.Names}}"}'    | cut -d : -f 2 | sed 's/"//g' | sed 's/}//g')
    echo "Oracle is running as: "$runningOrcl 

}

function old_startOracle()
{

    checkDocker

    #need to add logic to check if running and skip if true

    export runningOrcl=$(docker ps --no-trunc | grep -i oracle | awk '{print $1}')

    if [ -z "$runningOrcl" ]; then
        echo "Oracle not running."
        echo "Starting Oracle...please wait"
        docker run -d -it  store/oracle/database-enterprise:12.2.0.1
        docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}" 
        export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')
        echo "Oracle docker name: "$orclImage
    else
        export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')
        echo "Oracle is running as: "$orclImage 
    fi

    echo "This will take some time, please wait..."
    sleep 30

    start_up
}

function stopOracle()
{
    checkDocker
    export stopOrcl=$(docker ps --no-trunc | grep -i oracle | awk '{print $1}')
    echo $stopOrcl

    docker stop $stopOrcl

}

function bashAccess()
{
    checkDocker
    export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')
    docker exec -it $orclImage /bin/bash
}


function sqlPlusnolog()
{
    checkDocker
    export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')
    docker exec -it $orclImage bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
}

function sysDba()
{
    checkDocker
    export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')    
    docker exec -it $orclImage bash -c "source /home/oracle/.bashrc; sqlplus sys/Oradoc_db1@'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=127.0.0.1)(PORT=1521))
    (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=ORCLPDB1.localdomain)))' as sysdba"
}

function createMatt()
{
    checkDocker
    export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')
    docker exec -it $orclImage bash -c "source /home/oracle/.bashrc; sqlplus sys/Oradoc_db1@'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=127.0.0.1)(PORT=1521))
    (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=ORCLPDB1.localdomain)))' as sysdba <<EOF
    grant sysdba,dba to matt identified by matt;
    exit;
EOF"
}


function sqlPlususer()
{
    checkDocker
    export orclImage=$(docker ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"| grep -i oracle  | awk '{print $4}')
    createMatt
    docker exec -it $orclImage bash -c "source /home/oracle/.bashrc; sqlplus matt/matt@'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=127.0.0.1)(PORT=1521))
    (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=ORCLPDB1.localdomain)))'"
}




# Let's go to work
start_up
case $whatwhat in
    1) 
        startOracle
        ;;
    2) 
        stopOracle
        ;;
    3)
        bashAccess
        ;;   
    4)
        sqlPlusnolog
        ;;
    5) 
        sysDba
        ;;
    6)
        sqlPlususer
        ;;
    7)
        do_nothing
        ;;
esac



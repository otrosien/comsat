#!/bin/bash -f
file=".serverIP"
if [ ! -e "$file" ]
then
	echo no $file
	exit 1
fi
if [ $# -eq 0 ]
  then
    echo "usage: peer peersNumber"
fi

line=`tail -1 $file`
cat > .targetPeer.sh <<-EOF
	#!/bin/bash
	#nodeIDs=( 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 )
	#nodeIDs=( 1 2 3 4 5 6 7 8 9 10 1 2 3 4 5 6 7 8 9 10  )
	nodeIDs=( 1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3 )
	nodeID=\${nodeIDs[\`wget -q -O - http://169.254.169.254/latest/meta-data/ami-launch-index\`]}
	pubIP=\`wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname\`
	instId=\`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id\`
	#ifconfig eth0 mtu 4096
	#apt-get install unzip
	#su ubuntu -c "cd; wget https://github.com/puniverse/galaxy-integration/archive/training.zip; unzip training.zip; rm training.zip; rm -rf galaxy-example; mv galaxy-integration-training galaxy-example;"
	#su ubuntu -c "cd; wget https://github.com/puniverse/galaxy/archive/training.zip; unzip training.zip; rm training.zip; cd galaxy-training; ./gradlew jar &> ../galaxy.log; cp build/dist/galaxy-1.0-SNAPSHOT.jar ~/galaxy-example/baselib"
	#su ubuntu -c "cd; cd galaxy-training/src/main/java/co/paralleluniverse/galaxy/cluster; rm DistributedBranchHelper.java; wget https://raw.github.com/puniverse/galaxy/training/src/main/java/co/paralleluniverse/galaxy/cluster/DistributedBranchHelper.java"
	#su ubuntu -c "cd; cd galaxy-training/src/main/java/co/paralleluniverse/galaxy/core; rm AbstractCluster.java; wget https://raw.github.com/puniverse/galaxy/training/src/main/java/co/paralleluniverse/galaxy/core/AbstractCluster.java"
	#su ubuntu -c "cd; cd galaxy-training; ./gradlew jar &> ../galaxy.log; cp build/dist/galaxy-1.0-SNAPSHOT.jar ~/galaxy-example/baselib"
	su ubuntu -c "cd; echo \$instId \$pubIP \$nodeID > nodeData.txt"
	su ubuntu -c 'cd; echo $line >> galaxy-example/src/main/resources/config/server.properties'
	#su ubuntu -c 'cd; echo co.paralleluniverse.galaxy.core.Cache.level=FINE >> galaxy-example/src/main/resources/config/jul.properties'
	#su ubuntu -c 'cd; echo co.paralleluniverse.galaxy.netty.UDPComm.level=FINE >> galaxy-example/src/main/resources/config/jul.properties'
	#su ubuntu -c 'cd; echo co.paralleluniverse.galaxy.netty.MesssagePacket.level=FINE >> galaxy-example/src/main/resources/config/jul.properties'
	#su ubuntu -c 'cd; echo co.paralleluniverse.galaxy.cluster.DistributedBranchHelper.level=FINE >> galaxy-example/src/main/resources/config/jul.properties'
	#su ubuntu -c 'cd; echo co.paralleluniverse.galaxy.zookeeper.ZooKeeperDistributedTree.level=FINE >> galaxy-example/src/main/resources/config/jul.properties'
	#su ubuntu -c "cd; cd galaxy-example; sed 's/src\/config/src\/main\/resources\/config/g' build.gradle > temp; mv temp build.gradle"
	su ubuntu -c "cd; cd galaxy-example; ./gradlew peer -PnodeId=\$nodeID &> ../galaxy.log" &
EOF
chmod +x .targetPeer.sh
image=`cat .imageID`
instance=`ec2run $image -k ec2key2 -g quicklaunch-1 -t m1.medium -n $1 --user-data-file .targetPeer.sh | awk '/INS/{print $2}'`
echo instance is $instance
if [ -z "$instance" ]
then
	exit 1
fi
echo peer is going up

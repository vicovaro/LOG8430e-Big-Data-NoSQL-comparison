#!/bin/bash
ver=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ "$ver" -gt "30" ]; then
    echo "This script requires python 2"
    exit 1
fi

docker_compose="docker-compose"
if ! command -v $docker_compose&> /dev/null
then
    docker_compose="docker compose"
fi

docker_up=$($docker_compose -f mongo-docker-compose.yml up -d)

sleep 5

cd ../YCSB

for work_type in {1..10}
do
    mkdir -p ../mongo/"$work_type"
    echo -e "\n------------------------ Benchmark with workload $work_type for 3 times ------------------------\n"
    ./bin/ycsb load mongodb -s -P workloads/workload"$work_type" -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > ../mongo/"$work_type"/outputworkload.txt
    for i in {1..3}
    do
        echo -e "\n--------------------------- benchmarking $i time ---------------------------\n"
        ./bin/ycsb run mongodb -s -P workloads/workload"$work_type" -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > ../mongo/"$work_type"/outputRun"$i".txt
        sleep 3
    done
done

cd ../mongo
echo -e "\ntearing down mongo\n"
sleep 3
docker_stop=$($docker_compose -f mongo-docker-compose.yml down)


echo -e "\nAnalyzing the result \n"
python average.py


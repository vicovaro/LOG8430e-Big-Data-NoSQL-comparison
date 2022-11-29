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

docker_up=$($docker_compose -f docker-compose-cassandra-cluster.yml up -d)

sleep 5

echo -e "\n----------------------Create a table for use with YCSB-----------------------\n"
docker cp init.cql cassandra-db-node-1:/init.cql
docker exec -it cassandra-db-node-1 sh -c "cqlsh -f init.cql"
# create_table=$(docker exec -it cassandra-db-node-1 sh)

sleep 5

cd ../YCSB

for work_type in a b c d e f
do
    mkdir -p ../cassandra/"$work_type"
    echo -e "\n------------------------ Benchmark with workload $work_type for 3 times ------------------------\n"
    ./bin/ycsb load cassandra-cql -p hosts="127.0.0.1" -s -P workloads/workload"$work_type" > ../cassandra/"$work_type"/outputworkload.txt
    for i in {1..3}
    do
        echo -e "\n--------------------------- benchmarking $i time ---------------------------\n"
        ./bin/ycsb run cassandra-cql -p hosts="127.0.0.1" -s -P workloads/workload"$work_type" > ../cassandra/"$work_type"/outputRun"$i".txt
        sleep 3
    done
done

cd ../cassandra
echo -e "\ntearing down cassandra\n"
sleep 3
docker_stop=$($docker_compose -f docker-compose-cassandra-cluster.yml down)


echo -e "\nAnalyzing the result \n"
python average.py


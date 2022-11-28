#!/bin/bash
ver=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ "$ver" -gt "30" ]; then
    echo "This script requires python 2"
    exit 1
fi
docker_up=$(docker-compose -f redis-docker-compose.yml up -d)

sleep 5

cd ../YCSB
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > ../redis/outputLoad.txt

for i in {1..5}
do
    echo -e "\n--------------------------- benchmarking $i time ---------------------------\n"
    ./bin/ycsb run redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > ../redis/outputRun"$i".txt
done

cd ../redis
echo -e "\ntearing down redis\n"
docker_stop=$(docker-compose -f redis-docker-compose.yml down)


echo -e "\n analyzing the result \n"

throughput=0
read_latency=0
clean_latency=0
update_latency=0
total=0
for f in ./*Run[0-9].txt; do
    total=`expr $total + 1`
    echo $f
    cur_throughput=$(cat $f | grep -F Throughput | awk -F','  '{print $3}')
    throughput=$(python -c "print $throughput + $cur_throughput")

    cur_read_latency=$(cat $f | grep -F "[READ], Aver" | awk -F','  '{print $3}')
    read_latency=$(python -c "print $read_latency + $cur_read_latency")

    cur_clean_latency=$(cat $f | grep -F '[CLEANUP], AverageL' | awk -F','  '{print $3}')
    clean_latency=$(python -c "print $clean_latency + $cur_clean_latency")

    cur_update_latency=$(cat $f | grep -F '[UPDATE], Average' | awk -F','  '{print $3}')
    update_latency=$(python -c "print $update_latency + $cur_update_latency")

done
average_throughput=$(python -c "print $throughput/$total")
average_read_latency=$(python -c "print $read_latency/$total")
average_clean_latency=$(python -c "print $clean_latency/$total")
average_update_latency=$(python -c "print $update_latency/$total")

echo "Redis benchmark result:"
echo "Average ThroughPut(ops/sec) = $average_throughput"
echo "Average Read Latency(us) = $average_read_latency "
echo "Average Clean Latency(us) = $average_clean_latency"
echo "Average Update Latency(us) = $average_update_latency"




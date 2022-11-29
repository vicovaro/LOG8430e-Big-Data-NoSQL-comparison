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

docker_up=$($docker_compose -f redis-docker-compose.yml up -d)

sleep 5

cd ../YCSB

for work_type in a b c d e f
do
    mkdir -p ../redis/"$work_type"
    echo -e "\n------------------------ Benchmark with workload $work_type for 3 times ------------------------\n"
    ./bin/ycsb load redis -s -P workloads/workload"$work_type" -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > ../redis/"$work_type"/outputworkload.txt
    for i in {1..3}
    do
        echo -e "\n--------------------------- benchmarking $i time ---------------------------\n"
        ./bin/ycsb run redis -s -P workloads/workload"$work_type" -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > ../redis/"$work_type"/outputRun"$i".txt
        sleep 3
    done
done

cd ../redis
echo -e "\ntearing down redis\n"
sleep 3
docker_stop=$($docker_compose -f redis-docker-compose.yml down)


echo -e "\nAnalyzing the result \n"
python average.py


# for work_type in a b c d e f
# do
#     throughput=0
#     read_latency=0
#     clean_latency=0
#     update_latency=0
#     total=0
#     for f in ./"$work_type"/*Run[0-9].txt; do
#         total=`expr $total + 1`
#         echo $f
#         cur_throughput=$(cat $f | grep -F Throughput | awk -F','  '{print $3}')
#         throughput=$(python -c "print $throughput + $cur_throughput")

#         cur_read_latency=$(cat $f | grep -F "[READ], Aver" | awk -F','  '{print $3}')
#         read_latency=$(python -c "print $read_latency + $cur_read_latency")

#         cur_clean_latency=$(cat $f | grep -F '[CLEANUP], AverageL' | awk -F','  '{print $3}')
#         clean_latency=$(python -c "print $clean_latency + $cur_clean_latency")

#         cur_update_latency=$(cat $f | grep -F '[UPDATE], Average' | awk -F','  '{print $3}')
#         update_latency=$(python -c "print $update_latency + $cur_update_latency")

#     done
#     average_throughput=$(python -c "print $throughput/$total")
#     average_read_latency=$(python -c "print $read_latency/$total")
#     average_clean_latency=$(python -c "print $clean_latency/$total")
#     average_update_latency=$(python -c "print $update_latency/$total")

#     echo "" > ./"$work_type"/result.txt
#     echo "Redis benchmark result:" >> ./"$work_type"/result.txt
#     echo "Average ThroughPut(ops/sec) = $average_throughput" >> ./"$work_type"/result.txt
#     echo "Average Read Latency(us) = $average_read_latency " >> ./"$work_type"/result.txt
#     echo "Average Clean Latency(us) = $average_clean_latency" >> ./"$work_type"/result.txt
#     echo "Average Update Latency(us) = $average_update_latency" >> ./"$work_type"/result.txt
# done



# How to get started

TP3 assignment on NoSQL databases comparison.

## Machine specification for benchmarking

Ubuntu 22.04 64 bits
AMD Ryzen 7 2700X Eight-Core Processor
16gb of rams

## Requirements

- You need to install docker engine with Docker Compose before running the scripts.
- Java 11 JDK is required (we recommend Temurin JDK 11).
- The tool YCSB is included and it uses the latest master branch. We did not use the 0.17 version. The necessary code is already compiled using Maven.

## The three benchmarked NoSQL databases, booted using Docker-Compose

Each database will be contained in a cluster.

### Redis

Redis for key-value pair-based databases
https://github.com/bitnami/bitnami-docker-redis-cluster/blob/master/docker-compose.yml

```
sudo docker compose -f redis-docker-compose.yml up
```

This will create two secondary or replicate nodes with a third primary node acting as chief named redis-node-5.
The two secondary nodes all are replicas of the third node redis-node-5. The following link is the instruction to test the Redis cluster.
https://github.com/brianfrankcooper/YCSB/tree/master/redis

```
./YCSB/bin/ycsb.sh load redis -s -P "./YCSB/workloads/workloada" -p "redis.cluster=true" -p "redis.host=172.17.0.1" -p "redis.port=6379" > outputLoadRedis.txt
```

### Cassandra

Cassandra for column-based databases

### MongoDB

MongoDB for document-oriented databases

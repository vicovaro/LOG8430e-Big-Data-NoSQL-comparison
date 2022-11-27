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
cd redis
sudo docker compose -f redis-docker-compose.yml up
```

This will create two secondary or replicate nodes with a third primary node acting as chief named redis-node-5.
The two secondary nodes all are replicas of the third node redis-node-5. The following link is the instruction to test the Redis cluster.
https://github.com/brianfrankcooper/YCSB/tree/master/redis


YCSB Benchmark
```
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > outputLoadRedis.txt
./bin/ycsb run redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" -p "redis.cluster=true" > outputRunRedis.txt
```

### Cassandra

Cassandra for column-based databases
```
cd cassandra
sudo docker-compose -f docker-compose-cassandra-cluster.yml up
```

Create a table for use with YCSB
```
sudo docker exec -it cassandra-db-node-1 sh
cqlsh
cqlsh> create keyspace ycsb
    WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 3 };
cqlsh> USE ycsb;
cqlsh> create table usertable (
    y_id varchar primary key,
    field0 varchar,
    field1 varchar,
    field2 varchar,
    field3 varchar,
    field4 varchar,
    field5 varchar,
    field6 varchar,
    field7 varchar,
    field8 varchar,
    field9 varchar);
```

YCSB benchmark
```
./bin/ycsb load cassandra-cql -p hosts="127.0.0.1" -s -P workloads/workloada > outputLoadCassandra.txt
./bin/ycsb run cassandra-cql -p hosts="127.0.0.1" -s -P workloads/workloada > outputRunCassandra.txt
```



### MongoDB

MongoDB for document-oriented databases
```
cd mongo
sudo docker-compose -f mongo-docker-compose.yml up
```

add the following content in /etc/hosts if you just created a new VM

```
127.0.0.1       mongo1
127.0.0.1       mongo2
127.0.0.1       mongo3
```

YCSB benchmark
```
./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > outputLoadMongo.txt
./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set > outputRunMongo.txt
```


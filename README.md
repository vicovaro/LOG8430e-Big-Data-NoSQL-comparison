# How to get started

TP3 assignment on NoSQL databases comparison.

## Machine specification for benchmarking

Ubuntu 22.04 64 bits
AMD Ryzen 7 2700X Eight-Core Processor
16gb of rams

## Requirements

You need to install docker engine with Docker Compose before running the scripts.

## The three benchmarked NoSL databases, booted using Docker-Compose

Redis for key-value pair-based databases
https://github.com/bitnami/bitnami-docker-redis-cluster/blob/master/docker-compose.yml

```
docker compose -f redis-docker-compose.yml up
```

Cassandra for column-based databases
MongoDB for document-oriented databases

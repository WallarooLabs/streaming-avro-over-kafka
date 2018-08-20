.PHONY: test \
	check-for-wallaroo \
	start-kafka stop-kafka setup-topics reset\
	start-app \
	start-generator \
	tail-output \

K_BIN = ./kafka/bin/
IN_TOPIC = sensor-readings
OUT_TOPIC = sensor-aggregates

test:
	python -m unittest codec.Tests

check-for-wallaroo:
	@(which machida >/dev/null 2>&1) || \
	(echo "machida executable not found" ; exit 1)
	@python -c 'import wallaroo' 2>/dev/null || \
	(echo "wallaroo.py not in python path"; exit 1)

start-app: check-for-wallaroo
	-rm /tmp/app-initializer.*
	machida --application-module app \
	  --kafka_source_topic $(IN_TOPIC) \
	  --kafka_source_brokers 127.0.0.1:9092 \
	  --kafka_sink_topic $(OUT_TOPIC) \
	  --kafka_sink_brokers 127.0.0.1:9092 \
	  --kafka_sink_max_message_size 100000 \
	  --kafka_sink_max_produce_buffer_ms 100 \
	  --metrics 127.0.0.1:5001 \
	  --control 127.0.0.1:12500 \
	  --data 127.0.0.1:12501 \
	  --external 127.0.0.1:5050 \
	  --cluster-initializer --ponythreads=1 \
	  --ponynoblock

start-generator:
	./generator.py

tail-output:
	$(K_BIN)/kafka-console-consumer.sh \
	  --bootstrap-server localhost:9092 \
	  --topic $(OUT_TOPIC)

$(K_BIN): kafka log

log:
	mkdir -p log

kafka: tmp/kafka_2.11-2.0.0.tgz
	(cd tmp && tar xzf $(notdir $<))
	ln -s $(basename $<) $@

tmp/kafka_2.11-2.0.0.tgz:
	mkdir -p tmp
	(cd tmp &&\
	curl -sO 'http://apache.mirror.gtcomm.net/kafka/2.0.0/kafka_2.11-2.0.0.tgz')

start-kafka: $(K_BIN)
	$(K_BIN)/zookeeper-server-start.sh \
	  ./kafka/config/zookeeper.properties > ./log/zk.log 2>&1 &
	./wait_for_it localhost:2181
	$(K_BIN)/kafka-server-start.sh \
	  ./kafka/config/server.properties > ./log/kafka.log 2>&1 &
	./wait_for_it  localhost:9092

stop-kafka: $(K_BIN)
	$(K_BIN)/zookeeper-server-stop.sh
	$(K_BIN)/kafka-server-stop.sh

reset:
	-ps aux | grep [k]afka | awk '{print $$2}' | xargs -L1 kill -9
	-ps aux | grep [z]ook | awk '{print $$2}' | xargs -L1 kill -9
	sleep 1
	rm -rf ./kafka/logs/*
	rm -rf /tmp/kafka-logs
	rm -rf /tmp/zookeeper

setup-topics: $(K_BIN)
	-$(K_BIN)/kafka-topics.sh --create --zookeeper localhost:2181 \
	  --partitions 1 --replication-factor 1\
	  --config delete.retention.ms=1 \
	  --topic $(IN_TOPIC)
	-$(K_BIN)/kafka-topics.sh --create --zookeeper localhost:2181 \
	  --config delete.retention.ms=1 \
	  --partitions 1 --replication-factor 1\
	  --topic $(OUT_TOPIC)

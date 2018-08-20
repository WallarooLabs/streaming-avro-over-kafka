# Avro POC

## HOWTO run the demo

0. **make sure you have machida in your $PATH, wallaroo.py in
   $PYTHON_PATH, and a virtualenv activated,
   with ./requirements.txt installed**

1. `make start-kafka setup-topics` (TERMINAL 1)
   Downloads kafka if not downloaded already,
   starts single broker, creates input and output topics.

2. `make start-app` (TERMINAL 1)
   Start Wallaroo app [app.py](app.py), which connects to the
   Kafka broker.

3. `make tail-output` (TERMINAL 2)
   Opens up a Kafka console consumer and displays the output
   published by the Wallaroo app.

4. `make start-generator` (TERMINAL 3)
   Starts up Python script [generate.py](generate.py) which
   continuously sends random "sensor readings" to the input topic.


`make test` - runs unit tests for avro (de)serializer  
`make reset` - destroy kafka/zk state. WARNING! here be `rm -rf`s and `pkill`s


## TODO:

 - [x] Serialize and deserialize Avro from strings, not files
 - [x] Timebox: stand up Kafka broker to avoid TCP framing
 - [x] Connect `generator.py` to Source (kafka|tcp)
 - [x] Decode info
 - [ ] Perform a state computation (aggregate readings by geohash?)
 - [x] Send results to Kafka
 - [ ] Short writeup of what's what

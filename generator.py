#!/usr/bin/env python2
from faker import Faker
from kafka import KafkaProducer
from codec import serialize

KAFKA='localhost:9092'
TOPIC = 'sensor-readings'

def main():
    source = KafkaProducer(bootstrap_servers=KAFKA)
    gen = Faker()
    loop(source, gen)

def loop(source, gen):
    while True:
        r = random_sensor_reading(gen)
        source.send(TOPIC, serialize(r))

def random_sensor_reading(gen=Faker()):
    return {"id": gen.uuid4(),
            "lat": float(gen.latitude()),
            "lon": float(gen.longitude()),
            "val": gen.pyint()}

if __name__ == '__main__':
    main()

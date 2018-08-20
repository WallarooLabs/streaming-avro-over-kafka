from codec import deserialize
from collections import namedtuple
import wallaroo

def application_setup(args):
    ab = wallaroo.ApplicationBuilder("Avro example app")
    ab.new_pipeline("avro example pipeline",
                    wallaroo.DefaultKafkaSourceCLIParser(decoder))
    ab.to(pass_through)
    ab.to_sink(wallaroo.DefaultKafkaSinkCLIParser(encoder))
    return ab.build()

@wallaroo.computation(name="pass through everything")
def pass_through(event):
    return event

@wallaroo.decoder(header_length=4, length_fmt=">I")
def decoder(data):
    return deserialize(data)

@wallaroo.encoder
def encoder(data):
    val = str(data[u'val'])
    return (val, None, None)

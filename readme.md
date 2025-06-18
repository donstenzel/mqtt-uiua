# Paho MQTT Uiua Bindings

Simple bindings to [Paho MQTT C](https://github.com/eclipse-paho/paho.mqtt.c)
for [Uiua](https://uiua.org).

[wrap.c](src/wrap.c) just wraps Paho to make some things
compatible and has a single static client.

To build it, just make sure to have Paho installed on your system.
If the necessary headers and libs are in PATH it should work.
(I don't know much about C at all so take this with a grain of salt lol)


The [lib](lib.ua) provides creation, connection, subscription, respective
inverted functions and publishing functionality. Messages are received
through `Receive`, which returns a sentinel value when no message was available.
Currently only MQTT 3 is supported. Errors are printed in a human readable way.


The [example](example.ua) uses [Iris](https://github.com/marcos-cat/iris)
and [Rayguiua](https://github.com/donstenzel/rayguiua) to provide a small
graphical user interface to send and receive messages.
[Image of the example](image.png)

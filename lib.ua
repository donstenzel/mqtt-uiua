# Experimental!

# # === TODO ===
# - [x] Error code pretty printer
# - [x] under for create/destroy & connect/disconnect
# - [x] cleanup
# - [?] get rid of wrap.c / wrap.so
#   |=> not possible? no way to get the payload associated with a message
#       we can't get back the message because we have to pass in a
#       pointer to which its address is written. And we can't deref that
# - [/] remaining functions:
#   - [-] publishMessage: doesn't make sense at the moment
#                         because messages are kinda hard to get down
#   - [x] waitForCompletion
#   - [x] yield
#   - [x] getPendingDeliveryTokens
#   - [?] free, malloc
# - [ ] MQTT V5 support

String ← "const char*"

Lib ← &ffi ⊂□"bin/wrap.so"

┌─╴RC
  Success            ← 0
  Failure            ← ¯1
  Disconnected       ← ¯3
  MaxInflightReached ← ¯4
  BadUtf₈            ← ¯5
  InvalidNull        ← ¯6
  TopicTruncated     ← ¯7
  BadStructure       ← ¯8
  BadQOS             ← ¯9
  SSLNotSupported    ← ¯10
  BadMQTTVersion     ← ¯11
  BadProtocol        ← ¯14
  BadMQTTOption      ← ¯15
  WrongMQTTVersion   ← ¯16
  ZeroLenWillTopic   ← ¯17
└─╴

FmtError ← RC!⍣(
  "Success" °Success
| "Generic Error" °Failure
| "Client is disconnected" °Disconnected
| "Maximum number of messages that are simultaneously in-flight has been reached" °MaxInflightReached
| "An invalid UTF-8 string has been detected" °BadUtf₈
| "A NULL parameter was supplied when this is not valid" °InvalidNull
| "The topic string includes embedded \\0s! Not yet supported" °TopicTruncated
| "A parameter struct has an icorrect eyecatcher and/or version number" °BadStructure
| "An invalid QoS value was supplied" °BadQOS
| "Unrecognized MQTT version" °BadMQTTVersion
| "Protocol prefix is invalid" °BadProtocol
| "An option was given that is not applicable to the MQTT version" °BadMQTTOption
| "Call is not applicable to the requested version of MQTT" °WrongMQTTVersion
| "Will topic has length 0 while trying to connect" °ZeroLenWillTopic
)

Handle ← ⍤⊃FmtError=₀

# ? serverURI clientID
Create  ← Handle Lib {"int" "create" String String} □₂
Destroy ← ◌ Lib {"void" "destroy"} {}

# ? serverURI clientID
New ← ⌅(Create|Destroy)

# ? username password
Connect    ← Handle Lib {"int" "connect" String String} □₂
Disconnect ← Handle Lib {"int" "disconnect"} {}

# status ?
Connected ← (Lib {"int" "is_connected"} {})

# ? username password
Connection ← ⌅(Connect|Disconnect)

# ? topic
Unsubscribe ← Handle Lib {"int" "unsubscribe" String} □₁

Sub ↚ Handle Lib {"int" "subscribe" String "int"} □₂

# ? topic qos
Subscribe ← ⌅(Sub|⟜Sub|Unsubscribe)

# token ? topic payload qos retained
Publish ← Handle °□₂ Lib {"int" "publish" String "int" "const unsigned char*" "int" "int" "int*"} ⊓{∘|⧻.utf₈|∘|∘|0}

# ? token timeout
Wait ← Handle Lib {"int" "wait" "int" "unsigned long"} □₂

# call this periodically to process message retries and keepalive pings
Yield ← (◌ Lib {"void" "yield"} {})

# pending ?
Pending ← (&memcpy"int" Handle °□₃ Lib {"int" "get_pending" "int*" "int*"} {[] 0})

# actual ? message*
Payload ↚ °utf₈ ⊃⋅&memfree &memcpy "unsigned char" ⍜⊙□₂Lib {"unsigned char*" "get_payload" "const void*" "int*"} ⊙0
# ? message*
FreeMsg ↚ ◌ Lib {"void" "free_msg" "const void*"} □₁

# returns `∞ ∞` if no message was received in the given timeout window
# topic message ? timeout
Receive ← (
  ⍜⊙□₄Lib {"int" "receive" "char**" "int*" "void**" "int"} "" 0 {}
  ⨬∩⋅⋅∞⊓Handle⊙⋅⊃FreeMsg Payload ◡⋅(¬≍NULL)
)

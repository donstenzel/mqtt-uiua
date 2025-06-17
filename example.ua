# Experimental!
MQTT ~ "lib.ua"
I ~ "git: https://github.com/marcos-cat/iris"
Gui ~ "git: https://github.com/donstenzel/rayguiua"

~ {
  SubTopic ← "Subscribe..."
  PubTopic ← "Publish..."
  Message ← "Message..."
  Received ← {}
  LVData ← [0 0]
  Edit ← [0 0 0]
}

Send  ← ◌ MQTT~Publish⊸⊓⊃PubTopic Message(1 0)
Subs  ← MQTT~Subscribe⊸⊓SubTopic 1
Unsub ← MQTT~Unsubscribe⊸SubTopic

I~Open 600_500 "MQTT Explorer"
°I~Screen~FPS 24

New

MQTT!⍜New⍜Connection⍜Subscribe I~Loop!Gui!(
  ◌ Label [10 10 100 20] "Publish on:"
  Box~Text [10 30 580 20]⊸⊃(PubTopic|1e2|⊡₀Edit)
  ⍜⊙PubTopic⊙◌ ⍥⊙⍜Edit⋅1_0_0

  ◌ Label [10 60 100 20] "Message:"
  Box~Text [10 80 580 20]⊸⊃(Message|1e3|⊡₁Edit)
  ⍜⊙Message ⊙◌ ⍥⊙⍜Edit⋅0_1_0

  ◌ Label [10 110 100 20] "Topic to (un)sub:"
  Box~Text [10 130 580 20]⊸⊃(SubTopic|1e2|⊡₂Edit)
  ⍜⊙SubTopic ⊙◌ ⍥⊙⍜Edit⋅0_0_1

  ⍜LVData⍜°⊟ (◌ ListView [10 180 580 310] ⤚⋅⤚⋅/$"_;_")⟜Received

  ⍥Send Button [540 105 50 20] "Send!"
  ⍥Subs Button [10 155 50 20] "Sub"
  ⍥Unsub Button [70 155 50 20] "Unsub"

  ⨬⋅◌(⍜⊙Received⊂□$"_: _")¬⊸≍∞ Receive 0
) "localhost" "UIUA-MQTT" "user" "password" "receive" 1

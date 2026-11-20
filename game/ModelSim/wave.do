# Wave display setup, separate from compilation like the previous labs.
view wave
add wave -divider {Audio controls}
add wave -radix unsigned sim:/tb_audio/note_id
add wave sim:/tb_audio/note_on sim:/tb_audio/reset
add wave -divider {Square wave: +10 million / -10 million; zero when released}
add wave -radix decimal -format analog-step -height 140 -min -11000000 -max 11000000 sim:/tb_audio/sample
add wave sim:/tb_audio/high
configure wave -timelineunits ms

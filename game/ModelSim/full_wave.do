# Presentation view: actual decoded keys, note LEDs, player and audio.
view wave
delete wave *

# Decode the existing LED bus for readable key names, without changing the RTL.
radix define key_names {
    10'h001 "A" -color cyan,
    10'h002 "S" -color cyan,
    10'h004 "D" -color cyan,
    10'h008 "F" -color cyan,
    10'h201 "H" -color yellow,
    10'h202 "J" -color yellow,
    10'h204 "K" -color yellow,
    10'h208 "L" -color yellow,
    10'h000 "released" -color gray,
    10'h200 "released" -color gray,
    -default hexadecimal
}
radix define player_names {
    1'b0 "P1 (ASDF)",
    1'b1 "P2 (HJKL)"
}

add wave -divider {Keyboard: A S D F -> H J K L}
add wave -label key -radix key_names sim:/tb_full_system/LEDR
add wave -label note -radix binary {sim:/tb_full_system/LEDR[3:0]}
add wave -label player -radix player_names {sim:/tb_full_system/LEDR[9]}
add wave -label held sim:/tb_full_system/dut/note_on

add wave -divider {Audio}
add wave -label audio_sample -radix decimal -format analog-step -height 140 -min -11000000 -max 11000000 sim:/tb_full_system/dut/sample
add wave -label audio_ready sim:/tb_full_system/dut/audio_out_allowed
add wave -label audio_serial sim:/tb_full_system/AUD_DACDAT
add wave -divider {VGA pixel colour: 9-bit RRR GGG BBB}
add wave -label color -radix hexadecimal sim:/tb_full_system/dut/kavin/color
add wave -divider {Test result: errors should finish at zero}
add wave -label errors -radix unsigned sim:/tb_full_system/errors
configure wave -timelineunits ms
configure wave -signalnamewidth 1

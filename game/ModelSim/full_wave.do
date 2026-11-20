view wave
add wave -divider {Keyboard -> note and player}
add wave sim:/tb_full_system/PS2_CLK sim:/tb_full_system/PS2_DAT
add wave -radix hexadecimal sim:/tb_full_system/dut/ps2_byte
add wave sim:/tb_full_system/dut/ps2_byte_en
add wave -radix unsigned sim:/tb_full_system/dut/note_id
add wave sim:/tb_full_system/dut/player sim:/tb_full_system/dut/note_on
add wave -radix binary sim:/tb_full_system/LEDR
add wave -divider {Audio: samples -> real FIFO and serializer -> DAC pin}
add wave -radix decimal -format analog-step -height 110 -min -11000000 -max 11000000 sim:/tb_full_system/dut/sample
add wave sim:/tb_full_system/dut/audio_out_allowed sim:/tb_full_system/AUD_DACDAT
add wave -divider {VGA painter -> real framebuffer and monitor timing}
add wave -radix unsigned sim:/tb_full_system/dut/kavin/x sim:/tb_full_system/dut/kavin/y
add wave -radix hexadecimal sim:/tb_full_system/dut/kavin/color
add wave sim:/tb_full_system/dut/kavin/write sim:/tb_full_system/VGA_HS sim:/tb_full_system/VGA_VS
add wave -radix hexadecimal sim:/tb_full_system/VGA_R sim:/tb_full_system/VGA_G sim:/tb_full_system/VGA_B
add wave -divider {Checks: 0 means every check passed}
add wave -radix unsigned sim:/tb_full_system/errors
configure wave -timelineunits ms
configure wave -signalnamewidth 1

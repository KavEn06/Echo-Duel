IVERILOG ?= iverilog
VVP ?= vvp
FLAGS := -g2001 -Wall -Wno-timescale
BUILD := .build
.PHONY: all test audio integration ps2 compile
all: test compile
test: audio integration ps2
$(BUILD):
	mkdir -p $@

audio: | $(BUILD)
	$(IVERILOG) $(FLAGS) -s tb_audio -o $(BUILD)/tb_audio '../Milestone 1/Saajan/tone_gen.v' tests/tb_audio.v
	$(VVP) -n $(BUILD)/tb_audio > $(BUILD)/tb_audio.log
	cat $(BUILD)/tb_audio.log
	! grep -q FAIL $(BUILD)/tb_audio.log

integration: | $(BUILD)
	$(IVERILOG) $(FLAGS) -s tb_echo_duel_m1 -o $(BUILD)/tb_echo_duel_m1 echo_duel_m1.v '../Milestone 1/Saajan/note_decoder.v' '../Milestone 1/Saajan/tone_gen.v' '../Milestone 1/Kavin/game_fsm.v' '../Milestone 1/Kavin/frame_writer.v' '../Milestone 1/Kavin/kavin_milestone1.v' '../Milestone 1/Kavin/vga_adapter/vga_adapter.v' '../Milestone 1/Kavin/vga_adapter/vga_address_translator.v' '../Milestone 1/Kavin/vga_adapter/vga_controller.v' '../Milestone 1/Kavin/tests/sim/vga_pll.v' '../Milestone 1/Kavin/tests/sim/altsyncram.v' tests/sim/course_stubs.v tests/tb_echo_duel_m1.v
	$(VVP) -n $(BUILD)/tb_echo_duel_m1 > $(BUILD)/tb_echo_duel_m1.log
	cat $(BUILD)/tb_echo_duel_m1.log
	! grep -q FAIL $(BUILD)/tb_echo_duel_m1.log

ps2: | $(BUILD)
	$(IVERILOG) $(FLAGS) -s tb_ps2_path -o $(BUILD)/tb_ps2_path course_ps2/Altera_UP_PS2_Command_Out.v course_ps2/Altera_UP_PS2_Data_In.v course_ps2/PS2_Controller.v '../Milestone 1/Saajan/note_decoder.v' '../Milestone 1/Saajan/tone_gen.v' tests/tb_ps2_path.v
	$(VVP) -n $(BUILD)/tb_ps2_path > $(BUILD)/tb_ps2_path.log
	cat $(BUILD)/tb_ps2_path.log
	! grep -q FAIL $(BUILD)/tb_ps2_path.log

compile: | $(BUILD)
	$(IVERILOG) $(FLAGS) -s echo_duel_m1 -o $(BUILD)/echo_duel_m1 echo_duel_m1.v '../Milestone 1/Saajan/note_decoder.v' '../Milestone 1/Saajan/tone_gen.v' '../Milestone 1/Kavin/game_fsm.v' '../Milestone 1/Kavin/frame_writer.v' '../Milestone 1/Kavin/kavin_milestone1.v' '../Milestone 1/Kavin/vga_adapter/vga_adapter.v' '../Milestone 1/Kavin/vga_adapter/vga_address_translator.v' '../Milestone 1/Kavin/vga_adapter/vga_controller.v' '../Milestone 1/Kavin/tests/sim/vga_pll.v' '../Milestone 1/Kavin/tests/sim/altsyncram.v' tests/sim/course_stubs.v

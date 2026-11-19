IVERILOG ?= iverilog
VVP ?= vvp
BUILD := .build
OWN_RTL := game_fsm.v frame_writer.v kavin_milestone1.v kavin_board_demo.v
COURSE_RTL := vga_adapter/vga_adapter.v vga_adapter/vga_address_translator.v vga_adapter/vga_controller.v
# The real course vga_pll.v needs Intel libraries. Only local Icarus uses these models.
SIM_IP := tests/sim/vga_pll.v tests/sim/altsyncram.v
RTL := $(OWN_RTL) $(COURSE_RTL) $(SIM_IP)
TESTS := game_fsm frame_writer kavin_milestone1
# Course sources have no timescale; avoid changing the supplied files to add one.
FLAGS := -g2001 -Wall -Wno-timescale

.PHONY: all test compile clean
all: test compile

test: $(TESTS:%=$(BUILD)/tb_%.ok)

$(BUILD):
	mkdir -p $@

$(BUILD)/tb_%.ok: tests/tb_%.v $(RTL) | $(BUILD)
	$(IVERILOG) $(FLAGS) -s tb_$* -o $(BUILD)/tb_$* $(RTL) $<
	$(VVP) $(BUILD)/tb_$*
	touch $@

compile: | $(BUILD)
	$(IVERILOG) $(FLAGS) -s kavin_milestone1 -o $(BUILD)/kavin_milestone1 $(RTL)
	$(IVERILOG) $(FLAGS) -s kavin_board_demo -o $(BUILD)/kavin_board_demo $(RTL)

clean:
	rm -f $(BUILD)/tb_* $(BUILD)/kavin_milestone1 $(BUILD)/kavin_board_demo

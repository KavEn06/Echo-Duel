IVERILOG ?= iverilog
VVP ?= vvp
BUILD := .build
RTL := game_fsm.v vga_timing.v note_display.v kavin_milestone1.v
TESTS := game_fsm vga_timing note_display kavin_milestone1

.PHONY: all test compile clean
all: test compile

test: $(TESTS:%=$(BUILD)/tb_%.ok)

$(BUILD):
	mkdir -p $@

$(BUILD)/tb_%.ok: tests/tb_%.v $(RTL) | $(BUILD)
	$(IVERILOG) -g2001 -Wall -s tb_$* -o $(BUILD)/tb_$* $(RTL) $<
	$(VVP) $(BUILD)/tb_$*
	touch $@

compile: | $(BUILD)
	$(IVERILOG) -g2001 -Wall -s kavin_milestone1 -o $(BUILD)/kavin_milestone1 $(RTL)

clean:
	rm -f $(BUILD)/tb_* $(BUILD)/kavin_milestone1

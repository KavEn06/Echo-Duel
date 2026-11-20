IVERILOG ?= iverilog
VVP ?= vvp
BUILD := .build
RTL := note_decoder.v tone_gen.v
TESTS := note_decoder tone_gen
FLAGS := -g2001 -Wall -Wno-timescale

.PHONY: all test clean
all: test

test: $(TESTS:%=$(BUILD)/tb_%.ok)

$(BUILD):
	mkdir -p $@

$(BUILD)/tb_%.ok: tests/tb_%.v $(RTL) | $(BUILD)
	$(IVERILOG) $(FLAGS) -s tb_$* -o $(BUILD)/tb_$* $(RTL) $<
	$(VVP) -n $(BUILD)/tb_$* | tee $(BUILD)/tb_$*.log
	! grep -q FAIL $(BUILD)/tb_$*.log
	touch $@

clean:
	rm -rf $(BUILD)

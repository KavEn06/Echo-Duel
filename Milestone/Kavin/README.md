# Kavin - Milestone 1 starter

Basic VGA note display and initial game-state controller for Echo Duel, now
using the **official ECE241 VGA adapter downloaded from Quercus**:
https://q.utoronto.ca/courses/468637/pages/vga-adapter

## Architecture

`game_fsm` supplies the phase. `frame_writer` snapshots the phase and note,
then writes all 19,200 pixels of a 160x120 scene into the supplied VGA adapter.
The adapter owns video memory, VGA timing and the pixel clock. It expands
each stored pixel to a 4x4 block on a 640x480 monitor. Nine-bit color uses
three bits per RGB channel. A sweep takes 19,201 cycles, about 0.384 ms.
A full redraw erases the previous highlight; note changes apply at the next
sweep. This uses a single framebuffer, so it does not guarantee tear-free
updates relative to the monitor scan.

The initial custom `vga_timing.v` has been removed. The course adapter files
are unchanged; provenance and checksums are in [COURSE_SOURCES.md](COURSE_SOURCES.md).

| File | Responsibility |
| --- | --- |
| `game_fsm.v` | IDLE -> RECORD -> REPLAY -> MATCH -> RESULT phase control |
| `note_display.v` | Eight-key scene and phase colour band |
| `frame_writer.v` | Snapshot scene inputs and write pixels to course video memory |
| `kavin_milestone1.v` | Integration top including the official VGA adapter |
| `kavin_board_demo.v` | Standalone VGA bring-up using switches, before keyboard integration |
| `vga_adapter/` | Unmodified supplied VGA adapter, controller, translator, PLL and default MIF |
| `kavin.qpf`, `kavin.qsf`, `kavin.sdc` | Quartus board-demo project, extracted course pin assignments and initial clock constraints |
| `tests/` | Self-checking Icarus simulations; simulation-only Intel IP substitutes |

## Run locally

Requires Icarus Verilog and Make. From this directory:

```sh
make          # run four simulations and compile both tops
make -B test  # rerun all tests
make compile # compile both tops with functional simulation IP
```

Tests cover FSM transitions and empty-recording guard, all eight highlights,
complete framebuffer write coverage, coherent note changes, erasing a released
note, and integration through the real course adapter/controller over a complete
VGA frame (420,000 physical pixels). Build output stays in ignored `.build/`.

The adapter instantiates Intel `altsyncram` and a PLL. Icarus uses the explicitly
listed `tests/sim/` RAM and PLL models; it does **not** use the real Intel PLL.
The RAM model zero-fills to match our black background; it does not parse MIFs
or model read/write collisions. The PLL model is only a divide-by-two clock.
These tests do not verify Intel IP timing, synthesis or physical behavior.
The Makefile suppresses missing-timescale warnings from the unmodified course
sources. Other compiler warnings remain enabled.

## Board demo in Quartus / ECF

Open `kavin.qpf` from this directory. Its top is `kavin_board_demo`. It includes
the **real supplied `vga_pll.v`**, not `tests/sim/`. Quartus resolves Intel RAM
and PLL primitives using its built-in libraries. The project uses the supplied
DE1-SoC COLORS example's clock, VGA, reset and switch pin assignments.

1. Compile and review timing/resource reports, then program the DE1-SoC.
2. Press KEY[0] to reset (the button is active low).
3. Set SW[2:0] to select C, D, E, F, G, A, B, upper C (IDs 0..7).
4. Set SW[3] high to highlight the selected key green; low releases it.

The board demo stays in IDLE (blue band); it is a VGA bring-up test without
a keyboard or sound. The course's required milestone demonstration still needs
Saajan's playable keyboard/audio path and physical board verification.
The switches pass through two synchronizer stages. A multi-bit switch change
may transiently select an intermediate note, which is acceptable for this demo.

Clock constraints include CLOCK_50, derived PLL clocks and uncertainty.
Board I/O delays/CDC constraints and actual timing closure still require review
on ECF. No Quartus, ModelSim or hardware verification has been performed here.

## Integration interface for Saajan

Instantiate `kavin_milestone1` in the final board wrapper:

- `CLOCK_50`: 50 MHz. All control/note inputs must be synchronous to this clock.
- `reset`: synchronous active-high reset for project logic; invert internally
  for the course adapter's active-low `resetn`. Hold across a clock edge.
- `note_id[2:0]`: 0=C, 1=D, 2=E, 3=F, 4=G, 5=A, 6=B, 7=upper C.
  Proposed shared note mapping, not raw PS/2 scan codes.
- `note_active`: high while the selected note is sounding. Keep the note ID
  stable while active. Later multiplex replay notes into this same interface.
- `start`: one-clock pulse to begin recording from IDLE or RESULT.
- `finish_record`: one-clock pulse requesting replay (also usable for full memory).
- `sequence_nonempty`: true only after at least one note is stored; prevents
  replay of an empty sequence.
- `replay_done`, `match_done`: one-clock completion pulses from future modules.
- `game_state`: 0=IDLE, 1=RECORD, 2=REPLAY, 3=MATCH, 4=RESULT.
- `record_enable`, `replay_enable`, `match_enable`: outputs for phase-specific logic.

Until the game datapath exists, leave command/completion inputs low. Note
highlighting still works in IDLE. Synchronize and debounce physical controls
before generating command pulses. On entry into RECORD, future memory/score
modules must clear length, indices and score; the FSM does not store that data.

The top band is blue in IDLE, red in RECORD, yellow in REPLAY, green in MATCH,
and purple in RESULT. Text, score rendering, rhythm checking and animations are
later work. The full keyboard decoder, audio path, sequence storage, comparison
and score are not implemented in these milestone starter files.

## ModelSim waveform starter

`ModelSim/waveform.do` runs a separate waveform testbench with the actual
Intel libraries, following the course example. It does not use Icarus IP models.
Run it from the ModelSim folder with the Intel libraries mapped as on ECF.
The script has been prepared but not run here. Use the waveforms alongside the
board demo when preparing the milestone PDF; Icarus logs are not ModelSim evidence.

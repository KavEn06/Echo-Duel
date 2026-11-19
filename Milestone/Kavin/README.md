# Kavin - Milestone 1 starter

Basic VGA note display and initial game-state controller for Echo Duel.
This is Kavin's portion of the playable-keyboard milestone. It does not yet
implement keyboard decoding, audio, sequence memory, comparison or scoring.

## Files

| File | Responsibility |
| --- | --- |
| `game_fsm.v` | IDLE -> RECORD -> REPLAY -> MATCH -> RESULT phase control |
| `vga_timing.v` | 640x480 visible area, sync, blanking and pixel clock |
| `note_display.v` | Eight-key visual keyboard and phase colour band |
| `kavin_milestone1.v` | Connects the controller and display; integration top |
| `tests/tb_*.v` | Self-checking controller, timing, renderer and integration simulations |

## Run locally

Install Icarus Verilog and Make, then run from this directory:

```sh
make          # run all simulations and compile the integration top
make -B test  # force all simulations to run again
make compile # compile only, no simulation
```

The RTL uses Verilog-2001. Testbenches use Icarus's `$fatal` extension to
return a failing exit code. Generated files stay in `.build/`, which Git ignores.

## Interface to Saajan's modules / the board wrapper

Use `kavin_milestone1` as the top for simulation. In Quartus, instantiate it
inside the eventual DE1-SoC board wrapper rather than assigning its logical
control inputs directly to physical pins.

- `CLOCK_50`: 50 MHz board clock. All control inputs must use this domain.
- `reset`: synchronous, active high. Assert across at least one rising edge.
  Synchronize any physical reset/button input in the board wrapper.
- `note_id[2:0]`: 0=C, 1=D, 2=E, 3=F, 4=G, 5=A, 6=B, 7=upper C.
  This is a proposed integration mapping; use the same map in the decoder
  and tone generator. These are note IDs, not PS/2 scan codes.
- `note_active`: high while the displayed note is sounding. Keep `note_id`
  stable while active. Drive these from the keyboard/tone logic for milestone 1;
  later multiplex in the recorded note during replay. Single notes only.
- `start`: one-clock pulse to begin recording from IDLE or RESULT.
- `finish_record`: one-clock pulse to request replay. Ignored for an empty
  recording. Once memory exists, its full condition can also trigger this pulse.
- `sequence_nonempty`: high when at least one note has been stored.
- `replay_done`, `match_done`: one-clock completion pulses from the future
  replay and comparison modules. Leave low until those modules exist.
- `game_state`: 0=IDLE, 1=RECORD, 2=REPLAY, 3=MATCH, 4=RESULT.
- `record_enable`, `replay_enable`, `match_enable`: phase enables for other modules.

On a new recording, future memory/score modules must clear their sequence length,
indices and score. Detect entry into RECORD or use the accepted start event.
The FSM does not store or clear that data itself. Do not connect a held button
to a pulse input: synchronize, debounce and edge-detect physical controls first.
For a milestone-1 keyboard display, tie unused control inputs low; the display
continues highlighting keys in IDLE.

## VGA output

Connect the 8-bit `VGA_R/G/B`, `VGA_CLK`, `VGA_HS`, `VGA_VS`, `VGA_BLANK_N`
and `VGA_SYNC_N` outputs through the course's verified DE1-SoC pin assignments.
Sync and blanking outputs are active low. Composite `VGA_SYNC_N` is held low.
The display is eight white keys at the bottom with the active key green.
The top band is blue in IDLE, red in RECORD, yellow in REPLAY, green in MATCH
and purple in RESULT. Text, piano-roll animation and score rendering are deferred.

Horizontal timing: 640 visible + 16 front porch + 96 sync + 48 back porch = 800.
Vertical timing: 480 visible + 10 front porch + 2 sync + 33 back porch = 525.
The divider produces 25 MHz and approximately 59.52 Hz refresh; nominal VGA is
25.175 MHz. Test monitor compatibility on hardware. Coordinates update on the
falling pixel-clock phase; the DAC samples on the next rising phase.
The testbench checks all 420,000 pixels, sync widths and frame wrap.

This is a self-contained local starter because the Quercus VGA starter code
is not in this repository. When that code is available, either retain this
controller/renderer with its timing interface or adapt to the course controller.
Use one VGA controller at a time.

## Before the lab demonstration

1. Integrate the keyboard decoder and tone/audio path from Saajan.
2. Add the course board wrapper, pin assignments and clock constraints.
   Constrain CLOCK_50 and the divided VGA clock; inspect timing reports.
3. Compile in Quartus, check resources/timing, and program the DE1-SoC.
4. Check reset, all eight notes, repeated notes, audio and VGA on real hardware.

Local simulation verifies digital behavior; Quartus synthesis, board timing,
monitor acceptance and audio/keyboard operation have not been verified here.

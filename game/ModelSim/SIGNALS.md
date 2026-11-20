# Reading the combined waveform

`tb_full_system` is the testbench. `dut` is the actual Echo Duel board top.
Names such as `dut/kavin/x` mean the `x` wire inside Kavin's module inside the top.

| Displayed wave | Meaning |
|---|---|
| key | Actual decoded key: A, S, D, F, H, J, K, L, or released. Derived from the captured LED bus. |
| note | LEDR[3:0]: 0001=C, 0010=D, 0100=E, 1000=F; 0000=off. |
| player | LEDR[9]: P1 (ASDF) or P2 (HJKL). |
| held | 1 while a recognized note key is held. |
| audio_sample | Audio square wave: +10,000,000 / -10,000,000; zero is silence. |
| audio_ready | Audio controller has room for another sample. |
| audio_serial | Serial audio bits sent to the external audio chip. |
| errors | Failed checks so far; must be 0 after ALL FULL SYSTEM TESTS PASSED. |

The key waveform uses cyan for Player 1, yellow for Player 2, and gray for
released. It labels actual decoder output, rather than the testbench's intended
key. Player remains selected when a key is released, while note returns to 0000.
The test runs A -> S -> D -> F -> H -> J -> K -> L, with releases between keys.
VGA signals and raw PS/2 bits are hidden from this presentation view; the same
full-system simulation and checks still run.

## Key codes

| Player 1 | Player 2 | note_id | Pitch |
|---|---|---|---|
| A = 1C | H = 33 | 0 | C |
| S = 1B | J = 3B | 1 | D |
| D = 23 | K = 42 | 2 | E |
| F = 2B | L = 4B | 3 | F |

A release sends F0 followed by the released key's code. The waveform's green
key colour is hexadecimal 073; white is 1FF. RGB outputs describe the monitor's
current scanning position, which usually differs from the painter's x/y.

The automatic VGA checks inspect selected pixel writes into the framebuffer
and horizontal sync activity. They do not compare a complete rendered monitor
image. Audio checks inspect samples, serial DAC activity and release silence.
External keyboard pulses, codec clocks and I2C acknowledgements come from the
testbench; the course controllers and Intel RAM/PLL/FIFO simulation models run
inside the project. Recording, replay and scoring are future milestones.

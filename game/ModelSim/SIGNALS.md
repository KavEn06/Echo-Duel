# Reading the combined waveform

`tb_full_system` is the testbench. `dut` is the actual Echo Duel board top.
Names such as `dut/kavin/x` mean the `x` wire inside Kavin's module inside the top.

| Signal | Meaning |
|---|---|
| PS2_CLK | Clock pulses supplied by the simulated keyboard. |
| PS2_DAT | Keyboard bits, sent one at a time. |
| ps2_byte | Received scan code, displayed in hexadecimal. |
| ps2_byte_en | One-clock pulse indicating a new scan code. |
| note_id | Pitch: 0=C, 1=D, 2=E, 3=F. |
| player | 0=Player 1 (ASDF), 1=Player 2 (HJKL). |
| note_on | 1 while a recognized note key is held. |
| LEDR | Bits 0..3 identify the note; bit 9 identifies the player. |
| sample | Audio square wave: +10,000,000 / -10,000,000; zero is silence. |
| audio_out_allowed | Audio controller has room for another sample. |
| AUD_DACDAT | Serial audio bits sent to the external audio chip. |
| x | Horizontal coordinate of the pixel being written, 0..159. |
| y | Vertical coordinate of that pixel, 0..119. |
| color | Pixel colour in 9-bit RRR GGG BBB format. |
| write | 1 means write x/y/color into VGA memory on the next clock edge. |
| VGA_HS | Horizontal sync timing for each monitor row. |
| VGA_VS | Vertical sync timing for each monitor frame. |
| VGA_R | Red level currently sent to the monitor. |
| VGA_G | Green level currently sent to the monitor. |
| VGA_B | Blue level currently sent to the monitor. |
| errors | Failed checks so far; must be 0 after ALL FULL SYSTEM TESTS PASSED. |

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

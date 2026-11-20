# Combined Echo Duel milestone 1

Open `echo_duel_m1.qpf` in Quartus, or run `compile.cmd` on the remote PC
for a complete hardware build. Read `compile.log` and the reports in `output_files`. This connects Saajan's keyboard/note/audio
modules to Kavin's existing VGA interface without renaming its ports.
The two teammates' source modules remain in `Milestone 1/Kavin` and `Milestone 1/Saajan`.
The top and real course keyboard/audio support modules live here.

Press KEY[0] to reset. ASDF and HJKL select C/D/E/F for Players 1 and 2.
The selected note plays through audio and highlights on VGA. LEDs 0..3 show
the note, and LED 9 shows the player. This is the playable-keyboard milestone;
melody recording, replay and scoring are later work. The phase stays IDLE.

## Combined ModelSim simulation

On the DESL remote PC, double-click `game/ModelSim/fullsystem.cmd`.
Or change ModelSim's directory to `game/ModelSim` and enter `do testbench.do`.
This follows the lab layout: `testbench.do` compiles/runs and `full_wave.do`
sets up the waveform. `game/testbench.do` also forwards to this script.

The combined test presses and releases ASDF/HJKL over actual PS/2 wires.
It checks decoded notes/players, LEDs, green/white pixel writes, tone samples,
the real audio FIFO/serializer's DAC output and VGA horizontal sync. It uses
real course PS/2, VGA, audio and codec configuration RTL plus Intel simulation
libraries. The testbench supplies external keyboard signals, codec clocks and
an idealized I2C acknowledgement; it does not simulate physical sound or a monitor.
Game recording/replay/scoring are not implemented in this milestone.

The full run can take several minutes with the Intel peripheral models.
ModelSim stays open after the tests. Double-click `results.cmd` to reopen the
saved waveform later without rerunning; keep `game/vsim.wlf` on the remote PC. Results are in `full_system_transcript.log`.
The launcher selects installed ModelSim 18.1 because newer Questa 2023 on PATH
failed with a license error during this session.

## Audio-only simulation

Double-click `game/ModelSim/audio.cmd`, or run `do audio.do` from `game/ModelSim`.
This independently checks C/D/E/F divider periods, amplitudes and release silence
at 50 MHz, using `wave.do` for its waveform and `audio_transcript.log` for results.

## Local checks

```sh
make             # audio + integration + real PS/2 wire protocol, then top compile
make audio       # tone generator only
make integration # keyboard bytes -> decoder -> tone samples + framebuffer
make ps2         # PS/2 clock/data pulses -> real course PS/2 receiver -> notes
```

Local integrated tests substitute RAM/PLL and audio I/O with functional models.
Quartus uses the real supplied IP and codec setup files instead. Simulation
results do not establish hardware timing, codec initialization or audio playback.

## Source attribution

Saajan's original ZIP supplies the integration top, course PS/2/audio controllers,
modules and tests. Course audio controllers in the ZIP match `Audio.zip` from:
https://q.utoronto.ca/courses/468637/pages/audio-controller
The previously missing `course_audio/avconf.v` and `I2C_Controller.v` are copied
from that official download (Canvas file 45693739). The avconf lookup block
has `always @(*)` added to prevent the original zero-delay `always` loop from
hanging simulation; its lookup values and hardware behavior are unchanged. Kavin's course VGA
source attribution is in `../Milestone 1/Kavin/COURSE_SOURCES.md`.

For ModelSim 10.5 compatibility, the PS/2 mouse-initialization register is
declared before its uses; behavior is unchanged.

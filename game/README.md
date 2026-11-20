# Combined Echo Duel milestone 1

Open `echo_duel_m1.qpf` in Quartus. This connects Saajan's keyboard/note/audio
modules to Kavin's existing VGA interface without renaming its ports.
The two teammates' source modules remain in `Milestone 1/Kavin` and `Milestone 1/Saajan`.
The top and real course keyboard/audio support modules live here.

Press KEY[0] to reset. ASDF and HJKL select C/D/E/F for Players 1 and 2.
The selected note plays through audio and highlights on VGA. LEDs 0..3 show
the note, and LED 9 shows the player. This is the playable-keyboard milestone;
melody recording, replay and scoring are later work. The phase stays IDLE.

## Audio-only simulation (start here)

In ModelSim/Questa, change directory to `game/ModelSim`, then type:

```tcl
do testbench.do
```

It compiles `tone_gen.v` and the audio testbench, runs automatically, displays
C/D/E/F square waves and silence, checks the divider periods/amplitudes, and
saves `audio_transcript.log`. No Intel libraries are needed for this standalone
tone test. It uses the actual 50 MHz clock. It tests digital samples, not the
physical codec, speakers, or whether the final audio stream sounds correct.
`game/testbench.do` forwards to the same script if you open the game folder.

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
unchanged from that official download (Canvas file 45693739). Kavin's course VGA
source attribution is in `../Milestone 1/Kavin/COURSE_SOURCES.md`.

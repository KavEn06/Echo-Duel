# Open ModelSim, then: do testbench.do
# Run from game/ModelSim, matching the previous lab workflow.
set script_dir [pwd]
set game_dir [file dirname $script_dir]
set repo_dir [file dirname $game_dir]
set saajan_dir [file join $repo_dir {Milestone 1} Saajan]
catch {quit -sim}
cd $script_dir
transcript file audio_transcript.log
transcript on
if {![file exists work]} {vlib work}
vmap work work
vlog -work work [file join $saajan_dir tone_gen.v] [file join $game_dir tests tb_audio.v]
vsim -onfinish stop -voptargs=+acc work.tb_audio
# Load the waveform layout, as in the previous lab scripts.
do wave.do
run -all
wave zoom full
if {[examine -radix decimal sim:/tb_audio/errors] != 0} {error {Audio test failed; see audio_transcript.log}}
echo {PASS: C, D, E, F frequencies, amplitudes and silence. Rerun with: do testbench.do}

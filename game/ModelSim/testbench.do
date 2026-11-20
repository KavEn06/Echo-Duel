# Open ModelSim, then: do testbench.do
# This script finds its sources relative to itself, independent of the current folder.
set script_dir [file dirname [file normalize [info script]]]
set game_dir [file dirname $script_dir]
set repo_dir [file dirname $game_dir]
set saajan_dir [file join $repo_dir {Milestone 1} Saajan]
catch {quit -sim}
cd $script_dir
transcript file audio_transcript.log
transcript on
if {![file exists audio_work]} {vlib audio_work}
vmap audio_work audio_work
vlog -work audio_work [file join $saajan_dir tone_gen.v] [file join $game_dir tests tb_audio.v]
vsim -onfinish stop -voptargs=+acc audio_work.tb_audio
view wave
add wave -divider {Audio controls}
add wave -radix unsigned sim:/tb_audio/note_id
add wave sim:/tb_audio/note_on sim:/tb_audio/reset
add wave -divider {Square wave: +10 million / -10 million; zero when released}
add wave -radix decimal -format analog-step -height 140 -min -11000000 -max 11000000 sim:/tb_audio/sample
add wave sim:/tb_audio/high
configure wave -timelineunits ms
run -all
wave zoom full
if {[examine -radix decimal sim:/tb_audio/errors] != 0} {error {Audio test failed; see audio_transcript.log}}
echo {PASS: C, D, E, F frequencies, amplitudes and silence. Rerun with: do testbench.do}

# Run from game/ModelSim, like the previous labs: do testbench.do
set script_dir [pwd]
set game_dir [file dirname $script_dir]
set repo_dir [file dirname $game_dir]
set kavin_dir [file join $repo_dir {Milestone 1} Kavin]
set saajan_dir [file join $repo_dir {Milestone 1} Saajan]
catch {quit -sim}
cd $script_dir
transcript file full_system_transcript.log
transcript on
if {![file exists work]} {vlib work}
vmap work [file join $script_dir work]
# Real course controllers and Intel simulation libraries; no course_stubs.v.
vlog -work work [file join $game_dir echo_duel_m1.v] \
    [file join $saajan_dir note_decoder.v] [file join $saajan_dir tone_gen.v] \
    [file join $kavin_dir game_fsm.v] [file join $kavin_dir frame_writer.v] \
    [file join $kavin_dir kavin_milestone1.v] \
    {*}[glob [file join $kavin_dir vga_adapter *.v]] \
    {*}[glob [file join $game_dir course_ps2 *.v]] \
    {*}[glob [file join $game_dir course_audio *.v]] \
    [file join $game_dir tests tb_full_system.v]
# The real VGA RAM loads MIF/black_160_9.mif relative to this directory.
cd $game_dir
vmap work [file join $script_dir work]
vsim -onfinish stop -voptargs=+acc -L altera_mf_ver -L 220model_ver -L cyclonev_ver work.tb_full_system
do [file join $script_dir full_wave.do]
run -all
wave zoom full
cd $script_dir
if {[examine -radix decimal sim:/tb_full_system/errors] != 0} {
    error {FAIL: combined system checks failed; see transcript}
}
echo {PASS: combined keyboard, LEDs, VGA writes and real audio serializer checks}

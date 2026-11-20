# View the saved full-system waveform without rerunning the simulation.
set script_dir [pwd]
set game_dir [file dirname $script_dir]
catch {quit -sim}
catch {dataset close results}
vsim -view "results=[file join $game_dir vsim.wlf]"
do [file join $script_dir full_wave.do]
configure wave -signalnamewidth 1
wave zoom full

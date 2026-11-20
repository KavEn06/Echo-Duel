# Convenience entry point from the game folder: do testbench.do
set entry_dir [file dirname [file normalize [info script]]]
do [file join $entry_dir ModelSim testbench.do]

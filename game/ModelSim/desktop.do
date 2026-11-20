# Run from game/ModelSim AFTER the test completes: do desktop.do
set repo_dir [file normalize ../..]
set mover [file join $repo_dir game ModelSim desktop.ps1]
# Close the active dataset, keeping the ModelSim application open.
catch {quit -sim}
transcript file [file join [file normalize ~] echo_move_transcript.log]
cd [file normalize ~]
set destination [string trim [exec powershell -NoProfile -ExecutionPolicy Bypass -File $mover -Source $repo_dir]]
cd [file join $destination game ModelSim]
do results.do
echo "Project moved to $destination"

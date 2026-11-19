# Kavin milestone starter

Scope: milestone 1 from the revised proposal: basic VGA note display and initial game-state controller. All files use Verilog-2001 and a 50 MHz input clock. Keyboard decoding, tone generation, sequence storage and scoring belong to later integration.

1. Test the controller's reset, empty-recording guard, record/replay/match/result transitions, restart and enables; implement game_fsm.v.
2. Test 640x480 timing, sync widths, blanking and frame wrap; implement vga_timing.v with a 25 MHz pixel output and clock enable.
3. Test key highlighting, idle display and blanking; implement note_display.v and integrate all modules in kavin_milestone1.v.
4. Run the complete simulation suite and compile the top. Document the synchronous integration contract and remaining board checks.

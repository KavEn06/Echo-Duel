# Echo-Duel

Two-player FPGA melody memory game for ECE241 on the DE1-SoC.

## Project folders

- [Game](game/README.md): complete game implementation and integration.
- [Saajan: Milestone 1 keyboard and audio](Milestone%201/Saajan/README.md)

## Milestone 1

- [Kavin: VGA note display and initial game-state controller](Milestone%201/Kavin/README.md)

Run Kavin's local Verilog simulations and compile check with:

```sh
make -C "Milestone 1/Kavin"
```

Requires Icarus Verilog (`iverilog`, `vvp`) and Make. See the milestone README
for module interfaces, integration requirements and hardware checks still needed.

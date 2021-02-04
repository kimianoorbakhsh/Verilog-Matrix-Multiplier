# Verilog Matrix Multiplier
Final Project for Digital Systems Design Course, Fall 2020

## Running simulation on a module

```Bash
vlog -work work ./src/*.v
vsim -gui work.<testbench> -voptargs=+acc
```

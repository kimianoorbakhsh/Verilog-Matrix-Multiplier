# Verilog Matrix Multiplier
Final Project for Digital Systems Design Course, Fall 2020

Sharif University of Technology

Computer Engineering Department

## Contributors

-  [Ahmad Salimi](https://github.com/ahmadsalimi)
-  [Kimia Noorbakhsh](https://github.com/kimianoorbakhsh)
-  [Saee Saadat](https://github.com/SaeeSaadat)
-  [Alireza Hosseinpour](https://github.com/doctorhoseinpour)

## Running simulation on a module

```Bash
vlog -work work ./src/*.v
vsim -gui work.<testbench> -voptargs=+acc
```
``` Check the output with Golden Model in python:
python3 <model.py address> <input_a address> <input_b address> <simout.b address> <m> <n> <m>
```
## License

MIT License, Copyright (c) 2021 Kimia Noorbakhsh (and the gang!)

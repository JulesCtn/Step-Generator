# Step-Generator
This is a SPI (Mode 0) slave module. With ARR values send through SPI, it generates steps in order to control a motor in frequency.

### Configurable constants (Generics)
  - DATA_BITS: number of bits of the SPI input frame (default: 32bits);
  - PULSE_WIDTH: Width of a single pulse in µs (default: 2µs);
  - FREQ_FPGA: Internal frequency of the FPGA in MHz (default: 400MHz);

### I/O Pin assignement on X3 support
Useful pin:
  - 2 -> GND;
  - 20 -> 3.3V;

| Pin Number | Ball location | Function           |
|------------|---------------|--------------------|
| 3          | F8            | SPI clock input    |
| 5          | F9            | SPI MOSI input     |
| 7          | E7            | SPI CS input       |
| 4          | G8            | Reset_n (active low)|
| 8          | E6            | Step output        |

#### Device used: MachXO3LF-9400C.
#### Software used: Lattice Diamond.

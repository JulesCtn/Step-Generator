# Step-Generator
This is a SPI slave module (mode 0).
### Inputs:
  - Active low reset.
  - SPI frame with configurable length (look for DATA_BITS).
  - SPI clock.
  - ARR (32 bits long, configurable).

### Output
  - Step signal for an engine.

## Pin assignement on X3 support
Useful pin:
  - 2 -> GND;
  - 20 -> 3.3V;
| Pin Number | Ball location | Function |
| ------------- | ------------- | ------------- |
| '3' | "F8"  | SPI clock input |
| '5'  | "F9"  | SPI MOSI input |
| '7'  | "E7"  | SPI CS input |
| '4'  | "G8"  | Reset_n (active low) |
| '8'  | "E6"  | Step output |

#### Device used: MachXO3LF-9400C.
#### Software used: Lattice Diamond.

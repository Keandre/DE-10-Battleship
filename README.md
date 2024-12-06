# DE-10 Battleship

A single-player version of the classic Battleship game implemented on the DE10-Lite FPGA using SystemVerilog. Features include VGA-based visual output, accelerometer-based cursor control, and microphone-activated commands.

## Features

- **Dynamic Gameplay**: Single-player mode with AI that makes random moves.
- **Innovative Controls**:
  - Tilt the board past a threshold for cursor movement, and return it to neutral (0°) before making the next move.
  - Voice commands via microphone for ship placement and attack execution.
- **Visual Feedback**: VGA display for real-time game updates.

## Setup Instructions

1. **Clone Repository**:
   `git clone https://github.com/Keandre/DE-10-Battleship.git`
2. **Compile Code**:
   - Use Quartus to compile SystemVerilog files.
   - Add the provided PLL IP with 50 MHz input and 25.175 MHz output frequencies:
     - Open the IP catalog (`Tools => IP Catalog`) and select `ALTPLL`.
     - Save the component in the `ip` directory as `pll.v`.
     - Set the input clock frequency to `50 MHz` and output to `25.175 MHz`.
     - Ensure the `pll_inst.v` template is created for integration.
3. **Program FPGA**:
   - Upload the compiled bitstream to the DE10-Lite board.
   - Connect peripherals: VGA display and microphone.

## Controls

- **Cursor Movement**: Tilt the board past a threshold (accelerometer) and return to neutral before the next move.
- **Actions**: Use microphone for placement commands and attack phase.

## PLL Configuration Details

If needed, reconfigure the PLL to generate the correct clock frequencies:
1. Open the `ALTPLL` IP in Quartus.
2. Adjust the reference clock frequency to `50 MHz`. skip the rest
3. Set the output clock frequency to `25.175 MHz`.
4. Integrate the PLL into the design by instantiating it in the top-level module:
   ```bash
   pll pll_inst (.inclk0(MAX10_CLK1_50), .c0(pixel_clk));`
   ```
## Acknowledgements
I acknowledge the hard work of all my teammates who helped make this possible, as well as EECS3216 for teaching me what's required in order to accomplish this task.

## Extra - Figma Designs
[View BattleShip Figma Design](https://embed.figma.com/design/RYyQckCp7aWO6xDYyBQMZ3/BattleShip?node-id=0-1&embed-host=share)

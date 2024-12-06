`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
`define ENABLE_CLOCK2
`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
`define ENABLE_VGA
`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO



module DE10_LITE_Golden_Top 
import game_types::*;
(
    //////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
    input logic ADC_CLK_10,
`endif

    //////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
    input logic MAX10_CLK1_50,
`endif

    //////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
    input logic MAX10_CLK2_50,
`endif

    //////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
    output logic [12:0] DRAM_ADDR,
    output logic [1:0] DRAM_BA,
    output logic DRAM_CAS_N,
    output logic DRAM_CKE,
    output logic DRAM_CLK,
    output logic DRAM_CS_N,
    inout logic [15:0] DRAM_DQ,
    output logic DRAM_LDQM,
    output logic DRAM_RAS_N,
    output logic DRAM_UDQM,
    output logic DRAM_WE_N,
`endif

    //////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
    output logic [7:0] HEX0,
`endif
`ifdef ENABLE_HEX1
    output logic [7:0] HEX1,
`endif
`ifdef ENABLE_HEX2
    output logic [7:0] HEX2,
`endif
`ifdef ENABLE_HEX3
    output logic [7:0] HEX3,
`endif
//`ifdef ENABLE_HEX4
//    output logic [7:0] HEX4,
//`endif
//`ifdef ENABLE_HEX5
//    output logic [7:0] HEX5,
//`endif

    //////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
    input logic [1:0] KEY,
`endif

    //////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
    output logic [9:0] LEDR,
`endif

    //////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
    input logic [9:0] SW,
`endif

    //////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
    output logic [3:0] VGA_B,
    output logic [3:0] VGA_G,
    output logic VGA_HS,
    output logic [3:0] VGA_R,
    output logic VGA_VS,
`endif

    //////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
    output logic GSENSOR_CS_N,
    input logic [2:1] GSENSOR_INT,
    output logic GSENSOR_SCLK,
    inout wire GSENSOR_SDI,
    inout logic GSENSOR_SDO,
`endif

    //////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
    inout logic [15:0] ARDUINO_IO,
    inout logic ARDUINO_RESET_N,
`endif

    //////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
    inout logic [35:0] GPIO
`endif
);

    //=======================================================
    //  Internal Signals
    //=======================================================
    logic reset_b;
    assign reset_b = SW[9];  // Active-low reset from switch 9
    
    // Clock and reset
    logic pixel_clk;               // VGA pixel clock (25.175 MHz)
    logic por_reset_n;             // Power-on reset signal
    
    // VGA signals
    logic disp_ena;                // Display enable
    logic [31:0] column, row;      // Pixel coordinates
    
    // Accelerometer signals
    logic [9:0] x_data, y_data, z_data;        // Processed accelerometer data
    logic [9:0] x_data_o, y_data_o, z_data_o;  // Raw accelerometer outputs
    logic data_valid;                           // Data valid signal
    logic signed [8:0] angle_x, angle_y;        // Calculated angles
    
    // Tilt control signals
    logic left_tilt, right_tilt, up_tilt, down_tilt;
	 
	 // Add at the top with other parameters
	 //  Grid Parameters
    //=======================================================
    localparam GRID_SIZE = 10;
    localparam CELL_SIZE = 20;
    localparam GRID_SPACING = 40;
    localparam GRID_WIDTH = GRID_SIZE * CELL_SIZE;
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    localparam TOTAL_WIDTH = (2 * GRID_SIZE * CELL_SIZE) + GRID_SPACING;
    localparam LEFT_OFFSET = (640 - TOTAL_WIDTH) / 2;
	 //localparam TOP_OFFSET = 
    //=======================================================
    //  PLL Instantiation
    //=======================================================
    pll pll_inst (
        .inclk0(MAX10_CLK1_50),
        .c0(pixel_clk)
    );

    //=======================================================
    //  Power-On Reset Module
    //=======================================================
    POR #(
        .RESET_TIME(1000000)
    ) por_inst (
        .clk(pixel_clk),
        .reset_n(por_reset_n)
    );

    //=======================================================
    //  VGA Controller
    //=======================================================
    vga_controller #(
        .h_pixels(640),
        .v_pixels(480)
    ) vga_ctrl (
        .pixel_clk(pixel_clk),
        .reset_n(por_reset_n),
        .h_sync(VGA_HS),
        .v_sync(VGA_VS),
        .disp_ena(disp_ena),
        .column(column),
        .row(row)
    );

    //=======================================================
    //  Accelerometer Interface
    //=======================================================
    adxl345_interface adxl (
        .i_clk(MAX10_CLK1_50),
        .i_rst_n(por_reset_n),
        .o_data_x(x_data_o),
        .o_data_y(y_data_o),
        .o_data_z(z_data_o),
        .o_data_valid(data_valid),
        .o_sclk(GSENSOR_SCLK),
        .io_sdio(GSENSOR_SDI),
        .o_cs_n(GSENSOR_CS_N),
        .i_int1(GSENSOR_INT[1])
    );

 
 cordic_vec #(10)  corx (MAX10_CLK1_50, reset_b, z_data, x_data, 1'b1, angle_x);
  cordic_vec #(10)  cory (MAX10_CLK1_50, reset_b, z_data, y_data, 1'b1, angle_y);


    format_7seg fseg (
        .i_data(SW[3] ? angle_y : angle_x),
        .o_SSeg(HEX3),
        .o_HSeg(HEX2),
        .o_MSeg(HEX1),
        .o_LSeg(HEX0)
    );

    always_ff @(posedge pixel_clk) begin
        if (~reset_b) begin
            x_data <= '0;
            y_data <= '0;
            z_data <= '0;
        end else if (data_valid) begin
            x_data <= x_data_o;
            y_data <= y_data_o;
            z_data <= z_data_o;
        end
    end

 
    localparam THRESHOLD = 30;
    
    always_comb begin
       // LEDR[3:0] = '0;  // Initialize LEDs
        {left_tilt, right_tilt, up_tilt, down_tilt} = '0;  // Initialize tilt signals
        
        if (angle_x > THRESHOLD) begin
      //      LEDR[0] = 1'b1;
            left_tilt = 1'b1;
        end
        else if (angle_x < -THRESHOLD) begin
       //     LEDR[1] = 1'b1;
            right_tilt = 1'b1;
        end
        else if (angle_y > THRESHOLD) begin
       //     LEDR[2] = 1'b1;
            down_tilt = 1'b1;
        end
        else if (angle_y < -THRESHOLD) begin
      //      LEDR[3] = 1'b1;
            up_tilt = 1'b1;
        end
    end


// Game state signals
board_t player_board;
board_t ai_board;
board_t ai_ships_pos;
ships_array_t player_ships;
ships_array_t ai_ships;
sizes_array_t player_ship_sizes;
sizes_array_t ai_ship_sizes;
sizes_array_t player_ship_orientations;
sizes_array_t ai_ship_orientations;
colors_array_t player_ship_colors;
colors_array_t ai_ship_colors;

// Game control signals
logic game_initialized;
logic all_ships_sunk;
logic [31:0] remaining_ships;
logic game_over;
logic [3:0] cursor_x, cursor_y;
logic last_key0;
game_state_t game_state;

logic [2:0] ships_placed;  // New tracking signal
logic [9:0] debug_leds;

logic current_ship_orientation;


assign ARDUINO_IO[0] = 1'bZ;  // High-impedance state for input mode


game_board_controller game_boards (
    .clk(pixel_clk),
    .rst_n(por_reset_n),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y),
    .key0(ARDUINO_IO[0]), // Microphone
    .key1(KEY[1]),     
    .remaining_ships(remaining_ships),
    .game_over(game_over),
    .player_board(player_board),
    .ai_board(ai_board),
    .ai_ships_pos(ai_ships_pos),
    .player_ships(player_ships),
    .ai_ships(ai_ships),
    .player_ship_sizes(player_ship_sizes),
    .ai_ship_sizes(ai_ship_sizes),
    .player_ship_orientations(player_ship_orientations),
    .ai_ship_orientations(ai_ship_orientations),
    .player_ship_colors(player_ship_colors),
    .ai_ship_colors(ai_ship_colors),
    .current_ship(ships_placed),
    .game_state(game_state),
    .preview_ship_counter(preview_ship_counter),
    .debug_controller_length(debug_controller_length),
    .debug_controller_orientation(debug_controller_orientation),
    .debug_leds(debug_leds), 
	 .current_ship_length(current_ship_length),
	 .current_ship_orientation(current_ship_orientation)
);

    cursor_controller cursor_ctrl (
        .clk(pixel_clk),
        .rst_n(por_reset_n),
        .left_tilt(left_tilt),
        .right_tilt(right_tilt),
        .up_tilt(up_tilt),
        .down_tilt(down_tilt),
        .cursor_x(cursor_x),
        .cursor_y(cursor_y),
		  .current_ship_length(current_ship_length), 
		  .orientation(current_ship_orientation),      
        .game_state(game_state)                
    );

    // Color signals
    logic [3:0] player_r, player_g, player_b;
    logic [3:0] ai_r, ai_g, ai_b;
    logic [3:0] cursor_r, cursor_g, cursor_b;


// Player Grid
draw_grid player_grid1 (
    .clk(pixel_clk),
    .reset(~por_reset_n),
    .row(row - 100),
    .col(column - LEFT_OFFSET),
    .board(player_board),
    .GRID_ROWS(10),
    .GRID_COLS(10),
    .CELL_SIZE(CELL_SIZE),
    .ships(player_ships),
    .ship_sizes(player_ship_sizes),
    .orientations(player_ship_orientations),
    .ship_colors(player_ship_colors),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y),
    .current_ship_length(current_ship_length), 
    .current_orientation(current_ship_orientation),
    .game_state(game_state),
    .vga_r(player_r),
    .vga_g(player_g),
    .vga_b(player_b)
);


draw_grid ai_grid1 (
    .clk(pixel_clk),
    .reset(~por_reset_n),
    .row(row - 100),
    .col(column - (LEFT_OFFSET + (GRID_SIZE * CELL_SIZE) + GRID_SPACING)),
    .board(ai_board),
    .GRID_ROWS(10),
    .GRID_COLS(10),
    .CELL_SIZE(CELL_SIZE),
    .ships(ai_ships),
    .ship_sizes(ai_ship_sizes),
    .orientations(ai_ship_orientations),
    .ship_colors(ai_ship_colors),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y),
    .current_ship_length(4'd0),  // Default value since not used for AI grid
    .current_orientation(1'b0),  // Default value since not used for AI grid
    .game_state(game_state),
    .vga_r(ai_r),
    .vga_g(ai_g),
    .vga_b(ai_b)
);
    // Cursor
	assign current_ship = ships_placed;  // Make sure current_ship gets updated
	
    logic [3:0] preview_ship_size;
	logic preview_orientation;
	logic [2:0] preview_ship_counter;

always_comb begin
    preview_ship_size = player_ship_sizes[current_ship];
    preview_orientation = player_ship_orientations[current_ship];
end

assign current_ship = ships_placed;  // Make sure current_ship gets updated


cursor cursor_inst (
    .clk(pixel_clk),
    .reset(~por_reset_n),
    .row(row - 100),
    .col(column - 2),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y),
    .current_ship(current_ship),
    .current_ship_length(current_ship_length),  
    .orientation(current_ship_orientation),
    .game_state(game_state),
    .CELL_SIZE(CELL_SIZE),
    .grid_offset_x(LEFT_OFFSET + GRID_WIDTH + GRID_SPACING),
    .vga_r(cursor_r),
    .vga_g(cursor_g),
    .vga_b(cursor_b)
);


logic [3:0] debug_controller_length;
logic debug_controller_orientation;
logic [3:0] current_ship_length;
logic orientation;


logic [3:0] debug_ship_length;
logic [2:0] debug_ship_index;


assign LEDR = debug_leds;
  always_comb begin
    if (column >= LEFT_OFFSET && column < LEFT_OFFSET + GRID_WIDTH) begin
        // Player board region
        VGA_R = player_r;
        VGA_G = player_g;
        VGA_B = player_b;
    end 
    else if (column >= LEFT_OFFSET + GRID_WIDTH + GRID_SPACING && 
             column < LEFT_OFFSET + 2*GRID_WIDTH + GRID_SPACING) begin
        // AI board region with cursor overlay
        if (cursor_r != 0 || cursor_g != 0 || cursor_b != 0) begin
            VGA_R = cursor_r;
            VGA_G = cursor_g;
            VGA_B = cursor_b;
        end
        else begin
            VGA_R = ai_r;
            VGA_G = ai_g;
            VGA_B = ai_b;
        end
    end
    else begin
        // Background
        VGA_R = 4'd0;
        VGA_G = 4'd0;
        VGA_B = 4'd0;
    end
end

endmodule

module format_7seg (
    input [8:0] i_data,        // Input 9-bit data: [8] = sign bit, [7:0] = the actual value
    output logic [7:0] o_SSeg, // Output for Sign display segment (1 if negative, 0 otherwise)
    output logic [7:0] o_HSeg, // Output for Hundreds digit display segment
    output logic [7:0] o_MSeg, // Output for Tens digit display segment
    output logic [7:0] o_LSeg  // Output for Ones digit display segment
);
    // Local variables for different parts of the input value (hundreds, tens, ones)
    logic [7:0] data_nosign;  // Holds the absolute value of i_data
    logic [7:0] data_min100;  // Value adjusted for hundreds (after subtracting 100 if necessary)
    logic [7:0] data_10s;     // Tens digit of the adjusted value
    logic [7:0] data_1s;      // Ones digit of the adjusted value

    // Remove the sign bit and handle the absolute value (data_nosign holds unsigned value)
    assign data_nosign = i_data[8] ? -(i_data[7:0]) : i_data[7:0];

    // Assign the Sign display (o_SSeg): If the sign bit is 1, display negative sign
    assign o_SSeg = i_data[8] ? 8'hBF : 8'hFF;  // 8'hBF is a representation of a minus sign on a 7-segment display

    // Instantiate 7-segment converters for the tens and ones digits
    int_to_7seg MS (
        .i_int(data_10s),  // Input the tens digit
        .o_seg(o_MSeg)     // Output to tens 7-segment display
    );

    int_to_7seg LS (
        .i_int(data_1s),   // Input the ones digit
        .o_seg(o_LSeg)     // Output to ones 7-segment display
    );

    // Calculate the hundreds digit (o_HSeg) and determine if the value exceeds 99
    always_comb begin
        if (data_nosign > 8'd99) begin
            o_HSeg = 8'hF9;    // Display '1' for hundreds digit on 7-segment
            data_min100 = data_nosign - 8'd100;  // Subtract 100 from the value to get the remainder
        end else begin
            o_HSeg = 8'hC0;    // Display '0' for hundreds digit on 7-segment
            data_min100 = data_nosign;  // No need to subtract anything if the value is less than 100
        end
    end

    // Extract tens and ones from the remaining value after hundreds digit calculation
    always_comb begin
        data_10s = data_min100 / 8'd10;  
        data_1s = data_min100 - (data_10s * 8'd10);  // Get the ones place by subtracting tens value
    end
endmodule


module int_to_7seg (
  input        [7:0] i_int,  // Input 8-bit integer to be displayed
  output logic [7:0] o_seg  // Output 7-segment display encoding
);

  always_comb begin
    case (i_int)
      8'd1 : o_seg = 8'hF9;   // Display '1' on the 7-segment display
      8'd2 : o_seg = 8'hA4;   // Display '2'
      8'd3 : o_seg = 8'hB0;   // Display '3'
      8'd4 : o_seg = 8'h99;   // Display '4'
      8'd5 : o_seg = 8'h92;   // Display '5'
      8'd6 : o_seg = 8'h82;   // Display '6'
      8'd7 : o_seg = 8'hF8;   // Display '7'
      8'd8 : o_seg = 8'h80;   // Display '8'
      8'd9 : o_seg = 8'h98;   // Display '9'
      default : o_seg = 8'hC0; // Default case: display '0'
    endcase
  end // always_comb

endmodule

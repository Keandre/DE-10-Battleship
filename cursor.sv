module cursor 
import game_types::*; 
(
    input logic clk,
    input logic reset,
    input logic [31:0] row,
    input logic [31:0] col,
    input logic [3:0] cursor_x,
    input logic [3:0] cursor_y,
    input logic [2:0] current_ship,
    input logic [3:0] current_ship_length,
    input logic orientation,
    input game_state_t game_state,
    input logic [31:0] CELL_SIZE,
    input logic [31:0] grid_offset_x,
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b
);
    logic [31:0] cursor_pixel_x, cursor_pixel_y;
    logic in_cursor;
    
    always_comb begin
        cursor_pixel_x = cursor_x * CELL_SIZE;
        cursor_pixel_y = cursor_y * CELL_SIZE;
        
        if (game_state != PLACEMENT_PHASE) begin
            cursor_pixel_x = cursor_pixel_x + grid_offset_x;
        end
    end

    always_comb begin
        in_cursor = 1'b0;
        
        if (game_state == PLACEMENT_PHASE) begin
            if (orientation == 0) begin  // Horizontal
                if (row >= cursor_pixel_y && 
                    row < (cursor_pixel_y + CELL_SIZE) &&
                    col >= cursor_pixel_x && 
                    col < (cursor_pixel_x + (current_ship_length * CELL_SIZE))) begin
                    in_cursor = 1'b1;
                end
            end else begin  // Vertical
                if (row >= cursor_pixel_y && 
                    row < (cursor_pixel_y + (current_ship_length * CELL_SIZE)) &&
                    col >= cursor_pixel_x && 
                    col < (cursor_pixel_x + CELL_SIZE)) begin
                    in_cursor = 1'b1;
                end
            end
        end else begin
            if (row >= cursor_pixel_y && 
                row < (cursor_pixel_y + CELL_SIZE) &&
                col >= cursor_pixel_x && 
                col < (cursor_pixel_x + CELL_SIZE)) begin
                in_cursor = 1'b1;
            end
        end
    end

    // Color output
    always_comb begin
        if (in_cursor) begin
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end
    end

endmodule

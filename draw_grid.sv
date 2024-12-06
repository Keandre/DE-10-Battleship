import game_types::*;
module draw_grid (
    input logic clk,
    input logic reset,
    input logic [31:0] row,
    input logic [31:0] col,
    input board_t board,
    input logic [31:0] GRID_ROWS,
    input logic [31:0] GRID_COLS,
    input logic [31:0] CELL_SIZE,
    input ships_array_t ships,
    input sizes_array_t ship_sizes,
    input sizes_array_t orientations,
    input colors_array_t ship_colors,
    // New inputs for ship preview
    input logic [3:0] cursor_x,
    input logic [3:0] cursor_y,
    input logic [3:0] current_ship_length,
    input logic current_orientation,
    input game_state_t game_state,
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b
);
    logic in_grid;
    logic [3:0] grid_r, grid_g, grid_b;
    logic [31:0] grid_x, grid_y;
    logic is_grid_line;
    logic [2:0] cell_content;
    logic in_preview;
    
    // Calculate grid position
    assign grid_x = col / CELL_SIZE;
    assign grid_y = row / CELL_SIZE;
    
    // Check if current pixel is in grid
    assign in_grid = (grid_x < GRID_COLS) && (grid_y < GRID_ROWS);
    
    // Determine if current pixel is on a grid line
    assign is_grid_line = ((col % CELL_SIZE) == 0) || ((row % CELL_SIZE) == 0);

    // Check if current pixel is in ship preview area
    always_comb begin
        in_preview = 1'b0;
        if (game_state == PLACEMENT_PHASE) begin
            if (current_orientation == 0) begin  // Horizontal
                if (grid_y == cursor_y && 
                    grid_x >= cursor_x && 
                    grid_x < cursor_x + current_ship_length)
                    in_preview = 1'b1;
            end else begin  // Vertical
                if (grid_x == cursor_x && 
                    grid_y >= cursor_y && 
                    grid_y < cursor_y + current_ship_length)
                    in_preview = 1'b1;
            end
        end
    end
    
    // Get cell content if within grid
    assign cell_content = in_grid ? board[grid_y][grid_x] : EMPTY;

    // Color output logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            vga_r <= 4'd0;
            vga_g <= 4'd0;
            vga_b <= 4'd0;
        end
        else if (in_grid) begin
            if (is_grid_line) begin
                // Grid lines
                vga_r <= 4'd8;
                vga_g <= 4'd8;
                vga_b <= 4'd8;
            end
            else if (in_preview && cell_content == EMPTY) begin
                // Ship preview in semi-transparent yellow
                vga_r <= 4'd12;
                vga_g <= 4'd12;
                vga_b <= 4'd0;
            end
            else begin
                case (cell_content)
                    EMPTY: begin
                        vga_r <= 4'd0;
                        vga_g <= 4'd0;
                        vga_b <= 4'd0;
                    end
                    SHIP: begin
                        vga_r <= 4'd0;
                        vga_g <= 4'd15;
                        vga_b <= 4'd0;
                    end
                    HIT: begin
                        vga_r <= 4'd15;
                        vga_g <= 4'd0;
                        vga_b <= 4'd0;
                    end
                    MISS: begin
                        vga_r <= 4'd8;
                        vga_g <= 4'd8;
                        vga_b <= 4'd8;
                    end
                    default: begin
                        vga_r <= 4'd0;
                        vga_g <= 4'd0;
                        vga_b <= 4'd0;
                    end
                endcase
            end
        end
        else begin
            vga_r <= 4'd0;
            vga_g <= 4'd0;
            vga_b <= 4'd0;
        end
    end
endmodule

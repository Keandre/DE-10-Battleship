module render_text #(
    parameter int N = 11 // Number of characters in the string
)(
    input logic [8*N-1:0] string_flat, // Flattened array of ASCII characters
    input logic [9:0] x_start,
    input logic [9:0] y_start,
    input logic [3:0] color_r,
    input logic [3:0] color_g,
    input logic [3:0] color_b,
    input logic [1:0] size,
    input logic border,
    input logic [3:0] border_r,
    input logic [3:0] border_g,
    input logic [3:0] border_b,
    input logic [31:0] row,
    input logic [31:0] col, 
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b
);

    // Calculate text dimensions
    localparam int CHAR_PIXELS = 8;

    logic [31:0] char_width, text_width, text_height;

    // Dynamically calculate dimensions based on size input
    always_comb begin
        char_width = CHAR_PIXELS * size;
        text_width = N * char_width;
        text_height = CHAR_PIXELS * size;
    end

    // Determine if the current pixel is within the text area
    logic in_text_area;
    assign in_text_area = (col >= x_start) && (col < x_start + text_width) &&
                          (row >= y_start) && (row < y_start + text_height);

    // Determine if the current pixel is within the border area
    logic in_border_area;
    assign in_border_area = border && (
        ((col >= x_start - size) && (col < x_start + text_width + size)) &&
        ((row >= y_start - size) && (row < y_start + text_height + size)) &&
        !in_text_area
    );

    // Local coordinates within text area
    logic [31:0] local_x, local_y;
    assign local_x = col - x_start;
    assign local_y = row - y_start;

    // Determine character index
    logic [31:0] char_index;
    assign char_index = local_x / char_width;

    // Ensure char_index is within bounds
    logic valid_char;
    assign valid_char = (char_index < N);

    // Extract the specific character from the flattened string
    logic [7:0] current_char;
    assign current_char = valid_char ? string_flat[8*N-1 - (char_index * 8) -: 8] : 8'd0;

    // Determine font grid coordinates with scaling
    logic [31:0] scaled_x, scaled_y;
    assign scaled_x = local_x % char_width;
    assign scaled_y = local_y % text_height;

    logic [2:0] font_col, font_row;
    assign font_col = scaled_x / size;
    assign font_row = scaled_y / size;

    // Instantiate font_rom
    logic font_pixel;
    font_rom font (
        .char(current_char),
        .row(font_row),
        .col(font_col),
        .pixel(font_pixel)
    );

    always_comb begin
        if (in_text_area && font_pixel) begin
            // Text pixel
            vga_r = color_r;
            vga_g = color_g;
            vga_b = color_b;
        end else if (in_border_area) begin
            // Border pixel
            vga_r = border_r;
            vga_g = border_g;
            vga_b = border_b;
        end else begin
            // Background (black)
            vga_r = 4'd0;
            vga_g = 4'd0;
            vga_b = 4'd0;
        end
    end

endmodule

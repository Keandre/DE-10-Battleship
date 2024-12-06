module cursor_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic left_tilt,
    input  logic right_tilt,
    input  logic up_tilt,
    input  logic down_tilt,
	 input logic [3:0] current_ship_length,
    input logic orientation,               
    input game_types::game_state_t game_state,  
    output logic [3:0] cursor_x,
    output logic [3:0] cursor_y
);
    logic [19:0] timer_count;
    logic move_timer;
    logic can_move;

    // Timer for cursor movement
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            timer_count <= 20'd0;
            move_timer <= 1'b0;
        end else begin
            if (timer_count == 20'd2000000) begin // Adjust this value to control cursor speed
                timer_count <= 20'd0;
                move_timer <= 1'b1;
            end else begin
                timer_count <= timer_count + 1;
                move_timer <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            cursor_x <= 4'd0;
            cursor_y <= 4'd0;
            can_move <= 1'b1;
        end else if (move_timer) begin
            if (can_move) begin
                if (game_state == game_types::PLACEMENT_PHASE) begin
                    // Horizontal ship placement bounds
                    if (orientation == 0) begin
                        if (left_tilt && cursor_x > 0) 
                            cursor_x <= cursor_x - 1'b1;
                        else if (right_tilt && cursor_x < (10 - current_ship_length)) 
                            cursor_x <= cursor_x + 1'b1;
                        else if (up_tilt && cursor_y > 0)
                            cursor_y <= cursor_y - 1'b1;
                        else if (down_tilt && cursor_y < 9)
                            cursor_y <= cursor_y + 1'b1;
                    end 
                    // Vertical ship placement bounds
                    else begin
                        if (left_tilt && cursor_x > 0)
                            cursor_x <= cursor_x - 1'b1;
                        else if (right_tilt && cursor_x < 9)
                            cursor_x <= cursor_x + 1'b1;
                        else if (up_tilt && cursor_y > 0)
                            cursor_y <= cursor_y - 1'b1;
                        else if (down_tilt && cursor_y < (10 - current_ship_length))
                            cursor_y <= cursor_y + 1'b1;
                    end
                end 
                else begin  // Battle phase - normal bounds
                    if (left_tilt && cursor_x > 0)
                        cursor_x <= cursor_x - 1'b1;
                    else if (right_tilt && cursor_x < 9)
                        cursor_x <= cursor_x + 1'b1;
                    else if (up_tilt && cursor_y > 0)
                        cursor_y <= cursor_y - 1'b1;
                    else if (down_tilt && cursor_y < 9)
                        cursor_y <= cursor_y + 1'b1;
                end
                can_move <= 1'b0;
            end else if (~(left_tilt | right_tilt | up_tilt | down_tilt)) begin
                can_move <= 1'b1;
            end
        end
    end

endmodule

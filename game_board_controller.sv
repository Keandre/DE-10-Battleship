module game_board_controller 
import game_types::*;
(
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] cursor_x,
    input  logic [3:0] cursor_y,
    input  logic key0,          
    input  logic key1,          
    output logic [31:0] remaining_ships,
    output logic game_over,
    output board_t player_board,
    output board_t ai_board,
    output board_t ai_ships_pos,
    output logic [2:0] current_ship,    
    output game_state_t game_state,   
    output ships_array_t player_ships,
    output ships_array_t ai_ships,
    output sizes_array_t player_ship_sizes,
    output sizes_array_t ai_ship_sizes,
    output sizes_array_t player_ship_orientations,
    output sizes_array_t ai_ship_orientations,
    output colors_array_t player_ship_colors,
    output colors_array_t ai_ship_colors,
    output logic [3:0] display_ship_length,  
    output logic [3:0] display_orientation,   
    output logic [3:0] debug_controller_length,
    output logic debug_controller_orientation,
    output logic [2:0] preview_ship_counter,   
    output logic [9:0] debug_leds,              
    output logic [3:0] current_ship_length,
    output logic current_ship_orientation
);

    logic last_key0_reg, last_key1_reg;
    logic [3:0] ship_length;
    logic player_turn;
    logic [3:0] ai_target_x, ai_target_y;
    logic ai_attack_valid;
    logic [4:0] try_count;
    logic [4:0] ai_hits;
    logic [4:0] player_hits;
    logic [4:0] placement_tries;
    
    localparam MAX_PLACEMENT_TRIES = 16;
    localparam MAX_MOVES = 100;
    localparam TOTAL_SHIP_CELLS = 17;
    localparam MAX_TRIES = 100;
    
    logic [3:0] ai_placement_x, ai_placement_y;
    logic [3:0] ai_ship_length;
    logic ai_ship_orientation;
    logic [2:0] ai_current_ship;
    logic placement_valid;
    logic [$clog2(MAX_MOVES)-1:0] move_counter;
    logic [31:0] player_remaining_ships;
    logic [7:0] lfsr_x, lfsr_y;
    logic first_battle_move;
    
    typedef enum logic [1:0] {
        WAIT_PRESS,
        PRESSED,
        WAIT_RELEASE
    } key_state_t;
    
    key_state_t key_state;
    logic valid_move;
    logic move_made;
    logic valid_key_press;

    // LFSR implementation
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            lfsr_x <= 8'hAA;
            lfsr_y <= 8'h55;
        end else begin
            lfsr_x <= {lfsr_x[6:0], ~(lfsr_x[7] ^ lfsr_x[5] ^ lfsr_x[4] ^ lfsr_x[3])};
            lfsr_y <= {lfsr_y[6:0], ~(lfsr_y[7] ^ lfsr_y[6] ^ lfsr_y[5] ^ lfsr_y[4])};
        end
    end

    function automatic void select_ai_target;
        logic [3:0] temp_x, temp_y;
        begin
            if (try_count > 16) begin
                temp_x = (try_count[3:0]) % 10;
                temp_y = ((try_count >> 4) + lfsr_y[3:0]) % 10;
            end else begin
                temp_x = (lfsr_x[3:0] + lfsr_y[7:4]) % 10;
                temp_y = (lfsr_y[3:0] + lfsr_x[7:4]) % 10;
            end
            
            ai_attack_valid = (player_board[temp_y][temp_x] != HIT && 
                             player_board[temp_y][temp_x] != MISS);
                             
            if (ai_attack_valid) begin
                ai_target_x = temp_x;
                ai_target_y = temp_y;
            end
        end
    endfunction

    function automatic logic check_game_over;
        logic ships_destroyed;
        logic moves_exceeded;
        
        ships_destroyed = (remaining_ships == 0) || (player_remaining_ships == 0);
        moves_exceeded = (ai_hits >= TOTAL_SHIP_CELLS) || (player_hits >= TOTAL_SHIP_CELLS);
        
        return ships_destroyed || moves_exceeded;
    endfunction

    function logic is_valid_placement(
        input logic [3:0] x,
        input logic [3:0] y,
        input logic [3:0] length,
        input logic [3:0] orientation
    );
        begin
            is_valid_placement = 1'b1;
            
            if (orientation == 0) begin
                if (x + length > 10) is_valid_placement = 1'b0;
                if (y >= 10) is_valid_placement = 1'b0;
            end else begin
                if (y + length > 10) is_valid_placement = 1'b0;
                if (x >= 10) is_valid_placement = 1'b0;
            end
            
            if (is_valid_placement) begin
                for (int i = 0; i < length; i++) begin
                    if (orientation == 0) begin
                        if (player_board[y][x + i] == SHIP) is_valid_placement = 1'b0;
                    end else begin
                        if (player_board[y + i][x] == SHIP) is_valid_placement = 1'b0;
                    end
                end
            end
        end
    endfunction

    function logic is_valid_ai_placement(
        input logic [3:0] x,
        input logic [3:0] y,
        input logic [3:0] length,
        input logic orientation
    );
        begin
            is_valid_ai_placement = 1'b1;
            
            if (orientation == 0) begin
                if (x + length > 10) is_valid_ai_placement = 1'b0;
                if (y >= 10) is_valid_ai_placement = 1'b0;
            end else begin
                if (y + length > 10) is_valid_ai_placement = 1'b0;
                if (x >= 10) is_valid_ai_placement = 1'b0;
            end
            
            if (is_valid_ai_placement) begin
                for (int i = 0; i < length; i++) begin
                    if (orientation == 0) begin
                        if (ai_ships_pos[y][x + i] == SHIP) is_valid_ai_placement = 1'b0;
                    end else begin
                        if (ai_ships_pos[y + i][x] == SHIP) is_valid_ai_placement = 1'b0;
                    end
                end
            end
        end
    endfunction

    task place_ship(
        input logic [3:0] x,
        input logic [3:0] y,
        input logic [3:0] length,
        input logic [3:0] orientation
    );
        begin
            for (int i = 0; i < length; i++) begin
                if (orientation == 0) begin
                    player_board[y][x + i] <= SHIP;
                end else begin
                    player_board[y + i][x] <= SHIP;
                end
            end
            player_ships[current_ship].x <= x;
            player_ships[current_ship].y <= y;
            player_ship_orientations[current_ship] <= orientation;
        end
    endtask

    task place_ai_ship(
        input logic [3:0] x,
        input logic [3:0] y,
        input logic [3:0] length,
        input logic orientation
		  
    );
        begin
            for (int i = 0; i < length; i++) begin
                if (orientation == 0) begin
                    ai_ships_pos[y][x + i] <= SHIP;
                end else begin
                    ai_ships_pos[y + i][x] <= SHIP;
                end
            end
            ai_ships[ai_current_ship].x <= x;
            ai_ships[ai_current_ship].y <= y;
            ai_ship_orientations[ai_current_ship] <= orientation;
        end
    endtask

    // Main state machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            first_battle_move <= 1'b1;
            current_ship_length <= 4'd5;
            current_ship_orientation <= 1'b0;
            game_state <= PLACEMENT_PHASE;
            current_ship <= 3'd0;
            ai_current_ship <= 3'd0;
            ai_ship_length <= 4'd5;
            placement_tries <= 5'd0;
            preview_ship_counter <= 3'd0;
            last_key0_reg <= 1'b1;
            last_key1_reg <= 1'b1;
            move_made <= 1'b0;
            remaining_ships <= TOTAL_SHIP_CELLS;
            player_remaining_ships <= TOTAL_SHIP_CELLS;
            game_over <= 1'b0;
            player_turn <= 1'b1;
            move_counter <= 32'd0;
            try_count <= 5'd0;
            key_state <= WAIT_PRESS;
            valid_move <= 1'b0;
            ai_hits <= 5'd0;
            player_hits <= 5'd0;
            
            player_board <= '{default: '{default: EMPTY}};
            ai_board <= '{default: '{default: EMPTY}};
            ai_ships_pos <= '{default: '{default: EMPTY}};
            
            player_ships <= '{default: '{x: 8'd0, y: 8'd0}};
            ai_ships <= '{default: '{x: 8'd0, y: 8'd0}};
            
            player_ship_sizes[0] <= 4'd5;
            player_ship_sizes[1] <= 4'd4;
            player_ship_sizes[2] <= 4'd3;
            player_ship_sizes[3] <= 4'd3;
            player_ship_sizes[4] <= 4'd2;
            
            for (int i = 0; i < 5; i++) begin
                player_ship_orientations[i] <= 4'd0;
            end
            
            ai_ship_sizes <= player_ship_sizes;
            
            player_ship_colors <= '{
                '{r: 4'd15, g: 4'd0},
                '{r: 4'd0, g: 4'd15},
                '{r: 4'd15, g: 4'd15},
                '{r: 4'd15, g: 4'd0},
                '{r: 4'd0, g: 4'd15}
            };
            ai_ship_colors <= player_ship_colors;
            
            debug_controller_length <= 4'd0;
            debug_controller_orientation <= 1'b0;
            preview_ship_counter <= 3'd0;
        end else begin
            current_ship_length <= player_ship_sizes[current_ship];
            current_ship_orientation <= player_ship_orientations[current_ship];
            debug_controller_length <= player_ship_sizes[current_ship];
            debug_controller_orientation <= player_ship_orientations[current_ship];
            preview_ship_counter <= current_ship;
            
            valid_key_press = last_key0_reg && !key0;
            move_made <= 1'b0;
        
            last_key0_reg <= key0;
            last_key1_reg <= key1;
            
            // Key state machine
            case (key_state)
                WAIT_PRESS: begin
                    if (!key0 && last_key0_reg) begin
                        key_state <= PRESSED;
                        valid_move <= 1'b1;
                    end
                end
                
                PRESSED: begin
                    valid_move <= 1'b0;
                    key_state <= WAIT_RELEASE;
                end
                
                WAIT_RELEASE: begin
                    if (key0 && !last_key0_reg) begin
                        key_state <= WAIT_PRESS;
                    end
                end
                
                default: key_state <= WAIT_PRESS;
            endcase

            // Game state machine
            case (game_state)
                PLACEMENT_PHASE: begin
                    if (!key1 && last_key1_reg) begin
                        player_ship_orientations[current_ship] <= ~player_ship_orientations[current_ship];
                        current_ship_orientation <= ~current_ship_orientation;
                    end
                    
                    if (!key0 && last_key0_reg) begin
                        if (is_valid_placement(cursor_x, cursor_y, 
                            player_ship_sizes[current_ship], 
                            player_ship_orientations[current_ship])) begin
                            
                            place_ship(cursor_x, cursor_y, 
                                player_ship_sizes[current_ship], 
                                player_ship_orientations[current_ship]);
                                
                            if (current_ship == 3'd4) begin
                                game_state <= AI_PLACEMENT_PHASE;
                                ai_current_ship <= 3'd0;
                                placement_tries <= 5'd0;
                            end else begin
                                current_ship <= current_ship + 3'd1;
                            end
                        end
                    end
                end

                AI_PLACEMENT_PHASE: begin
                    if (ai_current_ship < 5) begin
                        ai_ship_length = ai_ship_sizes[ai_current_ship];
                        ai_ship_orientation = lfsr_x[0];
                        
                        ai_placement_x = lfsr_x[3:0] % 10;
                        ai_placement_y = lfsr_y[3:0] % 10;
                        
                        if (is_valid_ai_placement(ai_placement_x, ai_placement_y,
                            ai_ship_length, ai_ship_orientation)) begin
                            place_ai_ship(ai_placement_x, ai_placement_y,
                                ai_ship_length, ai_ship_orientation);
                            ai_current_ship <= ai_current_ship + 1;
                            placement_tries <= 5'd0;
                        end else if (placement_tries < MAX_PLACEMENT_TRIES) begin
                            placement_tries <= placement_tries + 1;
                        end else begin
                            placement_tries <= 5'd0;
                            ai_ship_orientation = ~ai_ship_orientation;
                        end
                    end else begin
                        game_state <= BATTLE_PHASE;
                    end
                end
					BATTLE_PHASE: begin
                    if (!game_over) begin
                        if (first_battle_move) begin
                            first_battle_move <= 1'b0;
                            valid_move <= 1'b0;
                            key_state <= WAIT_PRESS;
                        end else if (player_turn) begin
                            if (valid_move && !move_made && ai_board[cursor_y][cursor_x] == EMPTY) begin
                                if (ai_ships_pos[cursor_y][cursor_x] == SHIP) begin
                                    ai_board[cursor_y][cursor_x] <= HIT;
                                    remaining_ships <= remaining_ships - 1;
                                    player_hits <= player_hits + 1;
                                end else begin
                                    ai_board[cursor_y][cursor_x] <= MISS;
                                end
                                game_over <= check_game_over();
                                move_made <= 1'b1;
                                player_turn <= 1'b0;
                            end
                        end else begin
                            if (!move_made) begin
                                select_ai_target();
                                if (ai_attack_valid) begin
                                    if (player_board[ai_target_y][ai_target_x] == SHIP) begin
                                        player_board[ai_target_y][ai_target_x] <= HIT;
                                        player_remaining_ships <= player_remaining_ships - 1;
                                        ai_hits <= ai_hits + 1;
                                    end else begin
                                        player_board[ai_target_y][ai_target_x] <= MISS;
                                    end
                                    game_over <= check_game_over();
                                    move_made <= 1'b1;
                                    player_turn <= 1'b1;
                                end else if (try_count < MAX_TRIES - 1) begin
                                    try_count <= try_count + 1;
                                end
                            end
                        end
                    end
                end
            endcase
        end
    end

    // Debug LED outputs
    always_comb begin
        debug_leds = 10'b0;
        if (game_state == PLACEMENT_PHASE) begin
            debug_leds[2:0] = current_ship;
            debug_leds[6:3] = player_ship_sizes[current_ship];
            debug_leds[7] = player_ship_orientations[current_ship];
            debug_leds[8] = is_valid_placement(cursor_x, cursor_y, 
                player_ship_sizes[current_ship], 
                player_ship_orientations[current_ship]);
            debug_leds[9] = (key_state == WAIT_PRESS);
        end else begin
            debug_leds[3:0] = remaining_ships[3:0];
            debug_leds[4] = player_turn;
            debug_leds[5] = move_made;
            debug_leds[6] = ai_attack_valid;
            debug_leds[7] = (player_hits > ai_hits);
            debug_leds[8] = game_over;
            debug_leds[9] = (key_state == WAIT_PRESS);
        end
    end

endmodule

package game_types;
    // Game states
    typedef enum logic [2:0] {
		PLACEMENT_PHASE,
		AI_PLACEMENT_PHASE,
		BATTLE_PHASE
	} game_state_t;

    // Board and ship types
    typedef logic [7:0] coord_t;
    
    typedef struct packed {
        coord_t x;
        coord_t y;
    } ship_pos_t;
    
    typedef ship_pos_t [4:0] ships_array_t;
    typedef logic [3:0] size_t;
    typedef size_t [4:0] sizes_array_t;
    typedef logic [3:0] color_t;
    
    typedef struct packed {
        color_t r;
        color_t g;
    } ship_color_t;
    
    typedef ship_color_t [4:0] colors_array_t;
    typedef logic [2:0] cell_t;
    typedef cell_t [9:0][9:0] board_t;

    // Constants
    parameter [2:0] EMPTY = 3'b000;
    parameter [2:0] SHIP = 3'b001;
    parameter [2:0] HIT = 3'b010;
    parameter [2:0] MISS = 3'b011;


    // Display parameters
    parameter GRID_SIZE = 10;                    // 10x10 grid
    parameter CELL_SIZE = 15;                   
    parameter GRID_WIDTH = GRID_SIZE * CELL_SIZE;
    parameter GRID_SPACING = 30;                 
    parameter SCREEN_WIDTH = 640;
    parameter SCREEN_HEIGHT = 480;
    parameter TOTAL_WIDTH = (2 * GRID_WIDTH) + GRID_SPACING;
    parameter LEFT_OFFSET = (SCREEN_WIDTH - TOTAL_WIDTH) / 2;
    parameter TOP_OFFSET = (SCREEN_HEIGHT - GRID_WIDTH) / 2; 

    // Ship information
    parameter int SHIP_LENGTHS [0:4] = '{5, 4, 3, 3, 2};
    parameter string SHIP_NAMES [0:4] = '{"Carrier", "Battleship", "Cruiser", "Submarine", "Destroyer"};
endpackage

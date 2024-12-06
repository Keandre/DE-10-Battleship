module font_rom (
    input  logic [7:0] char,  // ASCII code of the character
    input  logic [2:0] row,   // Row index (0-7)
    input  logic [2:0] col,   // Column index (0-7)
    output logic pixel        // Pixel state (1 or 0)
);

    // Define the font memory: 256 characters * 8 rows per character
    logic [7:0] font_data [0:256*8-1]; 

    initial begin
        integer i;
        // Initialize font_data with default values (all 0s)
        for (i = 0; i < 256*8; i = i + 1) begin
            font_data[i] = 8'b00000000;
        end

        // Uppercase Alphabet (ASCII 65-90)
font_data[65*8 + 0] = 8'b01110000;  // 'A'
font_data[65*8 + 1] = 8'b10001000;
font_data[65*8 + 2] = 8'b10001000;
font_data[65*8 + 3] = 8'b11111000;
font_data[65*8 + 4] = 8'b10001000;
font_data[65*8 + 5] = 8'b10001000;
font_data[65*8 + 6] = 8'b10001000;
font_data[65*8 + 7] = 8'b00000000;

font_data[66*8 + 0] = 8'b11110000;  // 'B'
font_data[66*8 + 1] = 8'b10001000;
font_data[66*8 + 2] = 8'b10001000;
font_data[66*8 + 3] = 8'b11110000;
font_data[66*8 + 4] = 8'b10001000;
font_data[66*8 + 5] = 8'b10001000;
font_data[66*8 + 6] = 8'b11110000;
font_data[66*8 + 7] = 8'b00000000;

font_data[67*8 + 0] = 8'b01110000;  // 'C'
font_data[67*8 + 1] = 8'b10001000;
font_data[67*8 + 2] = 8'b10000000;
font_data[67*8 + 3] = 8'b10000000;
font_data[67*8 + 4] = 8'b10000000;
font_data[67*8 + 5] = 8'b10001000;
font_data[67*8 + 6] = 8'b01110000;
font_data[67*8 + 7] = 8'b00000000;

font_data[68*8 + 0] = 8'b11110000;  // 'D'
font_data[68*8 + 1] = 8'b10001000;
font_data[68*8 + 2] = 8'b10001000;
font_data[68*8 + 3] = 8'b10001000;
font_data[68*8 + 4] = 8'b10001000;
font_data[68*8 + 5] = 8'b10001000;
font_data[68*8 + 6] = 8'b11110000;
font_data[68*8 + 7] = 8'b00000000;

font_data[69*8 + 0] = 8'b11111000;  // 'E'
font_data[69*8 + 1] = 8'b10000000;
font_data[69*8 + 2] = 8'b10000000;
font_data[69*8 + 3] = 8'b11110000;
font_data[69*8 + 4] = 8'b10000000;
font_data[69*8 + 5] = 8'b10000000;
font_data[69*8 + 6] = 8'b11111000;
font_data[69*8 + 7] = 8'b00000000;

font_data[70*8 + 0] = 8'b11111000;  // 'F'
font_data[70*8 + 1] = 8'b10000000;
font_data[70*8 + 2] = 8'b10000000;
font_data[70*8 + 3] = 8'b11110000;
font_data[70*8 + 4] = 8'b10000000;
font_data[70*8 + 5] = 8'b10000000;
font_data[70*8 + 6] = 8'b10000000;
font_data[70*8 + 7] = 8'b00000000;

font_data[71*8 + 0] = 8'b01110000;  // 'G'
font_data[71*8 + 1] = 8'b10001000;
font_data[71*8 + 2] = 8'b10000000;
font_data[71*8 + 3] = 8'b10011000;
font_data[71*8 + 4] = 8'b10001000;
font_data[71*8 + 5] = 8'b10001000;
font_data[71*8 + 6] = 8'b01111000;
font_data[71*8 + 7] = 8'b00000000;

font_data[72*8 + 0] = 8'b10001000;  // 'H'
font_data[72*8 + 1] = 8'b10001000;
font_data[72*8 + 2] = 8'b10001000;
font_data[72*8 + 3] = 8'b11111000;
font_data[72*8 + 4] = 8'b10001000;
font_data[72*8 + 5] = 8'b10001000;
font_data[72*8 + 6] = 8'b10001000;
font_data[72*8 + 7] = 8'b00000000;

font_data[73*8 + 0] = 8'b01110000;  // 'I'
font_data[73*8 + 1] = 8'b00100000;
font_data[73*8 + 2] = 8'b00100000;
font_data[73*8 + 3] = 8'b00100000;
font_data[73*8 + 4] = 8'b00100000;
font_data[73*8 + 5] = 8'b00100000;
font_data[73*8 + 6] = 8'b01110000;
font_data[73*8 + 7] = 8'b00000000;

font_data[74*8 + 0] = 8'b00011000;  // 'J'
font_data[74*8 + 1] = 8'b00001000;
font_data[74*8 + 2] = 8'b00001000;
font_data[74*8 + 3] = 8'b00001000;
font_data[74*8 + 4] = 8'b10001000;
font_data[74*8 + 5] = 8'b10001000;
font_data[74*8 + 6] = 8'b01110000;
font_data[74*8 + 7] = 8'b00000000;

font_data[75*8 + 0] = 8'b10001000;  // 'K'
font_data[75*8 + 1] = 8'b10010000;
font_data[75*8 + 2] = 8'b10100000;
font_data[75*8 + 3] = 8'b11000000;
font_data[75*8 + 4] = 8'b10100000;
font_data[75*8 + 5] = 8'b10010000;
font_data[75*8 + 6] = 8'b10001000;
font_data[75*8 + 7] = 8'b00000000;

font_data[76*8 + 0] = 8'b10000000;  // 'L'
font_data[76*8 + 1] = 8'b10000000;
font_data[76*8 + 2] = 8'b10000000;
font_data[76*8 + 3] = 8'b10000000;
font_data[76*8 + 4] = 8'b10000000;
font_data[76*8 + 5] = 8'b10000000;
font_data[76*8 + 6] = 8'b11111000;
font_data[76*8 + 7] = 8'b00000000;

font_data[77*8 + 0] = 8'b10001000;  // 'M'
font_data[77*8 + 1] = 8'b11011000;
font_data[77*8 + 2] = 8'b10101000;
font_data[77*8 + 3] = 8'b10101000;
font_data[77*8 + 4] = 8'b10101000;
font_data[77*8 + 5] = 8'b10001000;
font_data[77*8 + 6] = 8'b10001000;
font_data[77*8 + 7] = 8'b00000000;

font_data[78*8 + 0] = 8'b10001000;  // 'N'
font_data[78*8 + 1] = 8'b11001000;
font_data[78*8 + 2] = 8'b10101000;
font_data[78*8 + 3] = 8'b10101000;
font_data[78*8 + 4] = 8'b10011000;
font_data[78*8 + 5] = 8'b10001000;
font_data[78*8 + 6] = 8'b10001000;
font_data[78*8 + 7] = 8'b00000000;

font_data[79*8 + 0] = 8'b01110000;  // 'O'
font_data[79*8 + 1] = 8'b10001000;
font_data[79*8 + 2] = 8'b10001000;
font_data[79*8 + 3] = 8'b10001000;
font_data[79*8 + 4] = 8'b10001000;
font_data[79*8 + 5] = 8'b10001000;
font_data[79*8 + 6] = 8'b01110000;
font_data[79*8 + 7] = 8'b00000000;

font_data[80*8 + 0] = 8'b11110000;  // 'P'
font_data[80*8 + 1] = 8'b10001000;
font_data[80*8 + 2] = 8'b10001000;
font_data[80*8 + 3] = 8'b11110000;
font_data[80*8 + 4] = 8'b10000000;
font_data[80*8 + 5] = 8'b10000000;
font_data[80*8 + 6] = 8'b10000000;
font_data[80*8 + 7] = 8'b00000000;

font_data[81*8 + 0] = 8'b01110000;  // 'Q'
font_data[81*8 + 1] = 8'b10001000;
font_data[81*8 + 2] = 8'b10001000;
font_data[81*8 + 3] = 8'b10001000;
font_data[81*8 + 4] = 8'b10101000;
font_data[81*8 + 5] = 8'b10010000;
font_data[81*8 + 6] = 8'b01101000;
font_data[81*8 + 7] = 8'b00000000;

font_data[82*8 + 0] = 8'b11110000;  // 'R'
font_data[82*8 + 1] = 8'b10001000;
font_data[82*8 + 2] = 8'b10001000;
font_data[82*8 + 3] = 8'b11110000;
font_data[82*8 + 4] = 8'b10100000;
font_data[82*8 + 5] = 8'b10010000;
font_data[82*8 + 6] = 8'b10001000;
font_data[82*8 + 7] = 8'b00000000;

font_data[83*8 + 0] = 8'b01111000;  // 'S'
font_data[83*8 + 1] = 8'b10000000;
font_data[83*8 + 2] = 8'b10000000;
font_data[83*8 + 3] = 8'b01110000;
font_data[83*8 + 4] = 8'b00001000;
font_data[83*8 + 5] = 8'b00001000;
font_data[83*8 + 6] = 8'b11110000;
font_data[83*8 + 7] = 8'b00000000;

font_data[84*8 + 0] = 8'b11111000;  // 'T'
font_data[84*8 + 1] = 8'b00100000;
font_data[84*8 + 2] = 8'b00100000;
font_data[84*8 + 3] = 8'b00100000;
font_data[84*8 + 4] = 8'b00100000;
font_data[84*8 + 5] = 8'b00100000;
font_data[84*8 + 6] = 8'b00100000;
font_data[84*8 + 7] = 8'b00000000;

font_data[85*8 + 0] = 8'b10001000;  // 'U'
font_data[85*8 + 1] = 8'b10001000;
font_data[85*8 + 2] = 8'b10001000;
font_data[85*8 + 3] = 8'b10001000;
font_data[85*8 + 4] = 8'b10001000;
font_data[85*8 + 5] = 8'b10001000;
font_data[85*8 + 6] = 8'b01110000;
font_data[85*8 + 7] = 8'b00000000;

font_data[86*8 + 0] = 8'b10001000;  // 'V'
font_data[86*8 + 1] = 8'b10001000;
font_data[86*8 + 2] = 8'b10001000;
font_data[86*8 + 3] = 8'b10001000;
font_data[86*8 + 4] = 8'b10001000;
font_data[86*8 + 5] = 8'b01010000;
font_data[86*8 + 6] = 8'b00100000;
font_data[86*8 + 7] = 8'b00000000;

font_data[87*8 + 0] = 8'b10001000;  // 'W'
font_data[87*8 + 1] = 8'b10001000;
font_data[87*8 + 2] = 8'b10001000;
font_data[87*8 + 3] = 8'b10101000;
font_data[87*8 + 4] = 8'b10101000;
font_data[87*8 + 5] = 8'b10101000;
font_data[87*8 + 6] = 8'b01010000;
font_data[87*8 + 7] = 8'b00000000;

font_data[88*8 + 0] = 8'b10001000;  // 'X'
font_data[88*8 + 1] = 8'b10001000;
font_data[88*8 + 2] = 8'b01010000;
font_data[88*8 + 3] = 8'b00100000;
font_data[88*8 + 4] = 8'b00100000;
font_data[88*8 + 5] = 8'b01010000;
font_data[88*8 + 6] = 8'b10001000;
font_data[88*8 + 7] = 8'b00000000;

font_data[89*8 + 0] = 8'b10001000;  // 'Y'
font_data[89*8 + 1] = 8'b10001000;
font_data[89*8 + 2] = 8'b01010000;
font_data[89*8 + 3] = 8'b00100000;
font_data[89*8 + 4] = 8'b00100000;
font_data[89*8 + 5] = 8'b00100000;
font_data[89*8 + 6] = 8'b00100000;
font_data[89*8 + 7] = 8'b00000000;

font_data[90*8 + 0] = 8'b11111000;  // 'Z'
font_data[90*8 + 1] = 8'b00001000;
font_data[90*8 + 2] = 8'b00010000;
font_data[90*8 + 3] = 8'b00100000;
font_data[90*8 + 4] = 8'b01000000;
font_data[90*8 + 5] = 8'b10000000;
font_data[90*8 + 6] = 8'b11111000;
font_data[90*8 + 7] = 8'b00000000;

// Lowercase Alphabet (ASCII 97-122)
font_data[97*8 + 0] = 8'b00000000;  // 'a'
font_data[97*8 + 1] = 8'b00000000;
font_data[97*8 + 2] = 8'b01110000;
font_data[97*8 + 3] = 8'b00001000;
font_data[97*8 + 4] = 8'b01111000;
font_data[97*8 + 5] = 8'b10001000;
font_data[97*8 + 6] = 8'b01111000;
font_data[97*8 + 7] = 8'b00000000;

font_data[98*8 + 0] = 8'b10000000;  // 'b'
font_data[98*8 + 1] = 8'b10000000;
font_data[98*8 + 2] = 8'b11110000;
font_data[98*8 + 3] = 8'b10001000;
font_data[98*8 + 4] = 8'b10001000;
font_data[98*8 + 5] = 8'b10001000;
font_data[98*8 + 6] = 8'b11110000;
font_data[98*8 + 7] = 8'b00000000;

font_data[99*8 + 0] = 8'b00000000;  // 'c'
font_data[99*8 + 1] = 8'b00000000;
font_data[99*8 + 2] = 8'b01110000;
font_data[99*8 + 3] = 8'b10001000;
font_data[99*8 + 4] = 8'b10000000;
font_data[99*8 + 5] = 8'b10001000;
font_data[99*8 + 6] = 8'b01110000;
font_data[99*8 + 7] = 8'b00000000;

font_data[100*8 + 0] = 8'b00001000;  // 'd'
font_data[100*8 + 1] = 8'b00001000;
font_data[100*8 + 2] = 8'b01111000;
font_data[100*8 + 3] = 8'b10001000;
font_data[100*8 + 4] = 8'b10001000;
font_data[100*8 + 5] = 8'b10001000;
font_data[100*8 + 6] = 8'b01111000;
font_data[100*8 + 7] = 8'b00000000;

font_data[101*8 + 0] = 8'b00000000;  // 'e'
font_data[101*8 + 1] = 8'b00000000;
font_data[101*8 + 2] = 8'b01110000;
font_data[101*8 + 3] = 8'b10001000;
font_data[101*8 + 4] = 8'b11111000;
font_data[101*8 + 5] = 8'b10000000;
font_data[101*8 + 6] = 8'b01110000;
font_data[101*8 + 7] = 8'b00000000;

font_data[102*8 + 0] = 8'b00111000;  // 'f'
font_data[102*8 + 1] = 8'b01000000;
font_data[102*8 + 2] = 8'b01000000;
font_data[102*8 + 3] = 8'b11100000;
font_data[102*8 + 4] = 8'b01000000;
font_data[102*8 + 5] = 8'b01000000;
font_data[102*8 + 6] = 8'b01000000;
font_data[102*8 + 7] = 8'b00000000;

font_data[103*8 + 0] = 8'b00000000;  // 'g'
font_data[103*8 + 1] = 8'b01111000;
font_data[103*8 + 2] = 8'b10001000;
font_data[103*8 + 3] = 8'b10001000;
font_data[103*8 + 4] = 8'b01111000;
font_data[103*8 + 5] = 8'b00001000;
font_data[103*8 + 6] = 8'b01110000;
font_data[103*8 + 7] = 8'b00000000;

font_data[104*8 + 0] = 8'b10000000;  // 'h'
font_data[104*8 + 1] = 8'b10000000;
font_data[104*8 + 2] = 8'b11110000;
font_data[104*8 + 3] = 8'b10001000;
font_data[104*8 + 4] = 8'b10001000;
font_data[104*8 + 5] = 8'b10001000;
font_data[104*8 + 6] = 8'b10001000;
font_data[104*8 + 7] = 8'b00000000;

font_data[105*8 + 0] = 8'b00100000;  // 'i'
font_data[105*8 + 1] = 8'b00000000;
font_data[105*8 + 2] = 8'b01100000;
font_data[105*8 + 3] = 8'b00100000;
font_data[105*8 + 4] = 8'b00100000;
font_data[105*8 + 5] = 8'b00100000;
font_data[105*8 + 6] = 8'b01110000;
font_data[105*8 + 7] = 8'b00000000;

font_data[106*8 + 0] = 8'b00010000;  // 'j'
font_data[106*8 + 1] = 8'b00000000;
font_data[106*8 + 2] = 8'b00110000;
font_data[106*8 + 3] = 8'b00010000;
font_data[106*8 + 4] = 8'b00010000;
font_data[106*8 + 5] = 8'b10010000;
font_data[106*8 + 6] = 8'b10010000;
font_data[106*8 + 7] = 8'b01100000;

font_data[107*8 + 0] = 8'b10000000;  // 'k'
font_data[107*8 + 1] = 8'b10000000;
font_data[107*8 + 2] = 8'b10010000;
font_data[107*8 + 3] = 8'b10100000;
font_data[107*8 + 4] = 8'b11000000;
font_data[107*8 + 5] = 8'b10100000;
font_data[107*8 + 6] = 8'b10010000;
font_data[107*8 + 7] = 8'b00000000;

font_data[108*8 + 0] = 8'b01100000;  // 'l'
font_data[108*8 + 1] = 8'b00100000;
font_data[108*8 + 2] = 8'b00100000;
font_data[108*8 + 3] = 8'b00100000;
font_data[108*8 + 4] = 8'b00100000;
font_data[108*8 + 5] = 8'b00100000;
font_data[108*8 + 6] = 8'b01110000;
font_data[108*8 + 7] = 8'b00000000;

font_data[109*8 + 0] = 8'b00000000;  // 'm'
font_data[109*8 + 1] = 8'b00000000;
font_data[109*8 + 2] = 8'b11010000;
font_data[109*8 + 3] = 8'b10101000;
font_data[109*8 + 4] = 8'b10101000;
font_data[109*8 + 5] = 8'b10101000;
font_data[109*8 + 6] = 8'b10101000;
font_data[109*8 + 7] = 8'b00000000;

font_data[110*8 + 0] = 8'b00000000;  // 'n'
font_data[110*8 + 1] = 8'b00000000;
font_data[110*8 + 2] = 8'b11110000;
font_data[110*8 + 3] = 8'b10001000;
font_data[110*8 + 4] = 8'b10001000;
font_data[110*8 + 5] = 8'b10001000;
font_data[110*8 + 6] = 8'b10001000;
font_data[110*8 + 7] = 8'b00000000;

font_data[111*8 + 0] = 8'b00000000;  // 'o'
font_data[111*8 + 1] = 8'b00000000;
font_data[111*8 + 2] = 8'b01110000;
font_data[111*8 + 3] = 8'b10001000;
font_data[111*8 + 4] = 8'b10001000;
font_data[111*8 + 5] = 8'b10001000;
font_data[111*8 + 6] = 8'b01110000;
font_data[111*8 + 7] = 8'b00000000;

font_data[112*8 + 0] = 8'b00000000;  // 'p'
font_data[112*8 + 1] = 8'b00000000;
font_data[112*8 + 2] = 8'b11110000;
font_data[112*8 + 3] = 8'b10001000;
font_data[112*8 + 4] = 8'b10001000;
font_data[112*8 + 5] = 8'b11110000;
font_data[112*8 + 6] = 8'b10000000;
font_data[112*8 + 7] = 8'b10000000;

font_data[113*8 + 0] = 8'b00000000;  // 'q'
font_data[113*8 + 1] = 8'b00000000;
font_data[113*8 + 2] = 8'b01111000;
font_data[113*8 + 3] = 8'b10001000;
font_data[113*8 + 4] = 8'b10001000;
font_data[113*8 + 5] = 8'b01111000;
font_data[113*8 + 6] = 8'b00001000;
font_data[113*8 + 7] = 8'b00001000;

font_data[114*8 + 0] = 8'b00000000;  // 'r'
font_data[114*8 + 1] = 8'b00000000;
font_data[114*8 + 2] = 8'b10110000;
font_data[114*8 + 3] = 8'b11001000;
font_data[114*8 + 4] = 8'b10000000;
font_data[114*8 + 5] = 8'b10000000;
font_data[114*8 + 6] = 8'b10000000;
font_data[114*8 + 7] = 8'b00000000;

font_data[115*8 + 0] = 8'b00000000;  // 's'
font_data[115*8 + 1] = 8'b00000000;
font_data[115*8 + 2] = 8'b01111000;
font_data[115*8 + 3] = 8'b10000000;
font_data[115*8 + 4] = 8'b01110000;
font_data[115*8 + 5] = 8'b00001000;
font_data[115*8 + 6] = 8'b11110000;
font_data[115*8 + 7] = 8'b00000000;

font_data[116*8 + 0] = 8'b01000000;  // 't'
font_data[116*8 + 1] = 8'b01000000;
font_data[116*8 + 2] = 8'b11100000;
font_data[116*8 + 3] = 8'b01000000;
font_data[116*8 + 4] = 8'b01000000;
font_data[116*8 + 5] = 8'b01000000;
font_data[116*8 + 6] = 8'b00111000;
font_data[116*8 + 7] = 8'b00000000;

font_data[117*8 + 0] = 8'b00000000;  // 'u'
font_data[117*8 + 1] = 8'b00000000;
font_data[117*8 + 2] = 8'b10001000;
font_data[117*8 + 3] = 8'b10001000;
font_data[117*8 + 4] = 8'b10001000;
font_data[117*8 + 5] = 8'b10001000;
font_data[117*8 + 6] = 8'b01111000;
font_data[117*8 + 7] = 8'b00000000;

font_data[118*8 + 0] = 8'b00000000;  // 'v'
font_data[118*8 + 1] = 8'b00000000;
font_data[118*8 + 2] = 8'b10001000;
font_data[118*8 + 3] = 8'b10001000;
font_data[118*8 + 4] = 8'b10001000;
font_data[118*8 + 5] = 8'b01010000;
font_data[118*8 + 6] = 8'b00100000;
font_data[118*8 + 7] = 8'b00000000;

font_data[119*8 + 0] = 8'b00000000;  // 'w'
font_data[119*8 + 1] = 8'b00000000;
font_data[119*8 + 2] = 8'b10001000;
font_data[119*8 + 3] = 8'b10001000;
font_data[119*8 + 4] = 8'b10101000;
font_data[119*8 + 5] = 8'b10101000;
font_data[119*8 + 6] = 8'b01010000;
font_data[119*8 + 7] = 8'b00000000;

font_data[120*8 + 0] = 8'b00000000;  // 'x'
font_data[120*8 + 1] = 8'b00000000;
font_data[120*8 + 2] = 8'b10001000;
font_data[120*8 + 3] = 8'b01010000;
font_data[120*8 + 4] = 8'b00100000;
font_data[120*8 + 5] = 8'b01010000;
font_data[120*8 + 6] = 8'b10001000;
font_data[120*8 + 7] = 8'b00000000;

font_data[121*8 + 0] = 8'b00000000;  // 'y'
font_data[121*8 + 1] = 8'b00000000;
font_data[121*8 + 2] = 8'b10001000;
font_data[121*8 + 3] = 8'b10001000;
font_data[121*8 + 4] = 8'b01111000;
font_data[121*8 + 5] = 8'b00001000;
font_data[121*8 + 6] = 8'b01110000;
font_data[121*8 + 7] = 8'b00000000;

font_data[122*8 + 0] = 8'b00000000;  // 'z'
font_data[122*8 + 1] = 8'b00000000;
font_data[122*8 + 2] = 8'b11111000;
font_data[122*8 + 3] = 8'b00010000;
font_data[122*8 + 4] = 8'b00100000;
font_data[122*8 + 5] = 8'b01000000;
font_data[122*8 + 6] = 8'b11111000;
font_data[122*8 + 7] = 8'b00000000;

// Period (ASCII 46)
font_data[46*8 + 0] = 8'b00000000;  // '.'
font_data[46*8 + 1] = 8'b00000000;
font_data[46*8 + 2] = 8'b00000000;
font_data[46*8 + 3] = 8'b00000000;
font_data[46*8 + 4] = 8'b00000000;
font_data[46*8 + 5] = 8'b00000000;
font_data[46*8 + 6] = 8'b01100000;
font_data[46*8 + 7] = 8'b01100000;

// Open Parenthesis (ASCII 40)
font_data[40*8 + 0] = 8'b00011000;  // '('
font_data[40*8 + 1] = 8'b00100000;
font_data[40*8 + 2] = 8'b01000000;
font_data[40*8 + 3] = 8'b01000000;
font_data[40*8 + 4] = 8'b01000000;
font_data[40*8 + 5] = 8'b01000000;
font_data[40*8 + 6] = 8'b00100000;
font_data[40*8 + 7] = 8'b00011000;

// Close Parenthesis (ASCII 41)
font_data[41*8 + 0] = 8'b01100000;  // ')'
font_data[41*8 + 1] = 8'b00010000;
font_data[41*8 + 2] = 8'b00001000;
font_data[41*8 + 3] = 8'b00001000;
font_data[41*8 + 4] = 8'b00001000;
font_data[41*8 + 5] = 8'b00001000;
font_data[41*8 + 6] = 8'b00010000;
font_data[41*8 + 7] = 8'b01100000;

// Comma (ASCII 44)
font_data[44*8 + 0] = 8'b00000000;  // ','
font_data[44*8 + 1] = 8'b00000000;
font_data[44*8 + 2] = 8'b00000000;
font_data[44*8 + 3] = 8'b00000000;
font_data[44*8 + 4] = 8'b00000000;
font_data[44*8 + 5] = 8'b01100000;
font_data[44*8 + 6] = 8'b01100000;
font_data[44*8 + 7] = 8'b00100000;

// Colon (ASCII 58)
font_data[58*8 + 0] = 8'b00000000;  // ':'
font_data[58*8 + 1] = 8'b00000000;
font_data[58*8 + 2] = 8'b01100000;
font_data[58*8 + 3] = 8'b01100000;
font_data[58*8 + 4] = 8'b00000000;
font_data[58*8 + 5] = 8'b01100000;
font_data[58*8 + 6] = 8'b01100000;
font_data[58*8 + 7] = 8'b00000000;

// Slash (ASCII 47)
font_data[47*8 + 0] = 8'b00001000;  // '/'
font_data[47*8 + 1] = 8'b00010000;
font_data[47*8 + 2] = 8'b00010000;
font_data[47*8 + 3] = 8'b00100000;
font_data[47*8 + 4] = 8'b00100000;
font_data[47*8 + 5] = 8'b01000000;
font_data[47*8 + 6] = 8'b01000000;
font_data[47*8 + 7] = 8'b10000000;

// Quotation Marks (ASCII 34)
font_data[34*8 + 0] = 8'b01010000;  // '"'
font_data[34*8 + 1] = 8'b01010000;
font_data[34*8 + 2] = 8'b00100000;
font_data[34*8 + 3] = 8'b00000000;
font_data[34*8 + 4] = 8'b00000000;
font_data[34*8 + 5] = 8'b00000000;
font_data[34*8 + 6] = 8'b00000000;
font_data[34*8 + 7] = 8'b00000000;

// Question Mark (ASCII 63)
font_data[63*8 + 0] = 8'b01110000;  // '?'
font_data[63*8 + 1] = 8'b10001000;
font_data[63*8 + 2] = 8'b00001000;
font_data[63*8 + 3] = 8'b00010000;
font_data[63*8 + 4] = 8'b00100000;
font_data[63*8 + 5] = 8'b00000000;
font_data[63*8 + 6] = 8'b00100000;
font_data[63*8 + 7] = 8'b00000000;

// Exclamation Mark (ASCII 33)
font_data[33*8 + 0] = 8'b00100000;  // '!'
font_data[33*8 + 1] = 8'b00100000;
font_data[33*8 + 2] = 8'b00100000;
font_data[33*8 + 3] = 8'b00100000;
font_data[33*8 + 4] = 8'b00100000;
font_data[33*8 + 5] = 8'b00000000;
font_data[33*8 + 6] = 8'b00100000;
font_data[33*8 + 7] = 8'b00000000;



    end
	 
    logic [7:0] row_data;
    assign row_data = font_data[char * 8 + row];
    assign pixel = row_data[7 - col]; // Leftmost bit is the highest bit

endmodule

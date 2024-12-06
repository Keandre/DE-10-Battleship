// Original digital sound detector
module sound_detector (
    input logic clk,
    input logic reset_n,
    input logic sound_signal,    // Digital input from microphone module
    output logic [9:0] LEDR,     // Output to LEDs
    output logic debug_raw_signal,
    output logic [7:0] debug_counter
);
    // Debug counter for signal monitoring
    logic [7:0] signal_counter;
    logic sound_detected;

    always_ff @(posedge clk) begin
        if (~reset_n) begin
            signal_counter <= '0;
            sound_detected <= 1'b0;
        end else begin
            // Count signal transitions for debugging
            if (sound_signal != debug_raw_signal) begin
                signal_counter <= signal_counter + 1;
            end
            
            // Direct signal detection
            sound_detected <= sound_signal;
        end
    end
    
    assign debug_raw_signal = sound_signal;
    assign debug_counter = signal_counter;

    always_comb begin
        LEDR = sound_detected ? 10'b1111111111 : 10'b0000000000;		  
    end
endmodule
module POR #(parameter RESET_TIME = 1000000) (
    input logic clk,
    output logic reset_n
);
    logic [31:0] counter;

    initial begin
        counter  = 0;
        reset_n  = 0;  // Assert reset
    end

    always_ff @(posedge clk) begin
        if (counter < RESET_TIME) begin
            counter <= counter + 1;
            reset_n <= 0;  // Keep reset active
        end else begin
            reset_n <= 1;  // Deactivate reset
        end
    end
endmodule

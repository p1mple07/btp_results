module moving_average(
    input clk,
    input reset,
    input [11:0] data_in,
    output reg [11:0] data_out
);

    // Internal registers
    reg [31:0] sum_reg; // 32-bit to handle 12-bit input sum
    reg [7:0] buffer[7:0]; // Memory buffer for 8 samples
    integer i;

    // State variable for edge conditions
    reg edge_detected;

    // Reset condition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum_reg <= 0;
            buffer <= {8'b0};
            data_out <= 12'b0;
            edge_detected <= 0;
        end else if (posedge reset) begin
            sum_reg <= 0;
            buffer <= {8'b0};
            data_out <= 12'b0;
            edge_detected <= 0;
        end else begin
            if (!edge_detected) begin
                edge_detected <= 1;
                buffer[7] <= data_in;
            end else begin
                buffer <= {buffer[6:0], data_in};
                sum_reg <= sum_reg + buffer[7];
                data_out <= sum_reg / 8;
                edge_detected <= 0;
            end
        end
    end

endmodule

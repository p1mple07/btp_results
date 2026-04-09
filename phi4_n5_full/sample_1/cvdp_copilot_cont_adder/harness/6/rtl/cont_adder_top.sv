module continuous_adder #(
    parameter DATA_WIDTH    = 32,
    parameter THRESHOLD_VALUE = 100,
    parameter SIGNED_INPUTS = 1  // 1: signed arithmetic, 0: unsigned arithmetic
)(
    input  logic         clk,
    input  logic         reset,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic         data_valid,
    output logic [DATA_WIDTH-1:0] sum_out,
    output logic         sum_ready
);

    // Internal accumulator
    logic [DATA_WIDTH-1:0] sum_accum;

    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum   <= '0;
            sum_ready   <= 1'b0;
        end
        else if (data_valid) begin
            // Compute the new accumulated sum
            if (SIGNED_INPUTS) begin
                // When using signed arithmetic, cast the operands to signed
                logic [DATA_WIDTH-1:0] new_sum;
                new_sum = $signed(sum_accum) + $signed(data_in);
                // For signed data, trigger output if the new sum is >= THRESHOLD_VALUE
                // or <= -THRESHOLD_VALUE
                if ((new_sum >= THRESHOLD_VALUE) || (new_sum <= -THRESHOLD_VALUE)) begin
                    sum_out   <= new_sum;
                    sum_ready <= 1'b1;
                    sum_accum <= '0;
                end
                else begin
                    sum_ready <= 1'b0;
                    sum_accum <= new_sum;
                end
            end
            else begin
                // Unsigned arithmetic: simply add the values
                logic [DATA_WIDTH-1:0] new_sum;
                new_sum = sum_accum + data_in;
                if (new_sum >= THRESHOLD_VALUE) begin
                    sum_out   <= new_sum;
                    sum_ready <= 1'b1;
                    sum_accum <= '0;
                end
                else begin
                    sum_ready <= 1'b0;
                    sum_accum <= new_sum;
                end
            end
        end
    end

endmodule
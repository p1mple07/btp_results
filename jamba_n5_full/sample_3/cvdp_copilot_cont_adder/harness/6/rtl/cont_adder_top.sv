module continuous_adder (
    input logic         clk,
    input logic         reset,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic         data_valid,
    output logic [7:0]  sum_out,
    output logic        sum_ready
);

    logic [DATA_WIDTH-1:0] sum_accum;
    bit signed_flag;

    initial begin
        sum_accum <= 8'd0;
        signed_flag <= signed_input;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum <= 8'd0;
            sum_ready <= 1'b0;
        end else begin
            if (data_valid) begin
                if (signed_flag) begin
                    sum_accum = signed_add(sum_accum, data_in);
                    if (sum_accum >= THRESHOLD_VALUE) begin
                        sum_out = sum_accum + data_in;
                        sum_ready <= 1'b1;
                        sum_accum <= 8'd0;
                    end else if (sum_accum <= -THRESHOLD_VALUE) begin
                        sum_out = sum_accum - data_in;
                        sum_ready <= 1'b1;
                        sum_accum <= 8'd0;
                    end
                end else
                    sum_accum = unsigned_add(sum_accum, data_in);
                    if (sum_accum >= THRESHOLD_VALUE) begin
                        sum_out = sum_accum + data_in;
                        sum_ready <= 1'b1;
                    end else if (sum_accum <= -THRESHOLD_VALUE) begin
                        sum_out = sum_accum - data_in;
                        sum_ready <= 1'b1;
                    end
            end
        end
    end

endmodule

// Helper functions
function bit signed_add(bit signed_flag, bit sum_accum, bit data_in);
    if (signed_flag) begin
        return signed_add_signed(sum_accum, data_in);
    end else
        return signed_add_unsigned(sum_accum, data_in);

function bit signed_add_signed(bit signed_flag, bit sum_accum, bit data_in);
    if (signed_flag) begin
        return sum_accum + data_in;
    end else
        return sum_accum - data_in;

function bit signed_add_unsigned(bit signed_flag, bit sum_accum, bit data_in);
    if (signed_flag) begin
        return sum_accum + data_in;
    end else
        return sum_accum - data_in;

endmodule

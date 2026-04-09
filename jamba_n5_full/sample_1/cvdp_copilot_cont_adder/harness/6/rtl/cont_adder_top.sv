module continuous_adder (
    input logic         clk,
    input logic         reset,
    input logic [7:0]   data_in,
    input logic         data_valid,
    output logic [7:0]  sum_out,
    output logic        sum_ready
);

    localparam integer DATA_WIDTH = 8;
    localparam integer THRESHOLD_VALUE = 100;
    localparam boolean SIGNED_INPUTS = 1;

    logic [7:0] sum_accum;
    logic sum_ready;

    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum <= 8'd0;
            sum_ready <= 1'b0;
        end else begin
            if (data_valid) begin
                if (SIGNED_INPUTS) begin
                    sum_accum <= sum_accum + data_in;

                    if (sum_accum >= THRESHOLD_VALUE) or (sum_accum <= -THRESHOLD_VALUE) begin
                        sum_out <= sum_accum + data_in;
                        sum_ready <= 1'b1;
                    end else begin
                        sum_ready <= 1'b0;
                    end
                end
                else begin
                    if (sum_accum + data_in >= 8'd100) begin
                        sum_out <= sum_accum + data_in;
                        sum_ready <= 1'b1;
                    end else begin
                        sum_ready <= 1'b0;
                    end
                end
            end
        end
    end

endmodule

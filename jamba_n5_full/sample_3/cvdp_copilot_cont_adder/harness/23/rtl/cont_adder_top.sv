module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE_1 = 50,
    parameter THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
    parameter WEIGHT = 1,
    parameter window_size = 5
) (
    input logic          clk,
    input logic          reset,
    input logic signed   [DATA_WIDTH-1:0] data_in,
    input logic          data_valid,
    output logic signed  [DATA_WIDTH-1:0] sum_out,
    output logic         sum_ready,
    output logic         threshold_1,
    output logic         threshold_2,
    output logic         sum_out_after_reset,
    output logic         avg_out
);

reg signed [DATA_WIDTH-1:0] sum_accum;
reg signed [DATA_WIDTH-1:0] weighted_input;
reg signed [DATA_WIDTH-1:0] sample_count;
reg signed [15:0] window_size;

always_ff @(posedge clk) begin
    if (reset) begin
        sum_accum         <= {DATA_WIDTH{1'b0}};
        sum_ready         <= 1'b0;
        sum_out           <= {DATA_WIDTH{1'b0}};
        threshold_1       <= 0;
        threshold_2       <= 0;
        sum_out_after_reset <= 1'b0;
        avg_out           <= 0;
        sample_count      <= 0;
        window_size       <= 0;
    end else begin
        if (data_valid) begin
            weighted_input <= data_in * WEIGHT;
            sum_accum     <= sum_accum + weighted_input;

            // Detect positive threshold
            if (SIGNED_INPUTS && (sum_accum + data_in >= THRESHOLD_VALUE_1)) begin
                if (sum_accum >= THRESHOLD_VALUE_1) begin
                    sum_ready <= 1'b1;
                    sum_out   <= sum_accum + data_in;
                    sum_accum <= {DATA_WIDTH{1'b0}};
                end else begin
                    sum_ready <= 1'b0;
                end
            end
            // Detect negative threshold
            else if (SIGNED_INPUTS && (sum_accum + data_in <= -1*THRESHOLD_VALUE_1)) begin
                if (sum_accum >= THRESHOLD_VALUE_2) begin
                    sum_ready <= 1'b1;
                    sum_out   <= sum_accum + data_in;
                    sum_accum <= {DATA_WIDTH{1'b0}};
                end else begin
                    sum_ready <= 1'b0;
                end
            end
            // Detect positive threshold
            else if (SIGNED_INPUTS && (sum_accum + data_in >= THRESHOLD_VALUE_2)) begin
                if (sum_accum >= THRESHOLD_VALUE_2) begin
                    sum_ready <= 1'b1;
                    sum_out   <= sum_accum + data_in;
                    sum_accum <= {DATA_WIDTH{1'b0}};
                end else begin
                    sum_ready <= 1'b0;
                end
            end
            // Detect negative threshold
            else if (SIGNED_INPUTS && (sum_accum + data_in <= -1*THRESHOLD_VALUE_2)) begin
                if (sum_accum >= THRESHOLD_VALUE_2) begin
                    sum_ready <= 1'b1;
                    sum_out   <= sum_accum + data_in;
                    sum_accum <= {DATA_WIDTH{1'b0}};
                end else begin
                    sum_ready <= 1'b0;
                end
            end
        end
    end
end @(posedge clk);

assign sum_out_after_reset = sum_ready;
assign avg_out = (sample_count == window_size) ? sum_accum / window_size : 0;

endmodule

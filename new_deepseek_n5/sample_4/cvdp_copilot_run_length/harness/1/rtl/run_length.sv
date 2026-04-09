module run_length
#(
    parameter DATA_WIDTH = 8
)
(
    input wire clk,
    input wire reset_n,
    input wire data_in,
    output reg data_out,
    output reg [$clog2(DATA_WIDTH):0] run_value,
    output reg valid
);
    reg [$clog2(DATA_WIDTH):0] run_length;
    reg prev_data_in;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length <= 'b0;
            run_value <= 'b0;
            prev_data_in <= 1'b0;
            valid <= 1'b0;
            data_out <= 1'b0;
        end
        else begin
            if (data_in == prev_data_in) begin
                run_length <= run_length + 1;
            end else begin
                run_length <= 1;
                run_value <= run_length;
                data_out <= prev_data_in;
                valid <= 1'b1;
            end
            if (run_length == DATA_WIDTH) begin
                valid <= 1'b1;
                run_value <= DATA_WIDTH;
            end
            else if (!reset_n) begin
                run_length <= 'b0;
                run_value <= 'b0;
                prev_data_in <= data_in;
            end
        end
    end
endmodule
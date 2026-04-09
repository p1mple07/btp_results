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
)
    reg [$clog2(DATA_WIDTH):0] run_length;
    reg prev_data_in;

    always @posedge (clk or reset_n) begin
        if (!reset_n) begin
            run_length <= 0;
            run_value <= 0;
            prev_data_in <= data_in;
            valid <= 0;
            data_out <= 0;
        else begin
            if (data_in != prev_data_in) begin
                valid <= 1;
                data_out <= prev_data_in;
                run_value <= run_length;
                run_length <= 0;
                prev_data_in <= data_in;
            else begin
                run_length <= run_length + 1;
                data_out <= data_out;
            end
        end
    end
end
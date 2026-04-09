module run_length
#(
    parameter DATA_WIDTH = 8
)
(
    input wire clk, 
    input wire reset_n, 
    input wire data_in, 
    output reg  data_out, 
    output reg run_value, 
    output valid, 
    output run_length
);

reg [$clog2(DATA_WIDTH):0] run_length;
reg prev_data_in;

always @posedge clk or negedge reset_n
begin
    if (!reset_n) begin
        run_length <= 0;
        run_value <= 0;
        prev_data_in <= 0;
        valid <= 0;
    else begin
        if (data_in == prev_data_in) begin
            run_length <= run_length + 1;
            if (run_length == DATA_WIDTH) begin
                valid <= 1;
                data_out <= prev_data_in;
                run_value <= run_length;
                run_length <= 1;
                valid <= 0;  // Reset valid to 0 after run completes
            end
        else begin
            run_value <= run_length;
            run_length <= 1;
            valid <= 1;
            data_out <= prev_data_in;
        end
    end
end
module run_length
#(
    parameter DATA_WIDTH = 8
)
(
    input wire clk,                                 // Clock signal      
    input wire reset_n,                             // Active-low reset signal     
    input wire data_in,                             // Input data stream
    output reg  data_out,                           // Output data to indicate the previous data_in
    output reg [$clog2(DATA_WIDTH):0] run_value,    // Output the run length value 
    output reg valid                                // Output valid flag for run length 
);
    reg [$clog2(DATA_WIDTH):0] run_length;
    reg prev_data_in;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length   <= 'b0;
            run_value    <= 'b0;
            prev_data_in <= 1'b0;
        end
        else begin
            if (data_in == prev_data_in) begin
                run_length <= run_length + 1;
                if (run_length == DATA_WIDTH) begin
                    valid <= 1;
                    data_out <= prev_data_in;
                    run_length <= 0;
                end
            else begin
                run_length <= 1;
                prev_data_in <= data_in;
                valid <= 0;
            end
        end
    end
end
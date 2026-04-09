module run_length
#(
    parameter DATA_WIDTH = 8                        // Width of the output run-length counter
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
            valid        <= 1'b0;
            data_out     <= 1'b0;
        end else begin
            prev_data_in <= data_in;
            run_length    <= 0;
            run_value     <= 1'b0;
            valid         <= 1'b0;
            data_out      <= prev_data_in;

            if (data_in != prev_data_in) begin
                run_length <= run_length + 1;
                if (run_length == (1 << DATA_WIDTH) - 1) begin
                    run_value <= run_length;
                    run_length <= 0;
                    valid <= 1'b1;
                end
            end
        end
    end
endmodule

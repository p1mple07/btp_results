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
        end
        else begin
            // Run-length calculation
            if (data_in == prev_data_in) begin
                if (run_length < DATA_WIDTH) begin
                    run_length <= run_length + 1'b1;
                end
            end
            else begin
                run_length <= 1'b1;
            end

            // Saturation handling
            if (run_length >= DATA_WIDTH) begin
                run_length <= DATA_WIDTH - 1;
            }

            // Output control
            if (data_in!= prev_data_in) begin
                data_out <= prev_data_in;
            }

            // Valid flag
            if ((run_length == DATA_WIDTH) && (data_in == prev_data_in)) begin
                valid <= 1'b1;
            end
            else begin
                valid <= 1'b0;
            end

            // Reset run length and data out
            if (reset_n == 1'b0) begin
                run_length <= 'b0;
                data_out <= 'b0;
            end

            // Store previous data input
            prev_data_in <= data_in;
        end
    end
endmodule
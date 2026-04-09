module run_length
#(
    parameter DATA_WIDTH = 8                        // Width of the output run-length counter
)
(
    input  wire         clk,                        // Clock signal      
    input  wire         reset_n,                    // Active-low reset signal     
    input  wire         data_in,                    // Input data stream
    output reg          data_out,                   // Output data to indicate the previous data_in
    output reg [$clog2(DATA_WIDTH):0] run_value,     // Output the run length value 
    output reg          valid                       // Output valid flag for run length 
);

    // Internal registers
    reg [$clog2(DATA_WIDTH):0] run_length;
    reg                         prev_data_in;

    //----------------------------------------------------------------------------
    // Always block for run-length calculation and run_value update.
    // - If data_in equals the previous input, increment run_length.
    // - When run_length saturates at DATA_WIDTH, output run_value and reset run_length.
    // - If data_in differs from the previous input, update run_value with the previous run
    //   count and start a new run (run_length = 1).
    //----------------------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length    <= 'b0;
            run_value     <= 'b0;
            prev_data_in  <= 1'b0;
        end
        else begin
            if (data_in == prev_data_in) begin
                if (run_length < DATA_WIDTH)
                    run_length <= run_length + 1;
                else begin
                    // Saturated: output the current run length and start a new run.
                    run_value    <= run_length; // run_length equals DATA_WIDTH
                    run_length   <= 1;
                end
            end
            else begin
                // Transition detected: update run_value with the count of the previous run.
                run_value    <= run_length;
                run_length   <= 1; // Start new run with current bit.
            end
            // Update previous input for next cycle.
            prev_data_in <= data_in;
        end
    end

    //----------------------------------------------------------------------------
    // Always block for valid and data_out signal control.
    // - Assert valid (as a one-cycle pulse) when either:
    //    (a) run_length saturates (i.e. equals DATA_WIDTH), or
    //    (b) a transition in data_in is detected (data_in != prev_data_in).
    // - When valid is high, data_out is updated to the previous data_in value.
    // - In all other cases, valid is low and data_out is cleared.
    //----------------------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid    <= 1'b0;
            data_out <= 1'b0;
        end
        else begin
            // Generate a one-cycle pulse for valid.
            if (((run_length == DATA_WIDTH) || (data_in != prev_data_in)) && !valid)
                valid <= 1'b1;
            else if (valid)
                valid <= 1'b0;
            
            // When valid is high, output the previous data_in value.
            if (valid)
                data_out <= prev_data_in;
            else
                data_out <= 1'b0;
        end
    end

endmodule
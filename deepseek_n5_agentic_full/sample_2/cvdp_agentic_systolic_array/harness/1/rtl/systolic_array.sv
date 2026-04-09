module containing four instantiated weight_stationary_pe PEs
// Arranged in a 2x2 grid to form a systolic array for matrix multiplication
// Each PE performs MAC operations and passes intermediate results to neighbors

// Description:
// This module implements a 2x2 systolic array using four weight_stationary_pe PEs.
// Each PE computes a portion of the matrix multiplication and passes the result
// to the adjacent PE in a wavefront fashion.
// The PE at (0,0) loads the weight and starts computation.
// The done signal is asserted when the final result is computed.

module systolic_array (
    // Inputs
    parameter DATA_WIDTH = 8,
    parameter CLK_PERIOD = 10,

    // Output
    output reg [DATA_WIDTH-1:0] y0,
              [DATA_WIDTH-1:0] y1
);

// instantiated PEs
    weight_stationary_pe#(
        DATA_WIDTH,
        weight:pe00_weight,
        psum_in:pe00_psum_in,
        input:pe00_input,
        valid:pe00_valid,
        done:pe00_done
    ) pe00,
    weight_stationary_pe#(
        DATA_WIDTH,
        weight:pe01_weight,
        psum_in:pe01_psum_in,
        input:pe01_input,
        valid:pe01_valid,
        done:pe01_done
    ) pe01,
    weight_stationary_pe#(
        DATA_WIDTH,
        weight:pe10_weight,
        psum_in:pe10_psum_in,
        input:pe10_input,
        valid:pe10_valid,
        done:pe10_done
    ) pe10,
    weight_stationary_pe#(
        DATA_WIDTH,
        weight:pe11_weight,
        psum_in:pe11_psum_in,
        input:pe11_input,
        valid:pe11_valid,
        done:pe11_done
    ) pe11;

// Clock and reset
reg clock, reset;
pe00_clk <= clock;
pe00_rst <= reset;
pe01_clk <= clock;
pe01_rst <= reset;
pe10_clk <= clock;
pe10_rst <= reset;
pe11_clk <= clock;
pe11_rst <= reset;

// Wavefront data flow connections
pe00.input <= input_in;
pe01.input <= input_in;
pe10.input <= input_in;
pe11.input <= input_in;

pe00_output_value <= pe00.output_value;
pe01_output_value <= pe01.output_value;
pe10_output_value <= pe10.output_value;
pe11_output_value <= pe11.output_value;

pe00_psum_out <= pe00.psum_out;
pe01_psum_out <= pe01.psum_out;
pe10_psum_out <= pe10.psum_out;
pe11_psum_out <= pe11.psum_out;

pe00_output_value <= pe01_input;
pe01_output_value <= pe11_input;
pe10_output_value <= pe11_input;
pe11_output_value <= pe00_input;

// Final output connections
y0 <= pe11_output_value;
y1 <= pe10_output_value;

// Control logic for wavefront processing
always @posedge clock begin
    if (reset) {
        // Initialize all PEs
        pe00.reset <= 1'b0;
        pe01.reset <= 1'b0;
        pe10.reset <= 1'b0;
        pe11.reset <= 1'b0;
        
        // Start processing
        pe00.load_weight <= 1'b0;
        pe01.load_weight <= 1'b0;
        pe10.load_weight <= 1'b0;
        pe11.load_weight <= 1'b0;
    }
    
    // Process wavefront
    #20;
    // Final accumulation
    #20;
    
    // Assert done after computation completes
    if (pe11.done) begin
        $display("Computations complete. y0 = %0d, y1 = %0d", y0, y1);
    end
    #20;
    
    // Reset
    reset <= 1'b1;
endmodule
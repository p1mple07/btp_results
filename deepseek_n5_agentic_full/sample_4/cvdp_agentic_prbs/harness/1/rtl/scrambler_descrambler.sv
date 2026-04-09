Module to perform data scrambling or descrambling using PRBS
 */

module scramble_descrambler #(parameter POLY_LENGTH = 31,
                           parameter POLY_TAP = 3,
                           parameter WIDTH = 16) (
   input  clock,
   input  rst,
   input  bypass_scrambling,
   input  data_in,
   input  valid_in,
   output logic data_out,
   output logic valid_out,
   output wire bit_count
)

// Create the PRBS generator/checker
parameter gen_prbs_gen = prbs_gen_check #(
    parameter CHECK_MODE = 0,
    parameter POLY_LENGTH = POLY_LENGTH,
    parameter POLY_TAP = POLY_TAP,
    parameter WIDTH = WIDTH
)();

// Create the PRBS xor
parameter prbs_xor = prbs_gen_check #(
    parameter CHECK_MODE = 1,
    parameter POLY_LENGTH = POLY_LENGTH,
    parameter POLY_TAP = POLY_TAP,
    parameter WIDTH = WIDTH
)();
 
// State variables
 reg  prbs_reg;
 reg  prbs_out;
 reg  prbs_bit_count;
 
// Initialisation
 always begin
    // Whenrst is asserted, initialise both PRBS generators
    prbs_reg <= {POLY_LENGTH{1'b1}};
    prbs_xor.reg <= {POLY_LENGTH{1'b1}};
    
    // Set initial bit count to zero
    prbs_bit_count = 0;
 end
 
// Process description
always_ff@ (posedge clock) begin
    case(bypass_scrambling)
        // Bypass mode: pass data through directly with 1-cycle latency
        data_out <= data_in;
        valid_out <= valid_in & (prbs_bit_count == 0);
        prbs_bit_count = prbs_bit_count + (valid_in ? WIDTH : 0);
        default
            // Normal operation: process data or check PRBS
            if(rst) begin
                // Initialisation phase
                prbs_reg <= {POLY_LENGTH{1'b1}};
                prbs_out <= data_out;
                valid_out <= valid_in & (prbs_bit_count == 0);
                prbs_bit_count = 0;
            else
                // Start normal operation
                prbs_reg <= prbs_out;
                prbs_out = (check_mode == 0) ? (data_in ^ prbs_xor.reg) : prbs_xor.reg;
                valid_out <= valid_in & (prbs_bit_count != 0); 
                prbs_bit_count += (valid_in ? WIDTH : 0);
            end
    endcase
end
 
// Latency control
always @ (negedge rst) begin
    prbs_reg <= {POLY_LENGTH{1'b1}};
    prbs_out <= data_out;
    valid_out <= valid_in;
    prbs_bit_count = 0;
end

// Module outputs
output 
    prbs_out as data_out,
    valid_out as valid_out,
    prbs_bit_count as bit_count
;
endmodule
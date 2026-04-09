module pseudo_rand_generator_ca (
   input clock,
   input reset,
   input [15:0] CA_seed,
   input [1:0] rule_sel,
   output [15:0] CA_out
 )

   // Initialize variables
   reg [15:0] next_state;
   integer cycle_count;

   // Lookup tables for Rule 30 and Rule 110
   const [
     // Rule 30 mappings
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0
   ] rule_30_map;

   [
     // Rule 110 mappings
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b1,
     7'd111, 7'd110, 7'd101, 7'd100, 7'd011, 7'd010, 7'd001, 7'd000
     -> 4'b0
   ] rule_110_map;

   // Always blocks
   always_comb begin
     next_state[0] = rule_30_map[(rule_sel << 1) | ((CA_seed >> 14) & 1)] 
                     ? ( ( (CA_seed >> 14) & 1 ) << 2 | ( (CA_seed >> 13) & 1 ) << 1 | ( (CA_seed >> 12) & 1 ) )
                     : rule_110_map[...];
     
     // Repeat similar assignments for next_state[1] to next_state[15]
   end

   always begin
     // Update the output after the next_state is computed
     if (reset) begin
       CA_out = CA_seed;
     else begin
       CA_out = next_state;
     end
   end

endmodule
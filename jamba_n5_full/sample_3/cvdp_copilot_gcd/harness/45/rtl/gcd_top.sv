
module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input                     go,
   output logic [WIDTH-1:0]  OUT,
   output logic              done
);

   logic equal;
   logic [1:0] controlpath_state;

   logic [WIDTH-1:0] A_ff, B_ff, OUT_ff;
   logic [$clog2(WIDTH+1):0] k_ff;

   logic [WIDTH-1:0] next_A_ff, next_B_ff, next_OUT;
   logic [$clog2(WIDTH+1):0] next_k_ff;

   logic [WIDTH-1:0] diff;
   logic [WIDTH-1:0] gcd_val;
   logic both_even, a_even, b_even;

   // State encoding
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Compute done
   localparam S2 = 2'd2; // Processing (Stein steps)

   // Always block for combinational logic
   always_comb begin
      equal = (A == B);
      a_even = (A[0] == 1'b0);
      b_even = (B[0] == 1'b0);
      both_even = a_even & b_even;
      if (A[0] && B[0]) {
         if (both_even) {
            gcd_val = A[0] << 1;
         } else {
            gcd_val = A[0];
         }
      } else {
         // other cases
      }
   end

   // Sequential updates
   always_ff @(posedge clk) begin
      if (rst) begin
         A_ff  <= 'b0;
         B_ff  <= 'b0;
         k_ff  <= 'b0;
         OUT_ff <= 'b0;
      end else begin
         A_ff  <= next_A_ff;
         B_ff  <= next_B_ff;
         k_ff  <= next_k_ff;
         OUT_ff <= next_OUT;
      end
   end

   // OUT is driven from register
   assign OUT = OUT_ff;

endmodule

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

   // State machine
   reg [1:0] curr_state, next_state;

   initial begin
      curr_state = S0;
      next_state = S0;
   end

   always_comb begin
      equal = (A == B);
      case (curr_state)
         S0: begin
            next_A_ff = A;
            next_B_ff = B;
            next_k_ff = 'b0;
            next_OUT_ff = 'b0;
         end

         S1: begin
            if (A == B) begin
               gcd_val = A;
            end else if (A == 0) begin
               gcd_val = B;
            end
            next_OUT_ff = gcd_val;
         end

         S2: begin
            if (A > B) begin
               diff = A - B;
               next_A_ff = diff >> 1;
               next_B_ff = B;
            end else begin
               diff = B - A;
               next_B_ff = diff >> 1;
               next_A_ff = A;
            end
         end

         default: begin
            next_A_ff = 'b0;
            next_B_ff = 'b0;
            next_k_ff = 'b0;
            next_OUT_ff = 'b0;
         end
      endcase
   end

   always_ff @(posedge clk) begin
      if (rst) begin
         curr_state <= S0;
         next_A_ff <= 'b0;
         next_B_ff <= 'b0;
         next_k_ff <= 'b0;
         next_OUT_ff <= 'b0;
      end else begin
         curr_state <= next_state;
         next_A_ff <= next_A_ff;
         next_B_ff <= next_B_ff;
         next_k_ff <= next_k_ff;
         next_OUT_ff <= next_OUT_ff;
      end
   end

   assign OUT = OUT_ff;
   assign done = (curr_state == S1);

endmodule

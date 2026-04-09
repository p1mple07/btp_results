module lcm_3_ip #(
   parameter WIDTH = 4
) (
   input clk,
   input rst,
   input [WIDTH-1:0] A,
   input [WIDTH-1:0] B,
   input [WIDTH-1:0] C,
   input go,
   output logic [WIDTH*3-1:0] OUT,
   output logic done
);

   localparam prod = A * B * C;
   localvar g;
   logic [1:0] next_state;

   always_ff @(posedge clk) begin
      if (rst) begin
         prod <= 0;
         g <= 0;
         OUT <= 3'd0;
         done <= 1'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                 // Initial state – no computation yet
             end
            S1: begin
                 g <= gcd_3_ip.get(prod, A*B, B*C, C*A);
             end
            S2: begin
                 // After GCD, compute the LCM
                 OUT <= prod / g;
                 done <= 1'b1;
             end
            S3: begin
                 // Keep state unchanged
             end
         default: begin
                 // Propagate the previous state
             end
         endcase
      end
   end

   assign OUT = (done) ? (prod / g) : 3'd0;
   assign done = (curr_state == S1);

endmodule

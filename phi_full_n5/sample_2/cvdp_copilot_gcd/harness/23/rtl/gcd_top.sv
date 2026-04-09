module gcd_top #(
   parameter WIDTH = 4
) (
   input clk,
   input rst,
   input go,
   input [WIDTH-1:0] A,
   input [WIDTH-1:0] B,
   output logic [WIDTH-1:0] OUT,
   output logic done
);

   // Internal signals for control path
   logic equal;
   logic [1:0] controlpath_state;

   // Instantiate control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk(clk),
      .rst(rst),
      .go(go),
      .equal(equal),
      .controlpath_state(controlpath_state)
   );

   // Instantiate datapath module
   gcd_datapath
   #(
      .WIDTH(WIDTH)
   ) gcd_datapath_inst (
      .clk(clk),
      .rst(rst),
      .A(A),
      .B(B),
      .controlpath_state(controlpath_state),
      .equal(equal)
   );

   // Assign output based on FSM state
   always @ (posedge clk) begin
      if (rst) begin
         OUT <= 'b0;
         done <= 1'b0;
      end else begin
         case (controlpath_state)
            S0: begin
               OUT <= A;
               done <= (A == B) ? 1'b1 : 1'b0;
            end
            S1: begin
               OUT <= B;
               done <= 1'b1;
            end
            S2: begin
               // A is even, B is odd
               if (A[WIDTH-1] == 1'b0)
                  OUT <= A shr<2>;
               else
                  OUT <= B shr<2>;
               equal <= (A == B) ? 1'b1 : 1'b0;
            end
            S3: begin
               // A is odd, B is even
               if (B[WIDTH-1] == 1'b0)
                  OUT <= A shr<2>;
               else
                  OUT <= B shr<2>;
               equal <= (A == B) ? 1'b1 : 1'b0;
            end
            default: begin
               OUT <= 'b0;
               equal <= 1'b0;
               done <= 1'b0;
            end
         endcase
      end
   end
endmodule


module gcd_datapath #(
   parameter WIDTH = 4
) (
   input clk,
   input rst,
   input equal,
   input [WIDTH-1:0] A,
   input [WIDTH-1:0] B,
   output logic [WIDTH-1:0] OUT,
   output logic factorCount
);

   // Registers for intermediate values and factor count
   logic [WIDTH-1:0] A_ff, B_ff;
   logic factorCount;

   // Implement Stein's algorithm
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= A;
         B_ff <= B;
         factorCount <= 0;
      end else begin
         case (equal)
           1'b1: begin
               if (A[WIDTH-1] == 1'b0 && B[WIDTH-1] == 1'b0) begin
                  A_ff <= A shr<2>;
                  B_ff <= B shr<2>;
                  factorCount <= factorCount + 1;
               end else if (A[WIDTH-1] == 1'b0) begin
                  A_ff <= B;
                  factorCount <= 0;
               end else if (B[WIDTH-1] == 1'b0) begin
                  B_ff <= A;
                  factorCount <= 0;
               end else begin
                  A_ff <= A;
                  B_ff <= B;
               end
               factorCount <= factorCount;
               equal <= 1'b0;
            end
            default: begin
               A_ff <= 'b0;
               B_ff <= 'b0;
               factorCount <= 0;
               equal <= 1'b0;
            end
         endcase
      end
   end

   // Output logic for GCD result
   assign OUT = A_ff;
   assign factorCount = factorCount;
endmodule

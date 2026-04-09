module gcd_top (#(parameter WIDTH = 4));

   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input                     go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done;

   reg [1:0] curr_state, next_state;
   logic equal, greater_than;

   always_ff @(posedge clk) begin
      if (rst) begin
         curr_state <= S0;
      end else begin
         curr_state <= next_state;
      end
   end

   always_comb begin
      case (curr_state)
         S0: begin
             equal   = A == B;
             greater_than = A > B;
             if (equal) next_state = S1;
             else if (greater_than) next_state = S2;
             else next_state = S3;
         end
         S1: begin
             next_state = S0;
         end
         S2: begin
             if (greater_than) A_ff = A_ff - B_ff;
             next_state = S1;
         end
         S3: begin
             if (!equal && !greater_than) B_ff = B_ff - A_ff;
             next_state = S1;
         end
         default: begin
             next_state = S0;
         end
      endcase
   end

   always_comb begin
      case (next_state)
         S1: begin
             OUT = A_ff;
         end
         S2: begin
             OUT = B_ff;
         end
         S3: begin
             OUT = A_ff;
         end
      endcase
   end

   always_ff @(posedge clk) begin
      done <= (curr_state == S1);
   end

endmodule

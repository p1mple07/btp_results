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

   logic equal, controlpath_state;

   // Combined FSM state encoding
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Processing
   localparam S2 = 2'd2; // Done

   // Combined FSM state transitions
   always_comb begin
      case (controlpath_state)
         S0: begin
            if (!go) 
               controlpath_state = S0;
            else 
               controlpath_state = S1;
         end
         S1: begin
            if (equal) 
               controlpath_state = S2;
            else
               controlpath_state = S1;
         end
         S2: begin
            done <= 1'b1;
         end
         default: begin
            controlpath_state = S0;
         end
      endcase
   end

   // Combined datapath logic
   always_comb begin
      if (rst) begin
         OUT = 'b0;
      end else begin
         // Initialization
         OUT = A;

         // Combine equal flag and datapath logic
         if (A == B) begin
            equal = 1'b1;
            if (A == 0) begin
               OUT = B;
            end else begin
               OUT = A << 1;
            end
         end else begin
            if (A > B) begin
               B = B - A;
            end else begin
               A = A - B;
            end
            equal = 1'b0;
         end
      end
   end

endmodule

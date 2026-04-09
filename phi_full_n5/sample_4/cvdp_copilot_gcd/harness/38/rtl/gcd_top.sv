module gcd_top #(
   parameter WIDTH = 4
) (
   input                     clk,
   input                     rst,
   input                     go,
   input [WIDTH-1:0]        A,
   input [WIDTH-1:0]        B,
   output logic [WIDTH-1:0] OUT,
   output logic              done
);

   // Internal signals for FSM
   logic [1:0] controlpath_state;
   logic equal, greater_than;
   logic equal_next, greater_than_next;

   // FSM and datapath logic combined
   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         controlpath_state <= 2'd0;
         equal <= 1'b0;
         greater_than <= 1'b0;
         OUT <= 'b0;
         done <= 1'b0;
      end else begin
         case (controlpath_state)
           2'd0: begin
               // Initialization
               equal <= (A == B);
               greater_than <= (A > B);
               controlpath_state <= 2'd1;
            end
           2'd1: begin
               // Computation complete
               OUT <= A;
               done <= 1'b1;
               controlpath_state <= 2'd0;
            end
           2'd2: begin
               // A_ff > B_ff, subtract B_ff from A_ff
               if (equal)
                  OUT <= A;
               else
                  OUT <= A - B;
               greater_than_next <= 1'b1;
               controlpath_state <= 2'd2;
            end
           2'd3: begin
               // B_ff > A_ff, subtract A_ff from B_ff
               if (greater_than)
                  OUT <= B;
               else
                  OUT <= B - A;
               equal_next <= 1'b1;
               controlpath_state <= 2'd3;
            end
            default: begin
               OUT <= 'b0;
               done <= 1'b0;
               controlpath_state <= 2'd0;
            end
         endcase
      end
   end

   // Output logic
   assign OUT = done ? OUT : 'b0;

endmodule

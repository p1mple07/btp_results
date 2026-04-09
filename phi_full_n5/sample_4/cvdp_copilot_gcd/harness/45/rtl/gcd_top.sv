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

   logic [1:0] controlpath_state;
   logic equal;

   // Combined datapath and control logic
   always_comb begin
      // Initialize state
      if (!go) begin
         controlpath_state <= S0;
         equal <= 'b0;
      end else begin
         controlpath_state <= S2;
         equal <= 'b0;
      end

      case (controlpath_state)
         S0: begin
            // Load inputs
            if (rst) begin
               A <= 'b0;
               B <= 'b0;
               equal <= 'b0;
            end else begin
               A <= A;
               B <= B;
               equal <= 'b0;
            end
         end

         S1: begin
            // Compute done
            if (equal) begin
               OUT <= A;
               controlpath_state <= S1;
               done <= 1'b1;
            end else begin
               A <= A >> 1;
               B <= B >> 1;
               controlpath_state <= S2;
               equal <= (A == B);
            end
         end

         S2: begin
            // Processing (Stein steps)
            if ((A != 0) && (B != 0)) begin
               if (A < B) begin
                  A <= A - B;
                  B <= B;
               end else begin
                  A <= A;
                  B <= B - A;
               end
               controlpath_state <= S2;
               equal <= (A == B);
            end else if (A == 0) begin
               B <= B;
               controlpath_state <= S1;
               equal <= 'b0;
            end else if (B == 0) begin
               A <= A;
               controlpath_state <= S1;
               equal <= 'b0;
            end
         end

         default: begin
            // Reset
            A <= 'b0;
            B <= 'b0;
            equal <= 'b0;
            controlpath_state <= S0;
         end
      endcase
   end

   // Output logic
   assign OUT = A;

endmodule

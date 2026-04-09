module gcd_top #(
   parameter WIDTH = 4,
   parameter BIT_WIDTH = WIDTH
) (
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic              equal,              // Signal indicating A_ff == B_ff
   output logic              greater_than,       // Signal indicating A_ff > B_ff
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Datapath registers
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= 'b0;
         B_ff <= 'b0;
         equal        = 1'b0;
         greater_than = 1'b0;
      end else begin
         case (controlpath_state)
            S0: begin
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               OUT  <= A_ff;
            end
            S2: begin
               if (greater_than)
                  A_ff <= A_ff - B_ff;
            end
            S3: begin
               if (!equal & !greater_than)
                  B_ff <= B_ff - A_ff;
            end
            default: begin
               A_ff <= 'b0;
               B_ff <= 'b0;
               equal        = 1'b0;
               greater_than = 1'b0;
            end
         endcase
      end
   end

   // State transition logic: Determine next state based on current state and inputs
   always_comb begin
      case(controlpath_state)
         S0: begin
             if(!go)
                controlpath_state <= S0;
             else if (equal)
                controlpath_state <= S1;
             else if (greater_than)
                controlpath_state <= S2;
             else
                controlpath_state <= S3;
         end
         S1: begin
             controlpath_state <= S0;
         end
         S2: begin
             if(equal)
                controlpath_state <= S1;
             else if (greater_than)
                controlpath_state <= S2;
             else
                controlpath_state <= S3;
         end
         S3: begin
             if (equal)
                controlpath_state <= S1;
             else if (greater_than)
                controlpath_state <= S2;
             else
                controlpath_state <= S3;
         end
         default: begin
             controlpath_state <= S0;
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
     if(rst) begin
        equal        = 1'b0;
        greater_than = 1'b0;
     end else begin
        equal        = (A_ff == B_ff);
        greater_than = (A_ff >  B_ff);
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = controlpath_state;

endmodule
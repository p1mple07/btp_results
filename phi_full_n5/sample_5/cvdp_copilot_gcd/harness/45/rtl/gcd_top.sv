module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input                     go,
   input                     equal,
   input [WIDTH-1:0]        A,
   input [WIDTH-1:0]        B,
   output logic [WIDTH-1:0] OUT,
   output logic             done
);

   // FSM states
   localparam S0 = 2'd0, // Idle
       S1 = 2'd1, // Load A and B
       S2 = 2'd2, // Processing
       S3 = 2'd3, // Done
       S4 = 2'd4; // Error state (unreachable in correct implementation)

   // FSM registers
   reg [1:0] fsm_state;
   reg [WIDTH-1:0] A_reg, B_reg;
   reg [WIDTH-1:0] k_reg;

   // Combinational logic for FSM
   always_comb begin
      case (fsm_state)
         S0: begin
            if (go) begin
               fsm_state <= S1;
               A_reg <= A;
               B_reg <= B;
            end
            else begin
               fsm_state <= S0;
            end
         end
         S1: begin
            fsm_state <= S2;
         end
         S2: begin
            // Stein's algorithm logic here
            // Use A_reg, B_reg, and k_reg for computations
            // Update fsm_state based on equal flag and other conditions
         end
         S3: begin
            fsm_state <= S4; // Error state for handling incorrect inputs
            done <= 1'b1;
         end
         S4: begin
            fsm_state <= S0;
         end
         default: begin
            fsm_state <= S0;
         end
      endcase
   end

   // Sequential logic for FSM
   always_ff @(posedge clk) begin
      if (rst) begin
         fsm_state <= S0;
         A_reg <= 'b0;
         B_reg <= 'b0;
         k_reg <= 'b0;
      end else begin
         fsm_state <= fsm_state;
         A_reg <= A_reg;
         B_reg <= B_reg;
         k_reg <= k_reg;
      end
   end

   // OUT and done logic
   assign OUT = B_reg; // Assuming B remains in the final state
   assign done = (fsm_state == S3);

endmodule

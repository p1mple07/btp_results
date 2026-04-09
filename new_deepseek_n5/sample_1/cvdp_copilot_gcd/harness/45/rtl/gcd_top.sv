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

   // FSM implementation combining control and datapath logic
   gcd_fsm  #(
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .equal             (equal),
      .A                 (A),
      .B                 (B),
      .OUT               (OUT)
   );

endmodule

// Combined Control and Datapath FSM
module gcd_fsm  #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input      [WIDTH-1:0]    A,
   input      [WIDTH-1:0]    B,
   input      [1:0]          controlpath_state,
   output logic              equal,
   output logic [WIDTH-1:0]  OUT
);

   // FSM state encoding
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Compute done
   localparam S2 = 2'd2; // Processing (Stein steps)

   // State encoding
   logic [WIDTH-1:0] A_ff, B_ff;
   logic [1:0] controlpath_state_ff;

   // Internal registers
   logic [WIDTH-1:0] A_reg, B_reg, OUT_reg;
   logic [$clog2(WIDTH+1):0] shift_reg;

   // Next-state signals
   logic [WIDTH-1:0] next_A_reg, next_B_reg, next_OUT;
   logic [$clog2(WIDTH+1):0] next_shift_reg;

   logic [WIDTH-1:0] diff;
   logic [WIDTH-1:0] gcd_val;
   logic both_even, a_even, b_even;

   // State encoding
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Compute done
   localparam S2 = 2'd2; // Processing (Stein steps)

   // Combinational logic for next states and outputs
   always_comb begin
      // Default next values
      next_A_reg = A_reg;
      next_B_reg = B_reg;
      next_shift_reg = shift_reg;
      next_OUT  = OUT_reg;
      gcd_val   = OUT_reg; // Default to current OUT value
      diff      = 'b0;

      // Determine intermediate flags
      a_even    = (A_reg[0] == 1'b0);
      b_even    = (B_reg[0] == 1'b0);
      both_even = a_even && b_even;
      equal     = (A_reg == B_reg);

      case (controlpath_state)
         S0: begin
            // Load inputs at S0
            next_A_reg = A;
            next_B_reg = B;
            next_shift_reg = 'b0;
            next_OUT  = 'b0; 
         end

         S1: begin
            // Done state: finalize the GCD
            // If A_ff == B_ff: gcd = A_ff << k_ff
            // If both zero => gcd=0
            // If one zero => gcd = nonzero << k_ff
            if (A_reg == 0 && B_reg == 0) begin
               gcd_val = 0;
            end else if (A_reg == 0) begin
               gcd_val = (B_reg << shift_reg);
            end else begin
               // A_reg == B_reg
               gcd_val = (A_reg << shift_reg);
            end
            next_OUT = gcd_val;
         end

         S2: begin
            // One step of Stein's algorithm
            // If not done, apply rules:
            // Both even: A=A/2, B=B/2, k++
            // A even, B odd: A=A/2
            // B even, A odd: B=B/2
            // Both odd: larger = (larger - smaller)/2

            if ((A_reg != 0) && (B_reg != 0)) begin
               // Both nonzero
               if (both_even) begin
                  next_A_reg = A_reg >> 1;
                  next_B_reg = B_reg >> 1;
                  next_shift_reg = shift_reg + 1;
               end else if (a_even && !b_even) begin
                  next_A_reg = A_reg >> 1;
               end else if (b_even && !a_even) begin
                  next_B_reg = B_reg >> 1;
               end else begin
                  // both odd
                  if (A_reg >= B_reg) begin
                     diff = A_reg - B_reg;
                     next_A_reg = diff >> 1;
                     next_B_reg = B_reg;
                  end else begin
                     diff = B_reg - A_reg;
                     next_B_reg = diff >> 1;
                     next_A_reg = A_reg;
                  end
               end
            end else if (A_reg == 0 && B_reg != 0) begin
               // If one is zero and the other is nonzero, make them equal to move to done next cycle
               next_A_reg = B_reg;
               next_B_reg = B_reg;
            end else if (B_reg == 0 && A_reg != 0) begin
               next_B_reg = A_reg;
               next_A_reg = A_reg;
            end
            // If both are zero, they are already equal, will move to done soon.
         end

         default: begin
            // Default reset values
            next_A_reg = 'b0;
            next_B_reg = 'b0;
            next_shift_reg = 'b0;
            next_OUT  = 'b0;
         end
      endcase
   end

   // Sequential updates
   always_ff @(posedge clk) begin
      if (rst) begin
         A_reg  <= 'b0;
         B_reg  <= 'b0;
         shift_reg <= 'b0;
         OUT_reg <= 'b0;
      end else begin
         A_reg  <= next_A_reg;
         B_reg  <= next_B_reg;
         shift_reg <= next_shift_reg;
         OUT_reg <= next_OUT;
      end
   end

   // OUT is driven from register
   assign OUT = OUT_reg;

endmodule
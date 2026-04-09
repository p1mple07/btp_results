module hebbian_rule (
    input  logic         clk,         // 1-bit posedge clock
    input  logic         rst,         // asynchronous negedge reset
    input  logic         start,       // active HIGH to start FSM
    input  logic signed  [3:0] a,       // 4-bit signed input (only -1 and 1 valid)
    input  logic signed  [3:0] b,       // 4-bit signed input (only -1 and 1 valid)
    input  logic  [1:0]  gate_select, // 2-bit selector for target gate behavior
    output logic signed  [3:0] w1,     // trained weight for input a
    output logic signed  [3:0] w2,     // trained weight for input b
    output logic signed  [3:0] bias,   // trained bias value
    output logic  [3:0]  present_state, // current FSM state
    output logic  [3:0]  next_state    // next FSM state
);

   // State Encoding (Moore FSM with 11 states)
   localparam S0 = 4'd0,  // Reset state
              S1 = 4'd1,  // Capture inputs
              S2 = 4'd2,  // Begin target assignment (AND)
              S3 = 4'd3,  // Continue target assignment (OR)
              S4 = 4'd4,  // Continue target assignment (NAND)
              S5 = 4'd5,  // Continue target assignment (NOR)
              S6 = 4'd6,  // Hold state after target assignment
              S7 = 4'd7,  // Compute delta values (Hebbian rule)
              S8 = 4'd8,  // Update weights and bias
              S9 = 4'd9,  // Loop/training iteration state
              S10 = 4'd10; // Return to initial state

   // Internal registers
   logic [3:0] state, next_state_reg;
   logic signed [3:0] x1, x2;      // Registers to hold captured inputs
   logic signed [3:0] target_reg;  // Register for computed target value
   logic signed [3:0] delta_w1, delta_w2, delta_b; // Deltas for weights and bias

   // Weights and bias registers
   logic signed [3:0] w1_reg, w2_reg, bias_reg;

   // Output assignments
   assign present_state = state;
   assign next_state    = next_state_reg;
   assign w1            = w1_reg;
   assign w2            = w2_reg;
   assign bias          = bias_reg;

   // Next state combinational logic
   always_comb begin
      case (state)
         S0: next_state_reg = (start) ? S1 : S0;
         S1: next_state_reg = S2;
         S2: next_state_reg = S3;
         S3: next_state_reg = S4;
         S4: next_state_reg = S5;
         S5: next_state_reg = S6;
         S6: next_state_reg = S7;
         S7: next_state_reg = S8;
         S8: next_state_reg = S9;
         S9: next_state_reg = S10;
         S10: next_state_reg = S0;
         default: next_state_reg = S0;
      endcase
   end

   // FSM sequential process
   always_ff @(posedge clk or negedge rst) begin
      if (!rst) begin
         // Asynchronous reset: initialize all registers to 0 and state to S0
         state          <= S0;
         w1_reg         <= 4'b0000;
         w2_reg         <= 4'b0000;
         bias_reg       <= 4'b0000;
         x1             <= 4'b0000;
         x2             <= 4'b0000;
         target_reg     <= 4'b0000;
         delta_w1       <= 4'b0000;
         delta_w2       <= 4'b0000;
         delta_b        <= 4'b0000;
      end
      else begin
         case (state)
            S0: begin
                  // Wait for start signal; remain in reset until start is asserted
                  if (start)
                     state <= S1;
                  else
                     state <= S0;
               end
            S1: begin
                  // Capture inputs into internal registers
                  x1 <= a;
                  x2 <= b;
                  state <= S2;
               end
            S2: begin
                  // Compute target based on gate_select.
                  // For valid inputs, we map -1 to logic 0 and 1 to logic 1.
                  case (gate_select)
                     2'b00: begin
                        // AND gate: target = 1 only if both inputs are 1; else 0.
                        target_reg <= ((x1 == 4'b0001) && (x2 == 4'b0001)) ? 4'b0001 : 4'b0000;
                     end
                     2'b01: begin
                        // OR gate: target = 1 if either input is 1; else 0.
                        target_reg <= ((x1 == 4'b0001) || (x2 == 4'b0001)) ? 4'b0001 : 4'b0000;
                     end
                     2'b10: begin
                        // NAND gate: target = 0 if both inputs are 1; else 1.
                        target_reg <= (((x1 == 4'b0001) && (x2 == 4'b0001))) ? 4'b0000 : 4'b0001;
                     end
                     2'b11: begin
                        // NOR gate: target = 1 if both inputs are -1; else 0.
                        target_reg <= (((x1 == 4'b1111) && (x2 == 4'b1111))) ? 4'b0001 : 4'b0000;
                     end
                  endcase
                  state <= S3;
               end
            S3: begin
                  // Intermediate state (could be used for additional target processing)
                  state <= S4;
               end
            S4: begin
                  state <= S5;
               end
            S5: begin
                  state <= S6;
               end
            S6: begin
                  // Transition state before computing deltas
                  state <= S7;
               end
            S7: begin
                  // Compute delta values using the Hebbian rule:
                  // delta_w = x * target, where x is either 1 or -1.
                  // Since valid x values are 1 (4'b0001) and -1 (4'b1111),
                  // the multiplication yields:
                  //   1 * 1 =  1,   1 * -1 = -1,
                  //  -1 * 1 = -1,  -1 * -1 =  1.
                  if (x1 == 4'b0001) begin
                     if (target_reg == 4'b0001)
                        delta_w1 <= 4'b0001;
                     else
                        delta_w1 <= 4'b1111; // Represents -1
                  end
                  else begin
                     if (target_reg == 4'b0001)
                        delta_w1 <= 4'b1111;
                     else
                        delta_w1 <= 4'b0001;
                  end

                  if (x2 == 4'b0001) begin
                     if (target_reg == 4'b0001)
                        delta_w2 <= 4'b0001;
                     else
                        delta_w2 <= 4'b1111;
                  end
                  else begin
                     if (target_reg == 4'b0001)
                        delta_w2 <= 4'b1111;
                     else
                        delta_w2 <= 4'b0001;
                  end

                  // delta_b is simply the target value.
                  delta_b <= target_reg;
                  state <= S8;
               end
            S8: begin
                  // Update weights and bias with the computed deltas.
                  w1_reg <= w1_reg + delta_w1;
                  w2_reg <= w2_reg + delta_w2;
                  bias_reg <= bias_reg + delta_b;
                  state <= S9;
               end
            S9: begin
                  // Loop through training iterations (could include convergence check here)
                  state <= S10;
               end
            S10: begin
                  // Return to the initial state (reset state)
                  state <= S0;
               end
            default: state <= S0;
         endcase
      end
   end

endmodule
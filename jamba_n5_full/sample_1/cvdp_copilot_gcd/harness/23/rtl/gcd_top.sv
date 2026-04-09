module gcd_top #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Internal signals to communicate between control path and data path
   logic equal;                     // Signal indicating A == B
   logic greater_than;              // Signal indicating A > B
   logic [1:0] controlpath_state;   // Current state of the control FSM

   // Instantiate the control path module
   gcd_controlpath_inst uut (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go),                // Connect go signal
      .equal             (equal),             // Connect equal signal from datapath
      .greater_than      (greater_than),      // Connect greater_than signal from datapath
      .controlpath_state (controlpath_state), // Output current state to datapath
      .done              (done)               // Output done signal
   );

   // Instantiate the data path module
   gcd_datapath udp (
      .clk               (clk),               // Clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .controlpath_state (controlpath_state), // Connect current state from control path
      .equal             (equal),             // Output equal signal to control path
      .greater_than      (greater_than),      // Output greater_than signal to control path
      .OUT               (UDP_OUT)             // Output GCD result
   );

   // Register to track factored-out twos
   reg [2:0] factor_of_two;

   // Sequential logic to update registers based on controlpath_state
   always_ff @(posedge clk) begin
      if (rst) begin
         factor_of_two <= 3'd0;
         A <= A >> 1;
         B <= B >> 1;
         OUT <= '0;
         done <= 1'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                 if (A == B) begin
                     factor_of_two <= 3'd0;
                     A <= A;
                     B <= B;
                     OUT <= A;
                     done <= 1'b1;
                  end else begin
                     // Both even
                     factor_of_two <= 3'd1;
                     A <= A >> 1;
                     B <= B >> 1;
                     OUT <= '0;
                  end
                 end
             end
            S1: begin
                 // Compute difference
                 if (A > B) begin
                     A = A - B;
                     factor_of_two <= 3'd0;
                 end else begin
                     B = B - A;
                     factor_of_two <= 3'd0;
                 end
                 OUT <= '0;
                 done <= 1'b1;
             end
            S2: begin
                 // Both odd, but not equal
                 if (factor_of_two == 3'd1) begin
                     A = A - B;
                     factor_of_two <= 3'd0;
                 end else if (factor_of_two == 3'd0) begin
                     B = B - A;
                     factor_of_two <= 3'd0;
                 end else begin
                     // Same parity after previous steps
                     factor_of_two <= 3'd0;
                     A = A >> 1;
                     B = B >> 1;
                     OUT <= '0;
                     done <= 1'b1;
                  end
             end
            default: begin
                 A <= '0;
                 B <= '0;
                 OUT <= '0;
                 done <= 1'b0;
             end
         endcase
      end
   end

endmodule

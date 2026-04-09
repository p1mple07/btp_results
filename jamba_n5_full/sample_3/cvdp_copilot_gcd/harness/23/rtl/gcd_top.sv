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

   // Instantiate the data path module
   gcd_datapath #(
      .WIDTH(WIDTH)
   ) uut (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .controlpath_state (controlpath_state), // Connect current state from control path
      .equal             (equal),             // Output equal signal to control path
      .greater_than      (greater_than),      // Output greater_than signal to control path
      .OUT               (OUT)                // Output GCD result
   );
endmodule

// Datapath module for GCD computation using Stein's algorithm
module gcd_datapath #(
   parameter WIDTH = 4                           // Bit-width of operands
   )(
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input                     go,                  // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,               // Output for the GCD result
   output logic              done                 // Signal to indicate completion of computation
);

   // Registers
   logic twos;
   logic [WIDTH-1:0] a, b;

   // Always block to compute the GCD
   always_ff @(posedge clk or rising_edge(rst)) begin
      if (rst) begin
         a <= 'b0;
         b <= 'b0;
         twos <= 0;
         OUT <= 'b0;
         done <= 1'b0;
      end else begin
         case (done)
            '0: begin
               // start computation
               a <= A;
               b <= B;
               twos <= 0;
            end
            '1: begin
               // we already have a and b, do nothing
            end
            default: begin
               // shouldn't happen
            end
         endcase
      end
   end

   // Main computation logic
   always_comb begin
      case (a[WIDTH-1:0] == 0 || b[WIDTH-1:0] == 0) {
         '0: // both zero
            OUT <= 'b0;
            done <= 1'b1;
            break;
         '1: // one zero
            if (a == 0) OUT <= b;
            else OUT <= a;
            done <= 1'b1;
            break;
      }

      // Both are even
      if (a[WIDTH-1:0] % 2 == 0 && b[WIDTH-1:0] % 2 == 0) begin
         a <= a >> 1;
         b <= b >> 1;
         twos <= twos + 1;
      end

      // One even, one odd: reduce the odd one
      else if (a[WIDTH-1:0] % 2 == 1 && b[WIDTH-1:0] % 2 == 0) begin
         b <= b >> 1;
      end
      else if (a[WIDTH-1:0] % 2 == 0 && b[WIDTH-1:0] % 2 == 1) begin
         a <= a >> 1;
      end

      // Both odd: subtract the smaller from the larger
      else begin
         if (a > b) begin
            b <= b - a;
         else
            a <= a - b;
         end
      end
   end

   assign OUT = a;
   assign done = 1'b1;

endmodule

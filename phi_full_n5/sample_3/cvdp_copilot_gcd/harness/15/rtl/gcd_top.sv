module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
   )(
   input                         clk,     // Clock signal. The design should be synchronized to the positive edge of this clock signal
   input                         rst,     // Active high Synchronous reset signal
   input  [WIDTH-1:0]            A,       // WIDTH bit input
   input  [WIDTH-1:0]            B,       // WIDTH bit input
   input  [WIDTH-1:0]            C,       // WIDTH bit input
   input                         go,      // Active high Start signal for LCM computation
   output logic  [3 * WIDTH-1:0] OUT,     // Computed LCM. 3*WIDTH bits wide
   output logic                  done     // Signal indicating that the computation is complete
);

   // Internal signals to hold intermediate values
   logic [3 * WIDTH-1:0] temp_lcm; // Temporary storage for multiplication results
   logic done_lcm;                // LCM computation done signal

   // Instantiate the gcd_3_ip module
   gcd_3_ip #(
      .WIDTH(WIDTH)
   ) gcd_3_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (A),
      .B             (B),
      .go            (go),
      .OUT           (gcd_3_inst.OUT),
      .done          (gcd_3_inst.done)
   );

   // Calculate LCM using the GCD value
   assign temp_lcm = A * B * C;
   assign done_lcm = temp_lcm / gcd_3_inst.OUT;

   // Ensure division does not result in overflow
   always_ff @(posedge clk) begin
      if (rst) begin
         OUT <= 0;
         done_lcm <= 0;
      end else begin
         if (go) begin
            temp_lcm <= A * B * C;
            done_lcm <= temp_lcm / gcd_3_inst.OUT;
            OUT <= {temp_lcm[WIDTH-1:0], temp_lcm[2*WIDTH-1:1], temp_lcm[3*WIDTH-1:2]};
            done_lcm <= temp_lcm / gcd_3_inst.OUT;
         end else begin
            OUT <= OUT;
            done_lcm <= done_lcm;
         end
      end
   end

   // Output logic
   assign OUT = {OUT[WIDTH-1:0], OUT[2*WIDTH-1:1], OUT[3*WIDTH-1:2]};
   assign done = done_lcm & (OUT[WIDTH-1] == OUT[2*WIDTH-1]) & (OUT[3*WIDTH-1] == OUT[2*WIDTH-1]);

endmodule

module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
) (
   input                         clk,     // Clock signal. The design should be synchronized to the positive edge of this clock signal
   input                         rst,     // Active high Synchronous reset signal
   input  [WIDTH-1:0]            A,       // WIDTH bit input
   input  [WIDTH-1:0]            B,       // WIDTH bit input
   input  [WIDTH-1:0]            C,       // WIDTH bit input
   input                         go,      // Active high Start signal for LCM computation
   output logic  [3 * WIDTH-1:0] OUT,     // Computed LCM. 3*WIDTH bits wide
   output logic                  done     // Signal indicating that the computation is complete
);

   // Internal signals
   logic [WIDTH-1:0] temp_abc, temp_bca, temp_cab;
   logic [3 * WIDTH-1:0] lcm_result;
   logic done_latch;

   // Instantiate gcd_3_ip module
   gcd_3_ip #(
      .WIDTH(WIDTH)
   ) gcd_3_inst (
      .clk(clk),
      .rst(rst),
      .A(A),
      .B(B),
      .go(go),
      .OUT(temp_abc),
      .done(done_latch)
   );

   // Instantiate gcd_3_ip module for intermediate GCD calculations
   gcd_3_ip #(
      .WIDTH(WIDTH)
   ) gcd_2_inst1 (
      .clk(clk),
      .rst(rst),
      .A(temp_bca),
      .B(C),
      .go(go),
      .OUT(temp_abc),
      .done(done_latch)
   );

   gcd_3_ip #(
      .WIDTH(WIDTH)
   ) gcd_2_inst2 (
      .clk(clk),
      .rst(rst),
      .A(temp_abc),
      .B(temp_cab),
      .go(go),
      .OUT(temp_bca),
      .done(done_latch)
   );

   // Calculate LCM using the formula LCM(A, B, C) = (A * B * C) / GCD(GCD(A * B, C), B * C, C * A)
   always_ff @(posedge clk) begin
      if (rst) begin
         lcm_result <= 0;
         done_latch <= 0;
      end else begin
         lcm_result <= (A * B * C) << (3 * WIDTH - WIDTH) / temp_bca;
         done_latch <= (temp_abc == temp_bca) & (temp_abc == temp_cab);
      end
   end

   // Output logic
   assign OUT(lcm_result) = lcm_result;
   assign done = done_latch;

endmodule

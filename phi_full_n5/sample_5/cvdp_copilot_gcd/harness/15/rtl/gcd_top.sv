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

   // Internal signals to hold intermediate LCM values
   logic [3 * WIDTH-1:0] temp_lcm;
   logic done_lcm_latched;

   // Instantiate the gcd_3_ip module
   gcd_3_ip gcd_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (A),
      .B             (B),
      .go            (go),
      .OUT           (gcd_inst.OUT),
      .done          (gcd_inst.done)
   );

   // Calculate LCM using the GCD value
   always_ff @(posedge clk) begin
      if (rst) begin
         temp_lcm <= {WIDTH{1'b0}};
         done_lcm_latched <= 1'b0;
      end else begin
         // Calculate LCM = (A * B * C) / GCD(A * B, B * C, C * A)
         // First, calculate the products
         logic [2 * WIDTH-1:0] product_ab = A * B;
         logic [2 * WIDTH-1:0] product_bc = B * C;
         logic [2 * WIDTH-1:0] product_ca = C * A;

         // Then calculate GCD of the products
         logic [WIDTH-1:0] gcd_product;
         gcd_product = gcd_inst.OUT;

         // Perform division with bit shifting to prevent overflow
         temp_lcm <= (product_ab * product_bc * product_ca) >> (3 * WIDTH - 2 * WIDTH);

         // Latch the LCM result
         if (go & !done_lcm_latched) begin
            done_lcm_latched <= 1'b1;
            OUT <= temp_lcm;
         end else begin
            OUT <= temp_lcm;
         end
      end
   end

   // Ensure OUT and done signals are updated only when go is asserted
   assign OUT = done_lcm_latched ? temp_lcm : {WIDTH{1'b0}};

endmodule

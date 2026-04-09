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

   // Internal signals to accommodate multiplication and division without overflow
   logic [3 * WIDTH-1:0] product_ab_bc;
   logic [3 * WIDTH-1:0] product_abc;
   logic [3 * WIDTH-1:0] gcd_abc;
   logic [3 * WIDTH-1:0] lcm_ab;
   logic [3 * WIDTH-1:0] lcm_bc;
   logic [3 * WIDTH-1:0] lcm_abc;
   logic [3 * WIDTH-1:0] temp_storage;
   logic            calculate_lcm;

   // Instantiate the gcd_3_ip module
   gcd_3_ip #(
      .WIDTH(WIDTH)
   ) gcd_3_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (A),
      .B             (B),
      .go            (go),
      .OUT_ab       (gcd_abc),
      .OUT_bc       (gcd_ab)
   );

   // Calculate products
   assign product_ab_bc = A * B * C;
   assign product_abc = A * B * C;

   // Calculate LCM using GCD
   always_ff @(posedge clk) begin
      if (rst) begin
         lcm_ab <= 0;
         lcm_bc <= 0;
         lcm_abc <= 0;
         temp_storage <= 0;
         calculate_lcm <= 0;
      end else begin
         if(go) begin
            // Perform division to calculate LCM
            lcm_ab <= product_ab_bc / gcd_abc;
            lcm_bc <= product_abc / gcd_ab;
            lcm_abc <= product_abc / gcd_abc;
            temp_storage <= product_abc;
            calculate_lcm <= 1;
         end else begin
            lcm_ab <= lcm_ab;
            lcm_bc <= lcm_bc;
            lcm_abc <= lcm_abc;
            temp_storage <= temp_storage;
         end
      end
   end

   // Assign LCM to OUT
   assign OUT = calculate_lcm ? lcm_abc : temp_storage;

   // Indicate completion of LCM computation
   assign done = calculate_lcm;

endmodule

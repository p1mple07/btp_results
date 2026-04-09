module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
   )(
   input clk,
   input rst,
   input [WIDTH-1:0] A,
   input [WIDTH-1:0] B,
   input [WIDTH-1:0] C,
   input go,
   output [WIDTH-1:0] OUT,   // Updated output width to match parameter WIDTH
   output done
);

   logic gcd_result;     // GCD result
   logic product;        // Intermediate product
   logic gcd_done;
   logic product_ready;

   // Calculate GCD of A, B, and C
   gcd_3_ip #(
      .WIDTH(2*WIDTH)
   ) gcd_inst (
      .clk   (clk),
      .rst   (rst),
      .A     (A),
      .B     (B),
      .C     (C),
      .go    (go),
      .OUT   (gcd_result),
      .done  (gcd_done)
   );

   // Sequential logic for LCM computation
   always_ff @(posedge clk) begin
      if (rst) begin
         OUT <= 0;
         done <= 0;
         product_ready <= 0;
      end else begin
         if (gcd_done) begin
            // Compute |A * B * C|
            product <= A * B * C;
            product_ready <= 1;
         end

         if (product_ready) begin
            // Compute LCM = |A * B * C| / GCD
            OUT <= product / gcd_result;
            done <= 1;
            product_ready <= 0;
         end else begin
            done <= 0;
         end
      end
   end
endmodule

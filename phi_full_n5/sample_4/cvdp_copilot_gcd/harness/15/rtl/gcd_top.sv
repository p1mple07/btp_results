module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
) (
   input                         clk,     // Clock signal
   input                         rst,     // Active high Synchronous reset signal
   input  [WIDTH-1:0]            A,       // WIDTH bit input
   input  [WIDTH-1:0]            B,       // WIDTH bit input
   input  [WIDTH-1:0]            C,       // WIDTH bit input
   input                         go,      // Active high Start signal for LCM computation
   output logic  [3 * WIDTH-1:0] OUT,     // Computed LCM. 3*WIDTH bits wide
   output logic                  done     // Signal indicating that the computation is complete
)
{
   // Internal signals
   logic [3 * WIDTH-1:0] lcm_temp;
   logic [WIDTH-1:0] gcd_result;
   logic done_latched;

   // Instantiate the existing gcd_3_ip module
   gcd_3_ip
   #(
      .WIDTH(WIDTH)
   ) gcd_3_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (A),
      .B             (B),
      .go            (go),
      .OUT           (gcd_result)
   );

   // Calculate LCM using GCD
   assign lcm_temp = A * B * C;
   always_ff @(posedge clk) begin
      if (rst) begin
         OUT <= {WIDTH{1'b0}};
         done_latched <= 1'b0;
      end else if (go) begin
         gcd_result <= gcd_result * (A * B * C) / gcd_result; // Divide by GCD to get LCM
         done_latched <= done_latched;
      end else begin
         OUT <= lcm_temp;
         done_latched <= done_latched;
      end
   end

   // Generate 'done' signal when computation is complete
   assign done = done_latched;

   // Output logic: Update OUT with the computed LCM and set 'done' high
   always_ff @(posedge clk) begin
     if (rst) begin
        OUT <= {WIDTH{1'b0}};
        done <= 1'b0;
     end else if (go) begin
        if (OUT[WIDTH-1:0] == 0) begin
          OUT <= lcm_temp;
          done <= 1'b1;
        end else begin
          OUT <= OUT;
          done <= done_latched;
        end
     end
   end
}

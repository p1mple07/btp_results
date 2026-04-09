module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
   )(
   input                         clk,
   input                         rst,
   input  [WIDTH-1:0]            A,
   input  [WIDTH-1:0]            B,
   input  [WIDTH-1:0]            C,
   input                         go,
   output logic  [WIDTH-1:0] OUT,
   output logic                  done
);

   logic [2*WIDTH-1:0]      gcd_ab;
   logic [WIDTH-1:0]       gcd_bc;
   logic             go_abc;
   logic             done_ab;
   logic             done_bc;
   logic             done_ab_latched;
   logic             done_bc_latched;

   // GCD is calculated for AB and BC in parallel. The GCD for two numbers is lower than the numbers themselves in most cases.
   // And calculating GCD for smaller numbers is comparatively faster using the implemented algorithm.
   // Hence in order to reduce GCD computation latency the calculation is broken up in this fashion.

   gcd_top
   #( .WIDTH(WIDTH)
  ) gcd_A_B_inst (
      .clk           (clk),               // Connect clock signal
      .rst           (rst),               // Connect reset signal
      .A             (A),                // Input operand A
      .B             (B),                // Input operand B
      .go            (go),                // Start signal to begin GCD computation
      .OUT           (gcd_ab),
      .done          (done_ab)
  );

   gcd_top
   #( .WIDTH(WIDTH)
  ) gcd_B_C_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (B),
      .B             (C),
      .go            (go),
      .OUT           (gcd_bc),
      .done          (done_bc)
  );

  gcd_top
  #( .WIDTH(WIDTH)
   ) gcd_ABC_inst (
      .clk           (clk),               // Connect clock signal
      .rst           (rst),               // Connect reset signal
      .A             (gcd_ab),            // Pass gcd_ab to next stage
      .B             (gcd_bc),            // Pass gcd_bc to next stage
      .go            (go_abc),             // Go forward if needed
      .OUT           (OUT),                // Output the LCM
      .done          (done)
  );

  always_ff @ (posedge clk) begin
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

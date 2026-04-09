input  [WIDTH-1:0]            A,
input  [WIDTH-1:0]            B,
input  [WIDTH-1:0]            C,
input                         go,
output logic  [3 * WIDTH-1:0] OUT,   // Updated output width
output logic                  done
);

logic [2*WIDTH-1:0]      gcd_result;     // GCD result
logic [3*WIDTH-1:0]      product;        // Intermediate product
logic                    gcd_done;
logic                    product_ready;
logic [2*WIDTH-1:0]      A_int;
logic [2*WIDTH-1:0]      B_int;
logic [2*WIDTH-1:0]      C_int;

always_comb begin
   A_int = A*B;
   B_int = B*C;
   C_int = C*A;
end

// Calculate GCD of A, B, and C
gcd_3_ip #(
   .WIDTH(2*WIDTH)
) gcd_inst (
   .clk   (clk),
   .rst   (rst),
   .A     (A_int),
   .B     (B_int),
   .C     (C_int),
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

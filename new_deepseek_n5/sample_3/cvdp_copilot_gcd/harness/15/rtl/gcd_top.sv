module lcm_3_ip #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [WIDTH-1:0]        C,
   input                     go,
   output logic  [3*WIDTH-1:0] OUT,
   output logic                  done
);

   // Instantiate the gcd_3_ip module
   gcd_3_ip
   #(
      .WIDTH(WIDTH)
   ) gcd_3_inst (
      .clk(clk),
      .rst(rst),
      .A(A),
      .B(B),
      .C(C),
      .go(go),
      .OUT(out_ab),
      .done(done_ab)
   );

   // Intermediate product registers
   logic [2*WIDTH-1:0] product_ab;  // A * B
   logic [2*WIDTH-1:0] product_bc;  // B * C
   logic [2*WIDTH-1:0] product_ca;  // C * A

   // State encoding for control path
   localparam S0 = 2'd0;    // Initialization state
   localparam S1 = 2'd1;    // Compute A*B
   localparam S2 = 2'd2;    // Compute GCD of A*B and B*C
   localparam S3 = 2'd3;    // Compute LCM using GCD result

   // Sequential logic to compute products and GCD
   always_ff @ (posedge clk) begin
      if (rst) begin
         product_ab <= 0;
         product_bc <= 0;
         product_ca <= 0;
      end else begin
         case (controlpath_state)
            S0: begin
               // Load inputs into registers
               product_ab <= A & B;
               product_bc <= B & C;
               product_ca <= C & A;
            end
            S1: begin
               // Compute A*B
               if (rst) begin
                  out_ab <= 0;
                  done_ab <= 0;
               end else begin
                  out_ab <= product_ab;
                  done_ab <= 1;
               end
            end
            S2: begin
               // Compute GCD of A*B and B*C
               if (rst) begin
                  gcd_ab <= 0;
                  gcd_bc <= 0;
               end else begin
                  gcd_ab <= gcd_3_inst.OUT;
                  gcd_bc <= out_ab;
               end
            end
            S3: begin
               // Compute LCM using formula
               if (rst) begin
                  OUT <= 0;
                  done <= 0;
               end else begin
                  // Compute (A*B*C) / GCD(A*B, B*C, C*A)
                  // Use product_ca as the third operand
                  if (gcd_ab == 0 || gcd_bc == 0) begin
                     // Handle division by zero if necessary
                     OUT <= 0;
                     done <= 0;
                  else begin
                     // Perform division (simplified for illustration)
                     OUT <= (product_ab & product_bc) / gcd_ab;
                     done <= 1;
                  end
               end
            end
            default: begin
               product_ab <= 0;
               product_bc <= 0;
               product_ca <= 0;
               out_ab <= 0;
               done_ab <= 0;
               gcd_ab <= 0;
               gcd_bc <= 0;
               OUT <= 0;
               done <= 0;
            end
         endcase
      end
   end

   // Control path FSM
   module gcd_controlpath (
      input                    clk,
      input                    rst,
      input                    go,
      input                    equal,
      input                    greater_than,
      output logic [1:0]       controlpath_state,
      output logic             done
   );

   // State encoding
   logic [1:0] curr_state = S0;
   logic [1:0] next_state;

   // State latching logic
   always_ff @ (posedge clk) begin
      if (rst) begin
         curr_state <= S0;
      end else begin
         curr_state <= next_state;
      end
   end

   // State transition logic
   always_comb begin
      case(curr_state)
         S0: begin
            if(!go) begin
               next_state = S0;
            else if (equal) begin
               next_state = S1;
            else if (greater_than) begin
               next_state = S2;
            else begin
               next_state = S3;
            end
         end
         S1: begin
            next_state = S2;
         end
         S2: begin
            if(equal) begin
               next_state = S1;
            else if (greater_than) begin
               next_state = S2;
            else begin
               next_state = S3;
            end
         end
         S3: begin
            if(equal) begin
               next_state = S1;
            else if (greater_than) begin
               next_state = S2;
            else begin
               next_state = S3;
            end
         end
         default: next_state = S0;
      endcase
   end

   // Output logic
   always_ff @ (posedge clk) begin
      if(rst) begin
         done <= 0;
      end else begin
         done <= (curr_state == S3);
      end
   end

   // Assign control path state
   assign controlpath_state = curr_state;
endmodule
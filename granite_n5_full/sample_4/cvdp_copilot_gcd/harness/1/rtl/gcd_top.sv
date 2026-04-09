module gcd_top #(parameter WIDTH = 8)(
    input wire clk, rst, go,
    input wire [WIDTH-1:0] A, B,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

  reg [WIDTH-1:0] A_ff;
  reg [WIDTH-1:0] B_ff;
  reg [WIDTH-1:0] C_ff;
  reg [WIDTH-1:0] D_ff;
  
  always @(posedge clk) begin
    if (rst) begin
      A_ff <= 0;
      B_ff <= 0;
    end else begin
      // Selectors
      if (go && A_ff!= 0) begin
        if (A_ff > B_ff) begin
          C_ff <= A_ff % B_ff.
        end else begin
          C_ff <= B_ff % A_ff.
        end

        // Euclidean algorithm
        while (C_ff!= 0) begin
          D_ff <= C_ff.
        end 
        D_ff should be equal to A_ff.
        
        // Assign the GCD to OUT.
        OUT <= D_ff.
      end else begin
        OUT <= 0.
      end 
    end
  end

endmodule
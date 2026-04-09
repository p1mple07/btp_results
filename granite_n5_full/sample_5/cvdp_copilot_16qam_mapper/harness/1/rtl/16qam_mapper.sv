module qam16_mapper_interpolated #(
  parameter int N = 4, // Number of input symbols
  parameter int IN_WIDTH = 4, // Bit width of each input symbol (fixed)
  parameter int OUT_WIDTH = 3 // Bit width of the output components (fixed)
)(
  input logic [N*IN_WIDTH-1:0] bits, // Packed input bits
  output logic [(N+N/2)*OUT_WIDTH-1:0] I, // Packed output of real (I) components
  output logic [(N+N/2)*OUT_WIDTH-1:0] Q // Packed output of imaginary (Q) components
);

  localparam int INTERPOLATION_WIDTH = OUT_WIDTH + 1;
  logic [INTERPOLATION_WIDTH-1:0] I_interpolation[N-1];
  logic [INTERPOLATION_WIDTH-1:0] Q_interpolation[N-1];

  always_comb begin
    for (int i = 0; i < N-1; i++) begin
      if (i == 0) begin
        I_interpolation[i] = {{OUT_WIDTH{bits[i*IN_WIDTH + IN_WIDTH-1]}}, bits[i*IN_WIDTH + IN_WIDTH-2:IN_WIDTH]};
        Q_interpolation[i] = {{OUT_WIDTH{bits[i*IN_WIDTH + IN_WIDTH-1]}}, bits[i*IN_WIDTH + IN_WIDTH-2:IN_WIDTH]};
      end else begin
        I_interpolation[i] = {(I_interpolation[i-1][INTERPOLATION_WIDTH-1] + I_interpolation[i][INTERPOLATION_WIDTH-1]) / 2, I_interpolation[i][OUT_WIDTH-1:0]};
        Q_interpolation[i] = {(Q_interpolation[i-1][INTERPOLATION_WIDTH-1] + Q_interpolation[i][INTERPOLATION_WIDTH-1]) / 2, Q_interpolation[i][OUT_WIDTH-1:0]};
      end
    end
  end

  assign I = {I_interpolation[0][OUT_WIDTH-1:0], I_interpolation};
  assign Q = {Q_interpolation[0][OUT_WIDTH-1:0], Q_interpolation};

endmodule
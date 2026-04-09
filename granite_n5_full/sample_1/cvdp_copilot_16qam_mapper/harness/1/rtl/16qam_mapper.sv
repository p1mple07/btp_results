module qam16_mapper_interpolated #(
  parameter int unsigned N = 4, // Number of input symbols
  parameter int unsigned IN_WIDTH = 4, // Bit width of each input symbol
  parameter int unsigned OUT_WIDTH = 3 // Bit width of the output components
)(
  input logic [N*IN_WIDTH-1:0] bits, // Packed input bits
  output logic [(N + N/2)*OUT_WIDTH-1:0] I, // Packed output of real (I) components
  output logic [(N + N/2)*OUT_WIDTH-1:0] Q // Packed output of imaginary (Q) components
);

  localparam int unsigned INTERPOLATED_WIDTH = OUT_WIDTH + 1; // Width of interpolated samples

  // Mapping input bits to real (I) and imaginary (Q) components
  always_comb begin
    I[INTERPOLATED_WIDTH*(N+N/2)-1:INTERPOLATED_WIDTH] = '0;
    Q[INTERPOLATED_WIDTH*(N+N/2)-1:INTERPOLATED_WIDTH] = '0;

    for (int i = 0; i < N; i++) begin
      int idx = INTERPOLATED_WIDTH * i;

      case (bits[INTERPOLATED_WIDTH*(i+1)-2:INTERPOLATED_WIDTH*i])
        2'b00: begin
          I[idx + INTERPOLATED_WIDTH-1:idx] = 3'd-3;
          Q[idx + INTERPOLATED_WIDTH-1:idx] = 3'd-3;
        end
        2'b01: begin
          I[idx + INTERPOLATED_WIDTH-1:idx] = 3'd-1;
          Q[idx + INTERPOLATED_WIDTH-1:idx] = 3'd-1;
        end
        2'b10: begin
          I[idx + INTERPOLATED_WIDTH-1:idx] = 3'd1;
          Q[idx + INTERPOLATED_WIDTH-1:idx] = 3'd1;
        end
        2'b11: begin
          I[idx + INTERPOLATED_WIDTH-1:idx] = 3'd3;
          Q[idx + INTERPOLATED_WIDTH-1:idx] = 3'd3;
        end
      endcase
    end
  end

  // Interpolation of real (I) and imaginary (Q) components
  generate if (N % 2 == 0) begin : odd_n
    assign I[(N+1)*INTERPOLATED_WIDTH-1:(N-1)*INTERPOLATED_WIDTH] = I[(N-1)*INTERPOLATED_WIDTH+INTERPOLATED_WIDTH-1:(N-1)*INTERPOLATED_WIDTH];
    assign Q[(N+1)*INTERPOLATED_WIDTH-1:(N-1)*INTERPOLATED_WIDTH] = Q[(N-1)*INTERPOLATED_WIDTH+INTERPOLATED_WIDTH-1:(N-1)*INTERPOLATED_WIDTH];
  end else begin : even_n
    assign I[(N+1)*INTERPOLATED_WIDTH-1:N*INTERPOLATED_WIDTH] = I[(N-1)*INTERPOLATED_WIDTH+INTERPOLATED_WIDTH-1:N*INTERPOLATED_WIDTH];
    assign Q[(N+1)*INTERPOLATED_WIDTH-1:N*INTERPOLATED_WIDTH] = Q[(N-1)*INTERPOLATED_WIDTH+INTERPOLATED_WIDTH-1:N*INTERPOLATED_WIDTH];
  end endgenerate

  // Output arrangement
  assign I[INTERPOLATED_WIDTH*N-1:INTERPOLATED_WIDTH] = bits[INTERPOLATED_WIDTH*N-1:INTERPOLATED_WIDTH*N-INTERPOLATED_WIDTH];
  assign Q[INTERPOLATED_WIDTH*N-1:INTERPOLATED_WIDTH] = bits[INTERPOLATED_WIDTH*N-2:INTERPOLATED_WIDTH*N-INTERPOLATED_WIDTH-1];

endmodule
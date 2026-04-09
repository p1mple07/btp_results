module cic_decimator #(parameter WIDTH = 16, RMAX = 2, M = 1, N = 2)(
  input wire clk,
  input wire rst,

  // Input side
  input wire [WIDTH-1:0] input_tdata,
  input wire input_tvalid,
  output reg input_tready,

  // Output side
  output wire [WIDTH-1:0] output_tdata,
  output reg output_tvalid,
  input wire output_tready,

  // Control signals
  input wire [WIDTH+1:0] rate
);

  localparam REG_WIDTH = WIDTH + $clog2((RMAX * M)**N);

  // Define internal signals
  reg [REG_WIDTH-1:0] integrator_accum [N];
  reg [WIDTH-1:0] comb_delay [M-1:0];
  reg [$clog2(RMAX)-1:0] cycle_reg;
  reg output_sample_valid;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_reg <= 0;
      integrator_accum <= {REG_WIDTH{1'b0}};
      comb_delay <= {M-1{1'b0}};
      output_sample_valid <= 1'b0;
    end else begin
      if ((input_tvalid && ~input_tready) || (output_tvalid && ~output_tready)) begin
        cycle_reg <= 0;
      end else begin
        if (input_tvalid) begin
          cycle_reg <= cycle_reg + 1;
          integrator_accum[0] <= integrator_accum[0] + input_tdata;
          for (int i = 1; i < N; i++) begin
            integrator_accum[i] <= integrator_accum[i-1];
          end
        end

        if ((rate - 1) <= cycle_reg && cycle_reg < rate) begin
          output_sample_valid <= 1'b1;
          comb_delay[0] <= input_tdata;
          for (int i = 1; i < M; i++) begin
            comb_delay[i] <= integrator_accum[N-1][WIDTH-1:0] - integrator_accum[N-2][WIDTH-1:0];
          end
        end
      end
    end
  end

  assign output_tdata = comb_delay[M-1];
  assign output_tvalid = output_sample_valid;

endmodule
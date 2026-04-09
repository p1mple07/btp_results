module sigma_delta_audio
(
  input   clk_sig,
  input   clk_en_sig,
  input  [14:0] load_data_sum,
  input  [14:0] read_data_sum,
  output  reg left_sig,
  output  reg right_sig
);

localparam DATA_WIDTH = 15;
localparam CLOCK_WIDTH = 2;
localparam READ_WIDTH  = 4;
localparam A1_WIDTH = 2;
localparam A2_WIDTH = 5;

wire [DATA_WIDTH+2] l_er0, r_er0;
reg [DATA_WIDTH+2] l_er0_prev, r_er0_prev;
wire [DATA_WIDTH+A1_WIDTH+2] l_aca1,  r_aca1;
wire [DATA_WIDTH+A2_WIDTH+2] l_aca2,  r_aca2;
reg [DATA_WIDTH+A1_WIDTH+2] l_ac1, r_ac1;
reg [DATA_WIDTH+A2_WIDTH+2] l_ac2, r_ac2;
wire [DATA_WIDTH+A2_WIDTH+3] l_quant;

reg [24-1:0] seed_1 = 24'h654321;
reg [19-1:0] seed_2 = 19'h12345;
reg [DATA_WIDTH+2] s_sum, s_prev, s_out;

// Timing control: Remove redundant timing control logic
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    if (&seed_1)
      seed_1 <= #1 seed_1;
    else
      seed_1 <= #1 {seed_1[22:0], ~(seed_1[23] ^ seed_1[22] ^ seed_1[21] ^ seed_1[16])};

    if (&seed_2)
      seed_2 <= #1 seed_2;
    else
      seed_2 <= #1 {seed_2[17:0], ~(seed_2[18] ^ seed_2[17] ^ seed_2[16] ^ seed_2[13] ^ seed_2[0])};

    s_sum  <= #1 seed_1 + seed_2;
    s_prev <= #1 s_sum;
    s_out  <= #1 s_sum - s_prev;
  end
end

localparam INPUT_DATA = 4;
reg [INPUT_DATA+0-1:0] integer_count = 0;

// Remove redundant timing control logic
always @ (posedge clk_sig) begin
  integer_count <= #1 integer_count;
end

reg [DATA_WIDTH+0-1:0] ldata_current, ldata_previous, rdata_current, rdata_previous;
wire [DATA_WIDTH+1-1:0] load_data_step, read_data_step;
reg [DATA_WIDTH+INPUT_DATA-1:0] load_data_int, read_data_int;
wire [DATA_WIDTH+0-1:0] load_data_int_out, read_data_int_out;

assign load_data_step = ldata_current - ldata_previous;
assign read_data_step = rdata_current - rdata_previous;

// Remove redundant logic for load and read data
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    if (~integer_count) begin
      ldata_previous <= ldata_current;
      ldata_current  <= load_data_sum;
      rdata_previous <= rdata_current;
      rdata_current  <= read_data_sum;
      load_data_int  <= load_data_sum;
      read_data_int  <= read_data_sum;
    end else begin
      load_data_int  <= load_data_int + {INPUT_DATA{load_data_step[DATA_WIDTH+1-1]}, load_data_step};
      read_data_int  <= read_data_int + {INPUT_DATA{read_data_step[DATA_WIDTH+1-1]}, read_data_step};
    end
  end
end

assign load_data_int_out = load_data_int[DATA_WIDTH+INPUT_DATA-1:INPUT_DATA];
assign read_data_int_out = read_data_int[DATA_WIDTH+INPUT_DATA-1:INPUT_DATA];

wire [DATA_WIDTH+2-1:0] load_data_gain, read_data_gain;
assign load_data_gain = load_data_int_out + {DATA_WIDTH-1, load_data_int_out};
assign read_data_gain = read_data_int_out + {DATA_WIDTH-1, read_data_int_out};

// Remove redundant logic for accumulators
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    l_ac1 <= #1 l_aca1;
    r_ac1 <= #1 r_aca1;
    l_ac2 <= #1 l_aca2;
    r_ac2 <= #1 r_aca2;
  end
end

assign l_aca1 = load_data_gain - l_er0 + l_ac1;
assign r_aca1 = read_data_gain - r_er0 + r_ac1;
assign l_aca2 = l_aca1 - {A2_WIDTH-A1_WIDTH}{l_er0} - {A2_WIDTH}{l_er0_prev} + l_ac2;
assign r_aca2 = r_aca1 - {A2_WIDTH-A1_WIDTH}{r_er0} - {A2_WIDTH}{r_er0_prev} + r_ac2;

// Simplify quantization logic
assign l_quant = l_ac2 + {DATA_WIDTH+A2_WIDTH+3-READ_WIDTH}{s_out[READ_WIDTH-1]};
assign r_quant = r_ac2 + {DATA_WIDTH+A2_WIDTH+3-READ_WIDTH}{s_out[READ_WIDTH-1]};

// Use non-blocking assignments for outputs
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    left_sig <= ~l_quant[DATA_WIDTH+A2_WIDTH+3-1] ? 1'b0 : 1'b1;
    right_sig <= ~r_quant[DATA_WIDTH+A2_WIDTH+3-1] ? 1'b0 : 1'b1;
  end
end

endmodule

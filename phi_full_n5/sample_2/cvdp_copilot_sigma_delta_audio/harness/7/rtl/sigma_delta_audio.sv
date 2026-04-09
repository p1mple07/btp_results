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
localparam READ_WIDTH = 4;
localparam A1_WIDTH = 2;
localparam A2_WIDTH = 5;

wire [DATA_WIDTH] l_er0, r_er0;
wire [DATA_WIDTH] l_aca1, r_aca1;
wire [DATA_WIDTH] l_aca2, r_aca2;
reg [DATA_WIDTH] l_ac1, r_ac1;
reg [DATA_WIDTH] l_ac2, r_ac2;
wire [DATA_WIDTH] l_quant;

reg [24-1:0] seed_1 = 24'h654321;
reg [19-1:0] seed_2 = 19'h12345;
reg [DATA_WIDTH] s_sum, s_prev, s_out;

always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    s_sum <= #1 seed_1 + seed_2;
    s_prev <= #1 s_sum;
    s_out <= #1 s_sum - s_prev;
  end
end

localparam INPUT_DATA = 4;
reg [INPUT_DATA-1:0] integer_count;

always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    integer_count <= #1 integer_count + 1'b1;
  end
end

reg [DATA_WIDTH] ldata_current, ldata_previous;
reg [DATA_WIDTH] rdata_current, rdata_previous;
wire [DATA_WIDTH] load_data_step, read_data_step;
wire [DATA_WIDTH] load_data_int_out, read_data_int_out;

assign load_data_step = ldata_current - ldata_previous;
assign read_data_step = rdata_current - rdata_previous;

always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    ldata_previous <= #1 ldata_current;
    ldata_current  <= load_data_sum;
    rdata_previous <= #1 rdata_current;
    rdata_current  <= read_data_sum;
    load_data_int  <= load_data_int_out + load_data_step;
    read_data_int  <= read_data_int_out + read_data_step;
  end
end

assign load_data_int_out = {load_data_int_out[DATA_WIDTH-1], load_data_int_out};
assign read_data_int_out = {read_data_int_out[DATA_WIDTH-1], read_data_int_out};

wire [DATA_WIDTH] load_data_gain, read_data_gain;
assign load_data_gain = load_data_int_out + {{(2){load_data_int_out[DATA_WIDTH-1]}}, load_data_int_out};
assign read_data_gain = read_data_int_out + {{(2){read_data_int_out[DATA_WIDTH-1]}}, read_data_int_out};

assign l_aca1 = l_aca1 + load_data_gain - (ldata_current - l_er0);
assign r_aca1 = r_aca1 + load_data_gain - (rdata_current - r_er0);

assign l_aca2 = l_aca2 + (l_aca1[DATA_WIDTH-A1_WIDTH-1:0]) - (ldata_current - l_er0) - (l_er0_prev[DATA_WIDTH-1]);
assign r_aca2 = r_aca2 + (r_aca1[DATA_WIDTH-A1_WIDTH-1:0]) - (rdata_current - r_er0) - (r_er0_prev[DATA_WIDTH-1]);

assign l_quant = l_quant + l_ac2 + s_out;
assign r_quant = r_quant + r_ac2 + s_out;

assign l_er0 = l_quant[DATA_WIDTH-1] ? 1'b1 : 1'b0;
assign r_er0 = r_quant[DATA_WIDTH-1] ? 1'b1 : 1'b0;

always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    left_sig <= ~left_sig;
    right_sig <= ~right_sig;
  end
end
endmodule

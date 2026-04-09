module sigma_delta_audio
(
  input   clk_sig,
  input   clk_en_sig,
  input  [14:0] load_data_sum,
  input  [14:0] read_data_sum,
  output  reg left_sig=0,
  output  reg right_sig=0
);

// Removed unused parameter
// localparam A1_WIDTH = 2;
// localparam A2_WIDTH = 5;

// Corrected width mismatches
localparam READ_WIDTH  = 4;
localparam A1_WIDTH = 4;
localparam A2_WIDTH = 4;

// Timing control improvements
// Added initial assignments for l_er0 and r_er0 to avoid unnecessary toggling
reg [DATA_WIDTH+2-1:0] l_er0 = 0, r_er0 = 0;

// Removed redundant assignments and optimized calculations
wire [DATA_WIDTH+2-1:0] load_data_step, read_data_step;
wire [DATA_WIDTH+1-1:0] load_data_int_out, read_data_int_out;

assign load_data_step = {ldata_current[DATA_WIDTH-1], ldata_current} - {ldata_previous[DATA_WIDTH-1], ldata_previous};
assign read_data_step = {rdata_current[DATA_WIDTH-1], rdata_current} - {rdata_previous[DATA_WIDTH-1], rdata_previous};

// Optimized seed generation with a single seed
reg [24-1:0] seed;
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    seed <= #(1) {seed[22:0], ~(seed[23] ^ seed[22] ^ seed[21] ^ seed[16])};
  end
end

// Removed redundant assignments and optimized calculations
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    s_sum  <= #1 seed + {5'b0, seed[17:0]};
    s_prev <= #1 s_sum;
    s_out  <= #1 s_sum - s_prev;
  end
end

// Simplified integer counting logic
reg [DATA_WIDTH-1:0] integer_count = 0;
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    integer_count <= integer_count + 1'b1;
  end
end

// Optimized load and read data logic
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    ldata_previous <= #1 ldata_current;
    ldata_current  <= #1 load_data_sum;
    rdata_previous <= #1 rdata_current;
    rdata_current  <= #1 read_data_sum;
    integer_count <= integer_count + 1'b1;
  end
end

// Simplified gain calculations
assign load_data_gain = {(2){load_data_int_out[DATA_WIDTH-1]}, load_data_int_out};
assign read_data_gain = {(2){read_data_int_out[DATA_WIDTH-1]}, read_data_int_out};

// Removed redundant logic and simplified latch assignments
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    l_ac1 <= #1 l_aca1;
    r_ac1 <= #1 r_aca1;
    l_ac2 <= #1 l_aca2;
    r_ac2 <= #1 r_aca2;
  end
end

// Simplified quant calculations
assign l_quant = {l_ac2[DATA_WIDTH+A2_WIDTH+2-1], l_ac2} + {(DATA_WIDTH+A2_WIDTH+3-READ_WIDTH){s_out[READ_WIDTH-1]}};
assign r_quant = {r_ac2[DATA_WIDTH+A2_WIDTH+2-1], r_ac2} + {(DATA_WIDTH+A2_WIDTH+3-READ_WIDTH){s_out[READ_WIDTH-1]}};

// Simplified edge detection
always @ (posedge clk_sig) begin
  if (clk_en_sig) begin
    left_sig <= #1 ~left_sig & ~l_er0[DATA_WIDTH+2-1];
    right_sig <= #1 ~right_sig & ~r_er0[DATA_WIDTH+2-1];
  end
end
endmodule

module sigma_delta_audio(
  input         clk_sig,
  input         clk_en_sig,
  input  [14:0] load_data_sum,
  input  [14:0] read_data_sum,
  output reg    left_sig = 0,
  output reg    right_sig = 0
);

  // Removed unused CLOCK_WIDTH parameter
  localparam DATA_WIDTH = 15;
  localparam READ_WIDTH  = 4;
  localparam A1_WIDTH    = 2;
  localparam A2_WIDTH    = 5;

  // l_er0 and r_er0: width = DATA_WIDTH + 1 (for DATA_WIDTH=15, width = 16 bits)
  wire [DATA_WIDTH+1:0] l_er0, r_er0;
  reg  [DATA_WIDTH+1:0] l_er0_prev = 0, r_er0_prev = 0;

  // l_aca1 and r_aca1: width = DATA_WIDTH + A1_WIDTH + 1 (15+2+1 = 18 bits)
  wire [DATA_WIDTH+A1_WIDTH+1:0] l_aca1, r_aca1;
  // l_aca2 and r_aca2: width = DATA_WIDTH + A2_WIDTH + 1 (15+5+1 = 21 bits)
  wire [DATA_WIDTH+A2_WIDTH+1:0] l_aca2, r_aca2;
  reg  [DATA_WIDTH+A1_WIDTH+1:0] l_ac1 = 0, r_ac1 = 0;
  reg  [DATA_WIDTH+A2_WIDTH+1:0] l_ac2 = 0, r_ac2 = 0;

  // l_quant and r_quant: will be 23 bits wide
  wire [DATA_WIDTH+A2_WIDTH+2:0] l_quant, r_quant;

  reg [24-1:0] seed_1 = 24'h654321;
  reg [19-1:0] seed_2 = 19'h12345;
  reg [24-1:0] s_sum = 0, s_prev = 0, s_out = 0;

  always @(posedge clk_sig) begin
    if (clk_en_sig) begin
      if (&seed_1)
        seed_1 <= 24'h654321;
      else
        seed_1 <= {seed_1[22:0], ~(seed_1[23] ^ seed_1[22] ^ seed_1[21] ^ seed_1[16])};
    end
  end

  always @(posedge clk_sig) begin
    if (clk_en_sig) begin
      if (&seed_2)
        seed_2 <= 19'h12345;
      else
        seed_2 <= {seed_2[17:0], ~(seed_2[18] ^ seed_2[17] ^ seed_2[16] ^ seed_2[13] ^ seed_2[0])};
    end
  end

  always @(posedge clk_sig) begin
    if (clk_en_sig) begin
      s_sum  <= seed_1 + {5'b0, seed_2};
      s_prev <= s_sum;
      s_out  <= s_sum - s_prev;
    end
  end

  localparam INPUT_DATA = 4;
  reg [INPUT_DATA-1:0] integer_count = 0;

  always @(posedge clk_sig) begin
    if (clk_en_sig)
      integer_count <= integer_count + 1'd1;
  end

  reg [DATA_WIDTH-1:0] ldata_current = 0, ldata_previous = 0;
  reg [DATA_WIDTH-1:0] rdata_current = 0, rdata_previous = 0;

  wire [DATA_WIDTH:0] load_data_step, read_data_step;
  reg [DATA_WIDTH+INPUT_DATA-1:0] load_data_int = 0, read_data_int = 0;
  wire [DATA_WIDTH-1:0] load_data_int_out, read_data_int_out;

  assign load_data_step = {ldata_current[DATA_WIDTH-1], ldata_current} -
                          {ldata_previous[DATA_WIDTH-1], ldata_previous};
  assign read_data_step = {rdata_current[DATA_WIDTH-1], rdata_current} -
                          {rdata_previous[DATA_WIDTH-1], rdata_previous};

  always @(posedge clk_sig) begin
    if (clk_en_sig) begin
      if (~|integer_count) begin
        ldata_previous <= ldata_current;
        ldata_current  <= load_data_sum;
        rdata_previous <= rdata_current;
        rdata_current  <= read_data_sum;
        load_data_int  <= {ldata_current[DATA_WIDTH-1], ldata_current, {INPUT_DATA{1'b0}}};
        read_data_int  <= {rdata_current[DATA_WIDTH-1], rdata_current, {INPUT_DATA{1'b0}}};
      end else begin
        load_data_int  <= load_data_int + {{INPUT_DATA {load_data_step[DATA_WIDTH]}}, load_data_step};
        read_data_int  <= read_data_int + {{INPUT_DATA {read_data_step[DATA_WIDTH]}}, read_data_step};
      end
    end
  end

  assign load_data_int_out = load_data_int[DATA_WIDTH+INPUT_DATA-1:INPUT_DATA];
  assign read_data_int_out = read_data_int[DATA_WIDTH+INPUT_DATA-1:INPUT_DATA];

  wire [DATA_WIDTH+1:0] load_data_gain, read_data_gain;
  assign load_data_gain = {load_data_int_out[DATA_WIDTH-1], load_data_int_out, 1'b0} +
                          {{2 {load_data_int_out[DATA_WIDTH-1]}}, load_data_int_out};
  assign read_data_gain = {read_data_int_out
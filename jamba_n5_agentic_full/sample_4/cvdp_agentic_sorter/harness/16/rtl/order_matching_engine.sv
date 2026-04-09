module order_matching_engine #(
    parameter WIDTH = 8
)(
    input                     clk,
    input                     rst,
    input                    start,
    input  [8*WIDTH-1:0]    bid_orders,
    input  [8*WIDTH-1:0]    ask_orders,
    output reg              match_valid,
    output reg [8*WIDTH-1:0] matched_price,
    output reg              done,
    output reg              latency_error
);

  // Instantiate the sorting engine for bid orders
  localparam INPUTS_COUNT = 8;
  wire [WIDTH-1:0] bid_sorted[0:INPUTS_COUNT];
  wire [WIDTH-1:0] ask_sorted[0:INPUTS_COUNT];

  sorting_engine #(.WIDTH(WIDTH)) uut_bid (.clk(clk), .rst(rst), .start(start), .in_data(bid_orders), .out_data(bid_sorted));
  assign bid_sorted = uut_bid.out_data;

  sorting_engine #(.WIDTH(WIDTH)) uut_ask (.clk(clk), .rst(rst), .start(start), .in_data(ask_orders), .out_data(ask_sorted));
  assign ask_sorted = uut_ask.out_data;

  // Find the best bid (maximum)
  wire [WIDTH-1:0] best_bid;
  always @(posedge clk) begin
    best_bid = -1;
    for (int i = 0; i < INPUTS_COUNT; i = i + 1) begin
      if (bid_sorted[i] > best_bid) begin
        best_bid = bid_sorted[i];
      end
    end
  end

  // Find the best ask (minimum)
  wire [WIDTH-1:0] best_ask;
  always @(posedge clk) begin
    best_ask = 16'hFFFFFFFF; // Max possible value
    for (int i = 0; i < INPUTS_COUNT; i = i + 1) begin
      if (ask_sorted[i] < best_ask) begin
        best_ask = ask_sorted[i];
      end
    end
  end

  // Check if best bid >= best ask
  always @(posedge clk) begin
    if (match_valid) begin
      if (best_bid >= best_ask) begin
        match_valid = 1;
        matched_price = best_ask;
      end else begin
        match_valid = 0;
        matched_price = 0;
      end
    end else
      match_valid = 0;
  end

  // Latency measurement
  reg [2:0] cycles;
  always @(posedge clk) begin
    if (!rst) begin
      cycles <= 3'd0;
    end else begin
      cycles <= cycles + 1;
    end
  end

  always @(posedge clk) begin
    if (cycles == 21) begin
      done <= 1;
    end else
      done <= 0;
  end

endmodule

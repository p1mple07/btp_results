module order_matching_engine #(parameter PRICE_WIDTH = 16)(
    input                    clk,
    input                    rst,
    input                    start,         // Start matching operation
    input  [8*PRICE_WIDTH-1:0] bid_orders,    // 8 bid orders (flat vector)
    input  [8*PRICE_WIDTH-1:0] ask_orders,    // 8 ask orders (flat vector)
    output reg                 match_valid,   // high if a match occurs
    output reg [PRICE_WIDTH-1:0] matched_price, // matched price (best ask)
    output reg                 done,          // matching engine done
    output reg                 latency_error  // asserted if latency ≠ 20 cycles
)

  // Instantiate the sorting engines
  sorting_engine #(.WIDTH(PRICE_WIDTH)) sorted_bids (
      .clk(clk),
      .rst(rst),
      .start(start),
      .in_data[bid_orders],
      .done,
      .out_data[sorted_bids_out]
  );

  sorting_engine #(.WIDTH(PRICE_WIDTH)) sorted_asks (
      .clk(clk),
      .rst(rst),
      .start(start),
      .in_data[ask_orders],
      .done,
      .out_data[sorted_asks_out]
  );

  // Extract best bid and ask
  reg [PRICE_WIDTH-1:0] best_bid = sorted_bids_out[7*PRICE_WIDTH:0];
  reg [PRICE_WIDTH-1:0] best_ask = sorted_asks_out[0*PRICE_WIDTH:0];

  // Compare and determine match
  assign match_valid = (best_bid >= best_ask);
  assign matched_price = best_ask;

  // Ensure total latency is 21 cycles
  integer t = 0;
  always @posedgeclk begin
    if (!rst) begin
      t = 0;
      done <= 0;
      latency_error <= 0;
    end else if (start) begin
      t <= t + 1;
      done <= 1;
      latency_error <= 0;
      
      // After sorting and matching, wait one extra cycle for final validation
      if (t == 20) begin
        latency_error <= 1;
      end
    end
  end

endmodule
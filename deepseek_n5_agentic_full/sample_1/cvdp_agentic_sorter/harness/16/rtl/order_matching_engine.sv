module order_matching_engine #(parameter PRICE_WIDTH = 16)(
    input                     clk,
    input                     rst,
    input                     start, 
    input  [8*PRICE_WIDTH-1:0] bid_orders,
    input  [8*PRICE_WIDTH-1:0] ask_orders,
    output reg                 match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg                 done,
    output reg                 latency_error
)

  // Instantiate sorting engines for bid and ask orders
  sorting_engine bid_sorter #(.WIDTH(PRICE_WIDTH))(
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_data[bid_orders],
        .done,
        .out_data[.output(0:0)]
  );

  sorting_engine ask_sorter #(.WIDTH(PRICE_WIDTH))(
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_data[ask_orders],
        .done,
        .out_data[.output(0:0)]
  );

  // Variables for extracting max bid and min ask
  reg [PRICE_WIDTH-1:0] max_bid, min_ask;
  reg [PRICE_WIDTH-1:0] * sorted_bids, *sortedAsks;

  // Variables for matching logic
  reg match_valid_local;
  reg [PRICE_WIDTH-1:0] matched_price_local;
  reg [3:0] count;

  // Main control logic
  always @(posedge_clk or posedge_rst) begin
    if (rst) begin
      bid_sorter.reset();
      ask_sorter.reset();
      state = IDLE;
    elsif start begin
      state = STARTING;
    end
  end

  // Extract sorted data
  case(state) 
    IDLE: begin
      state = STARTING;
      // Start both sorting engines
      // ...
    STARTING: begin
      // Wait for both sorting engines to complete
      while (!bid_sorter.done || !ask_sorter.done) {
        // Do nothing here except wait
        // ...
      }
      
      // Extract max bid and min ask
      max_bid = bid_sorter.out_data[7*PRICE_WIDTH:0];
      min_ask = ask_sorter.out_data[0*PRICE_WIDTH:0];
      
      // Compare and determine match
      if (max_bid >= min_ask) begin
        match_valid_local = 1;
        matched_price_local = min_ask;
      else
        match_valid_local = 0;
        // Set matched_price to a default value if no match
        // ...
      end
      
      // Update global states
      match_valid <= match_valid_local;
      matched_price <= matched_price_local;
      
      // Mark completion
      done <= 1;
      
      // Optional: Reset sorting engines
      bid_sorter.reset();
      ask_sorter.reset();
      
      // Return to idle state
      state <= IDLE;
    end
  end
endmodule
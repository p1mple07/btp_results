module order_matching_engine #(parameter PRICE_WIDTH = 16)(
    input     clk,
    input     rst,
    input     start,
    input  [8*PRICE_WIDTH-1:0] bid_orders,
    input  [8*PRICE_WIDTH-1:0] ask_orders,
    output reg   match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg   done,
    output reg   latency_error
);

  localparam IDLE     = 3'd0,
             LOAD     = 3'd1,
             SORT_BIDS = 3'd2,
             SORT_ASKS = 3'd3,
             GET Match = 3'd4,
             POST     = 3'd5,

  reg [2:0] state;

  // Internal storage for bid and ask orders
  reg [WIDTH-1:0] bid_reg [8];
  reg [WIDTH-1:0] ask_reg [8];

  // Variables for extracted orders
  reg [WIDTH-1:0] best_bid, best_ask;

  // Counter for latency measurement
  reg latency_counter = 0;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state = IDLE;
      done = 0;
      match_valid = 0;
      best_bid = 0;
      best_ask = 0;
      latency_counter = 0;
    else begin
      case (state)
        IDLE: begin
          done = 0;
          state = LOAD;
          // Load bid orders
          for (int i = 0; i < 8; i = i + 1) begin
            bid_reg[i] <= bid_orders[i * WIDTH +: WIDTH];
          end
          // Load ask orders
          for (int i = 0; i < 8; i = i + 1) begin
            ask_reg[i] <= ask_orders[i * WIDTH +: WIDTH];
          end
          state = SORT_BIDS;
        end

        SORT_BIDS: begin
          // Sort bid orders
          // (Assuming bid_orders is already loaded via the above loop)
          // Using sorting_engine for bid orders
          // Wire bid_orders to sorting_engine's in_data
          reg [8*WIDTH-1:0] sorted_bids;
          assign sorted_bids = bid_reg;
          // Create a temporary register to hold the sorted results
          reg [8*WIDTH-1:0] temp_bids;
          // Copy sorted_bids to temp_bids
          temp_bids = sorted_bids;
          // Sort the bids
          assign temp_bids -> sorting_engine.in_data;
          // Wait for sorting_engine to complete (20 cycles)
          // After 20 cycles, the final_sorted is in sorting_engine.final_sorted
          // Wire the final_sorted to best_bid
          assign best_bid = sorting_engine.final_sorted[7];
          // Set state to SORT_ASKS
          state = SORT_ASKS;
          // Increment latency counter while waiting
          latency_counter <= latency_counter + 1;
        end

        SORT_ASKS: begin
          // Sort ask orders similarly
          // (Assume ask_orders is already loaded via the above loop)
          // Wire ask_orders to sorting_engine's in_data
          reg [8*WIDTH-1:0] sortedAsks;
          assign sortedAsks = ask_reg;
          reg [8*WIDTH-1:0] temp_Ask;
          temp_Ask = sortedAsks;
          assign temp_Ask -> sorting_engine.in_data;
          // Wait for sorting_engine to complete
          // After 20 cycles, the final_sorted is in sorting_engine.final_sorted
          // Wire the final_sorted to best_ask
          assign best_ask = sorting_engine.final_sorted[0];
          // Set state to GET Match
          state = GET Match;
          latency_counter <= latency_counter + 1;
        end

        GET Match: begin
          // Compare best_bid and best_ask
          if (best_bid > best_ask) begin
            // Match found
            match_valid = 1;
            matched_price = best_ask;
          else begin
            match_valid = 0;
            matched_price = 0;
          end
          // Set state to POST
          state = POST;
          // Increment latency counter up to 21
          if (latency_counter < 20) begin
            latency_counter <= latency_counter + 1;
          else begin
            done <= 1;
            match_valid <= 0;
            matched_price <= 0;
            // Ensure total latency is 21 cycles
            if (latency_counter > 20) {
              latency_error <= 1;
            }
          end
        end

        POST: begin
          // All done
          done <= 1;
          // Reset latency counter
          latency_counter <= 0;
        end
      endcase
    end
  end
endmodule
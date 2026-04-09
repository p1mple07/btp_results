order_matching_engine.sv

// Copyright 2023, Synopsys Inc. All rights reserved.

module order_matching_engine #(parameter PRICE_WIDTH = 16)(
    input                  clk,
    input                  rst,
    input                  start,         // Start matching operation
    input  [8*PRICE_WIDTH-1:0] bid_orders,    // 8 bid orders (flat vector)
    input  [8*PRICE_WIDTH-1:0] ask_orders,    // 8 ask orders (flat vector)
    output reg               match_valid,   // high if a match occurs
    output reg [PRICE_WIDTH-1:0] matched_price, // matched price (best ask)
    output reg               done,          // matching engine done
    output reg               latency_error  // asserted if latency ≠ 20 cycles
);

  // FSM states:
  // 0 - Ready for input
  // 1 - Waiting for start signal
  // 2 - Validating inputs
  // 3 - Sorting bids
  // 4 - Sorting asks 
  // 5 - Waiting for sorted data
  // 6 - Matching orders
  // 7 - Validating latency
  // 8 - Output results

  localparam IDLE = 0'd0,
         READY = 0'd1,
         VALID_IN = 0'd2,
         SORT_BID = 0'd3,
         SORT_ASK = 0'd4,
         WAIT_DATA = 0'd5,
         MATCH = 0'd6,
         VALID_LATENCY = 0'd7,
         DONE = 0'd8;

  reg [9:0] state;  // State encoding

  // Internal buffers to hold intermediate data
  reg [PRICE_WIDTH-1:0] bid_buffer [8];
  reg [PRICE_WIDTH-0:0] ask_buffer [8];

  // Comparator to find best bid and best ask
  reg [PRICE_WIDTH-1:0] best_bid;
  reg [PRICE_WIDTH-1:0] best_ask;

  // Latency tracking
  integer latency_counter = 0;

  // Register to store the matched price
  reg [PRICE_WIDTH-1:0] matched_price_reg;

  // Event flags
  wire match_valid_flag = false;
  wire matched_price_flag = false;

  // Event-based handling of signals
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset all registers and counters
      state <= IDLE;
      match_valid <= 0;
      best_bid <= 0;
      best_ask <= 0;
      matched_price_reg <= 0;
      done <= 0;
      latency_counter <= 0;
      invalidate event;
    end else begin
      case (state)
        // Initial state: wait for start signal
        IDLE: begin
          if (!start) begin
            state <= IDLE;
          end else begin
            // Validate inputs
            state <= VALID_IN;
          end
        end

        // Validate inputs
        VALID_IN: begin
          if (bid_orders == 0 || ask_orders == 0) begin
            match_valid <= 0;
            done <= 0;
            state <= DONE;
            invalidate event;
          end else begin
            // Store inputs in buffers
            for (int i = 0; i < 8; i++) begin
              bid_buffer[i] <= bid_orders[i * PRICE_WIDTH +: PRICE_WIDTH];
              ask_buffer[i] <= ask_orders[i * PRICE_WIDTH +: PRICE_WIDTH];
            end
            state <= SORT_BID;
          end
        end

        // Sort bids
        SORT_BID: begin
          // Pipe-line the sorting process
          // Assuming sorting_engine is already implemented
          state <= SORT_ASK;
          // Sort bid_orders and ask_orders here using sorting_engine.sv
          // For this example, we'll assume the sorter returns sorted data directly
          // In practice, connect bid_orders to sorting_engine's inputs
          // and same for ask_orders
        end

        // Sort asks
        SORT_ASK: begin
          // Pipe-line the sorting process
          state <= WAIT_DATA;
          // Sort ask_orders and bid_orders here using sorting_engine.sv
        end

        // Match orders
        WAIT_DATA: begin
          // Extract best bid and best ask
          best_bid = bid_buffer[7];
          best_ask = ask_buffer[0];
          
          // Check if match occurred
          if (best_bid >= best_ask) begin
            match_valid <= 1;
            matched_price <= best_ask;
            matched_price_flag <= true;
          else begin
            match_valid <= 0;
            match_valid_flag <= true;
          end
          
          state <= MATCH;
        end

        // After match, validate latency
        MATCH: begin
          if (latency_counter >= 21) begin
            // Latency exceeded
            latency_error <= 1;
            invalidated = true;
          end else begin
            // Increment latency counter
            latency_counter <= latency_counter + 1;
          end
          state <= VALID_LATENCY;
        end

        // Final latency validation state
        VALID_LATENCY: begin
          if (latency_counter != 20) begin
            // Latency not reached yet
            state <= VALID LATENCY;
          else begin
            // Latency achieved
            done <= 1;
            invalidated = true;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

  // Handle events
  event match_valid event;
  event matched_price_flag event;
  event latency_error event;

  // Pack output signals
  always @* (posedge clk) begin
    if (match_valid_flag) begin
      match_valid <= 1;
    end
    if (matched_price_flag) begin
      matched_price_flag <= false;
      matched_price <= matched_price_reg;
    end
    if (latency_error) begin
      $finish();
    end
  end

  // Ensure proper ordering of events
  always begin
    if (match_valid) {
      match_valid_flag <= true;
    }
    if (latency_error) {
      $finish();
    }
  end
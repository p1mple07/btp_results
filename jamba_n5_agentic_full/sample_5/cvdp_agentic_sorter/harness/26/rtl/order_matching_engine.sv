module order_matching_engine #(
    parameter PRICE_WIDTH = 16
)(
    input                      clk,
    input                      rst,
    input                      start,         // Active high. Start matching operation
    input                      circuit_breaker, //Active high. Circuit breaker
    input  [8*PRICE_WIDTH-1:0] bid_orders,    // 8 bid orders (flat vector)
    input  [8*PRICE_WIDTH-1:0] ask_orders,    // 8 ask orders (flat vector)
    output reg                 match_valid,   // High if a match occurs
    output reg [PRICE_WIDTH-1:0] matched_price, // Matched price (best bid)
    output reg                 done          // Active high. Matching engine done
);

localparam N = 8;

reg [7:0] bid_sorted, ask_sorted;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bid_sorted = {};
        ask_sorted = {};
    end else begin
        // Sort bid_orders ascending
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N-1; j = j + 1) begin
                if (bid_sorted[j] > bid_sorted[j+1]) begin
                    bid_sorted[j] <= bid_sorted[j+1];
                    bid_sorted[j+1] <= bid_sorted[j];
                end
            end
        end

        // Sort ask_orders ascending
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N-1; j = j + 1) begin
                if (ask_sorted[j] > ask_sorted[j+1]) begin
                    ask_sorted[j] <= ask_sorted[j+1];
                    ask_sorted[j+1] <= ask_sorted[j];
                end
            end
        end
    end
end

// Find best bid and best ask
assign best_bid = bid_sorted[0];
assign best_ask = ask_sorted[0];

// Check if match occurs
assign match_valid = (best_bid >= best_ask);
assign matched_price = best_bid;

// Done is always high after processing, but we can use the start signal to control start.
assign done = start;

endmodule

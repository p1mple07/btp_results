module order_matching_engine #(
    parameter PRICE_WIDTH = 16  // Width of the price field
)(
    input                      clk,
    input                      rst,
    input                      start,         // Active high: start matching
    input                      circuit_breaker, // Active high: disable matches
    input  [8*PRICE_WIDTH-1:0] bid_orders,    // 8 bid orders (flat vector)
    input  [8*PRICE_WIDTH-1:0] ask_orders,    // 8 ask orders (flat vector)
    output reg                 match_valid,   // High if a match occurs
    output reg [PRICE_WIDTH-1:0] matched_price, // Best bid price
    output reg                 done          // Matching engine finished
);

// --- Circuit breaker guard -------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        match_valid <= 0;
        matched_price <= 0;
        done <= 0;
    end else if (circuit_breaker) begin
        match_valid <= 0;
        matched_price <= 0;
        done <= 0;
    end
end

// --- Sort bid orders (ascending) ---------------------------------------------
always @(posedge clk) begin
    if (start) begin
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 7; j = j + 1) begin
                if (bid_orders[j] > bid_orders[j+1]) begin
                    assign bid_orders[j] = bid_orders[j+1];
                    assign bid_orders[j+1] = bid_orders[j];
                end
            end
        end
    end
end

// --- Sort ask orders (ascending) ---------------------------------------------
always @(posedge clk) begin
    if (start) begin
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 7; j = j + 1) begin
                if (ask_orders[j] > ask_orders[j+1]) begin
                    assign ask_orders[j] = ask_orders[j+1];
                    assign ask_orders[j+1] = ask_orders[j];
                end
            end
        end
    end
end

// --- Find best bid and best ask ----------------------------------------------
assign max_bid = bid_orders[7];
assign min_ask = ask_orders[0];

// --- Match decision ---------------------------------------------------------
assign match_valid = (max_bid >= min_ask);

// --- Output result -----------------------------------------------------------
assign matched_price = (match_valid) ? max_bid : 0;
assign done = (start && match_valid);

endmodule

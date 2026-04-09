module order_matching_engine #(
    parameter PRICE_WIDTH = 16
)(
    input clk,
    input rst,
    input start,
    input circuit_breaker,
    input [8*PRICE_WIDTH-1:0] bid_orders,
    input [8*PRICE_WIDTH-1:0] ask_orders,
    output reg match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg done
);

// Instantiate the generic sorting engine for bid and ask
assign sorted_bid = sort_engine(bid_orders, PRICE_WIDTH);
assign sorted_ask = sort_engine(ask_orders, PRICE_WIDTH);

// Check circuit breaker
always @(posedge clk or posedge rst) begin
    if (rst) begin
        match_valid <= 0;
        matched_price <= 0;
        done <= 0;
    end else if (circuit_breaker) begin
        match_valid <= 0;
        matched_price <= 0;
        done <= 0;
    end else begin
        // Compare best bid and best ask
        if (sorted_bid[0] >= sorted_ask[0]) begin
            match_valid <= 0;
            matched_price <= 0;
        else
            match_valid <= 1;
            matched_price <= sorted_bid[0];
        end
    end
end

endmodule

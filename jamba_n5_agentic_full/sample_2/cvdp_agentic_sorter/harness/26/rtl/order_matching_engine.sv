module order_matching_engine #(
    parameter PRICE_WIDTH = 16
) (
    input                      clk,
    input                      rst,
    input                      start,
    input                      circuit_breaker,
    input                      [8*PRICE_WIDTH-1:0] bid_orders,
    input                      [8*PRICE_WIDTH-1:0] ask_orders,
    output reg                 match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg                 done
);

    // Circuit breaker safeguard
    always @(*) begin
        if (circuit_breaker) begin
            match_valid <= 0;
            matched_price <= 0;
            done <= 0;
        end
        else begin
            // Process the data
            integer max_bid = -1;
            integer min_ask = 32767;

            for (int i = 0; i < 8; i = i + 1) begin
                if (bid_orders[i] > max_bid) max_bid = bid_orders[i];
            end

            for (int i = 0; i < 8; i = i + 1) begin
                if (ask_orders[i] < min_ask) min_ask = ask_orders[i];
            end

            if (max_bid >= min_ask) begin
                matched_price = min_ask;
                match_valid <= 1;
            else
                matched_price <= 0;
                done <= 0;
            end
        end
    end

endmodule

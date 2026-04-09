module order_matching_engine #(
    parameter PRICE_WIDTH = 16
)(
    input clk,
    input rst,
    input start,
    input [8*PRICE_WIDTH-1:0] bid_orders,
    input [8*PRICE_WIDTH-1:0] ask_orders,
    output reg match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg done,
    output reg latency_error
);

// ... code to implement

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        match_valid <= 0;
        matched_price <= 0;
        done <= 0;
        latency_error <= 1;
        state <= IDLE;
    end else begin
        case (state)
            IDLE: begin
                // ... wait for start
            end
            /* other states */
        endcase
    end
end


module order_matching_engine #(
    parameter PRICE_WIDTH = 16
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire circuit_breaker,
    input wire [8*PRICE_WIDTH-1:0] bid_orders,
    input wire [8*PRICE_WIDTH-1:0] ask_orders,
    output reg match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg done
);

localparam ADDR_WIDTH = 16;

reg [8*PRICE_WIDTH-1:0] data_bid, data_ask;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_bid <= {8*PRICE_WIDTH{1'b0}};
        data_ask <= {8*PRICE_WIDTH{1'b0}};
        match_valid <= 1'b0;
        matched_price <= 0;
        done <= 1'b0;
    end else begin
        if (circuit_breaker) begin
            match_valid <= 1'b0;
            matched_price <= 0;
            done <= 1'b0;
        end else begin
            // Bubble sort for bid orders
            for (int i = 0; i < 8; i = i + 1) begin
                for (int j = 0; j < 7; j = j + 1) begin
                    if (data_bid[j] > data_bid[j+1]) begin
                        swap data_bid[j], data_bid[j+1];
                        swap data_ask[j], data_ask[j+1];
                    end
                end
            end

            // Bubble sort for ask orders
            for (int i = 0; i < 8; i = i + 1) begin
                for (int j = 0; j < 7; j = j + 1) begin
                    if (data_ask[j] > data_ask[j+1]) begin
                        swap data_ask[j], data_ask[j+1];
                        swap data_bid[j], data_bid[j+1];
                    end
                end
            end

            // Find best bid (maximum)
            for (int i = 0; i < 8; i = i + 1) begin
                if (data_bid[i] > data_bid[i+1]) begin
                    swap data_bid[i], data_bid[i+1];
                    swap data_ask[i], data_ask[i+1];
                end
            end

            // Find best ask (minimum)
            for (int i = 0; i < 8; i = i + 1) begin
                if (data_ask[i] < data_ask[i+1]) begin
                    swap data_ask[i], data_ask[i+1];
                    swap data_bid[j], data_bid[j+1];
                end
            end

            // Retrieve the matched price
            data_bid[0] <= data_bid[7];
            data_ask[0] <= data_ask[7];
            for (int i = 0; i < 8; i = i + 1) begin
                if (data_bid[i] > data_bid[i+1]) begin
                    swap data_bid[i], data_bid[i+1];
                    swap data_ask[i], data_ask[i+1];
                end
            }

            // Compare and decide
            if (data_bid[0] >= data_ask[0]) begin
                match_valid <= 1'b1;
                matched_price <= data_bid[0];
            end else begin
                match_valid <= 1'b0;
                matched_price <= 0;
            end
        end
    end
endmodule

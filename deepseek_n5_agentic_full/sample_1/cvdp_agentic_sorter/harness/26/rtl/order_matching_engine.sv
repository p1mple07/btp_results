module order_matching_engine #(parameter PRICE_WIDTH = 16)
(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire                circuit_breaker,
    input  [8*PRICE_WIDTH-1:0] bid_orders,
    input  [8*PRICE_WIDTH-1:0] ask_orders,
    output reg                 match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg                 done
)

    // Determine the best sorting engine based on latency
    static int selected_sort_engine = 0;
    static reg sort_engine_latency[4] = 
        sort_bubble_sorter.bubble_sort_depth,
        sort_merge_sort.sort_merge_depth,
        sort_radix_sort.sort_radix_depth,
        sort_brick_sort.sort_brick_depth;

    always @* begin
        if (sort_engine_latency[selected_sort_engine] <= others) begin
            // Use the selected sorting engine
            $use sorting_engine#selected_sort_engine#.sort_engine(
                .clk(clk),
                .rst(rst),
                .start(start),
                .in_data[bid_orders],
                .out_data[matched_price],
                .done(done)
            );
        end else begin
            // Fall back to another method (e.g., manual sorting)
            manual_sorting#8(.clk(clk), .rst(rst), .start(start),
                                       .in_data[bid_orders], .out_data[matched_price],
                                       .done(done));
        end
    end

    // Comparator logic
    reg [PRICE_WIDTH-1:0] best_bid = matched_price;
    reg [PRICE_WIDTH-1:0] best_ask = matched_price;

    // Sorting logic
    assign best_bid = matched_price;
    assign best_ask = matched_price;

    // Comparator logic
    always @* begin
        if (best_bid >= best_ask) begin
            match_valid <= 1;
            matched_price <= best_bid;
        else
            match_valid <= 0;
            matched_price <= 0;
        end

        if (circuit_breaker) begin
            match_valid <= 0;
            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule
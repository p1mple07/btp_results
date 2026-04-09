module order_matching_engine #(
    parameter PRICE_WIDTH = 16
)(
    input                     clk,
    input                     rst,
    input                      start,
    input  [8*PRICE_WIDTH-1:0] bid_orders,
    input  [8*PRICE_WIDTH-1:0] ask_orders,
    output reg                 match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg                 done,
    output reg                 latency_error
);

    localparam WIDTH = PRICE_WIDTH;

    // Instantiate the sorting engines for bid and ask
    sorting_engine #(WIDTH) bid_sort(.WIDTH(WIDTH));
    sorting_engine #(WIDTH) ask_sort(.WIDTH(WIDTH));

    // Signals
    wire bid_sorted;
    wire ask_sorted;
    wire [7:0] best_bid;
    wire [7:0] best_ask;
    wire match;

    // Process bid_orders
    begin
        bid_sort.start();
        bid_sort.done => bid_sorted;
    end

    // Process ask_orders
    begin
        ask_sort.start();
        ask_sort.done => ask_sorted;
    end

    // Wait for both to finish
    fork
        if (!bid_sorted) bid_sorted = 1;
        if (!ask_sorted) ask_sorted = 1;
    fork

    // Determine match
    if (bid_sorted && ask_sorted) begin
        best_bid = bid_sorted[7];
        best_ask = ask_sorted[7];
        match = (best_bid >= best_ask);
    end else begin
        match = 0;
    end

    // Output
    assign match_valid = match;
    assign matched_price = match ? best_ask : best_bid;
    assign done = 1;
    assign latency_error = 0;

endmodule

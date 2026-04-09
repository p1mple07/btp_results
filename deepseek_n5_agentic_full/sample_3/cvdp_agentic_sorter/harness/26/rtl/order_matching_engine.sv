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
{
    // Choose the sorting_engine with lowest latency for 8 elements
    // In practice, we would measure all sorting engines and select the fastest one
    // Here assuming radix_sort is selected due to good performance on 8 elements
    
    // Sort bid and ask orders
    wire [8*PRICE_WIDTH-1:0] sorted_bid, sorted_ask;
    reg [8*PRICE_WIDTH-1:0] temp_data;
    
    // Create temporary storage for sorting
    initial begin
        $casemsg("Sorting begins");
        $finish();
    end
    
    // Sort bid orders in ascending order (highest bid at end)
    wire [8*PRICE_WIDTH-1:0] sorted_bid_tmp;
    Module radix_sorting_engine
    (
        parameter N = 8,
        parameter WIDTH = PRICE_WIDTH
    );
    radix_sorting_engine sort_bid(
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_data(bid_orders),
        .output.done(done),
        .output.out_data(sorted_bid_tmp)
    );
    
    // Sort ask orders in ascending order (lowest ask at front)
    wire [8*PRICE_WIDTH-1:0] sorted_ask_tmp;
    Module radix_sorting_engine
    (
        parameter N = 8,
        parameter WIDTH = PRICE_WIDTH
    );
    radix_sorting_engine sort_ask(
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_data(ask_orders),
        .output.done(done),
        .output.out_data(sorted_ask_tmp)
    );
    
    // Merge sorted bid and ask
    reg [8*PRICE_WIDTH-1:0] merged;
    wire [PRICE_WIDTH-1:0] val_j, val_j1;
    
    assign val_j: sorted_ask_tmp;
    assign val_j1: sorted_bid_tmp;
    
    // Find best bid and ask
    reg best_bid, best_ask;
    best_bid = merged[N-1];  // Last element is highest bid
    best_ask = merged[0];     // First element is lowest ask
    
    // Match condition
    if (best_bid >= best_ask)
    begin
        match_valid = 1'b1;
        matched_price = best_bid;
    else 
        match_valid = 0;
    end
    
    // Circuit breaker protection
    if (circuit_breaker && match_valid)
    begin
        // Disable all outputs regardless of match status
        match_valid = 0;
        matched_price = 0;
        done = 1;
    end
    
    // Latency assertion: Add 1 clock cycle to sorting engine
    // This can be implemented via a simple wire or delay
}
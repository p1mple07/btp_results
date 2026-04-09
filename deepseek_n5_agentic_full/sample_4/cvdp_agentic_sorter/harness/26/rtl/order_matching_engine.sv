module order_matching_engine #( 
    parameter PRICE_WIDTH = 16, 
    parameter sort_width = 8
) (
    input wire clocksclk, 
    input wire clocksrst, 
    input clocksstart,
    input clocksbreak,
    input [sort_width*PRICE_WIDTH-1:0] bid_orders,
    input [sort_width*PRICE_WIDTH-1:0] ask_orders,
    output reg match_valid,
    output reg [PRICE_WIDTH-1:0] matched_price,
    output reg done
) 

    // Determine which sorting engine has the lowest latency
    // Currently assumes that selection_sort is the fastest for these patterns
    reg [sort_width*PRICE_WIDTH-1:0] sorted_bid, sorted_ask;
    wire [sort_width*PRICE_WIDTH-1:0] temp;
    
    // Selection sort implementation
    selection_sorting_engine #(
        parameter N = sort_width,
        parameter WIDTH = PRICE_WIDTH
    )(clocksclk, clocksrst, clocksstart, temp, 
         output reg done_selection, 
         output reg [PRICE_WIDTH-1:0] matched_price_selection);
    
    // Match logic
    reg bit match_occurred;
    reg bit match_valid_current;
    
    // Best bid and ask
    reg [PRICE_WIDTH-1:0] best_bid, best_ask;
    
    // Circuit breaker control
    reg bit circuit_breaker;
    
    // Clock enablement
    always@(posedge clocksclk) begin
        if (clocksrst) begin
            // Initial state
            sorted_bid <= {sort_width*PRICE_WIDTH{1'b0}};
            sorted_ask <= {sort_width*PRICE_WIDTH{1'b0}};
            done_selection <= 0;
            best_bid <= {PRICE_WIDTH{1'b0}};
            best_ask <= {PRICE_WIDTH{1'b0}};
            match_valid <= 0;
            match_occurred <= 0;
        else begin
            // Load sorted data
            if (clocksstart && !clocksbreak) begin
                sorted_bid <= temp;
                // Match best bid and ask
                best_bid <= sorted_bid[sort_width*PRICE_WIDTH-1:PRICE_WIDTH];
                best_ask <= sorted_ask[0:PRICE_WIDTH];
                
                // Check if match occurred
                if (best_bid >= best_ask) begin
                    match_valid_current <= 1;
                    match_occurred <= 1;
                else begin
                    match_valid_current <= 0;
                    match_occurred <= 0;
                end
            end
        end
    end
    
    // Finalize match status
    always@(!clocksrst) begin
        match_valid <= match_valid_current;
    end
    
    // Output the results
    wire [PRICE_WIDTH-1:0] matched_price_final;
    always@(posedge clocksclk) begin
        if (match_occurred) begin
            matched_price_final <= best_bid;
        else begin
            matched_price_final <= {PRICE_WIDTH{1'b0}};
        end
    end
    
    // Connect the outputs
    wiredone(sorted_bid, matched_price_final);
    wiredone(sorted_ask, best_ask);
    
    // Add circuit breaker protection
    always@(posedge clocksclk) begin
        if (clocksbreak || match_occurred) begin
            // Disable any successful matches
            match_valid <= 0;
        end
    end
    
    // Latency adjustment
    always@(posedge clocksclk) begin
        if (!clocksrst) begin
            // Ensure adding exactly one clock cycle latency
            // This would depend on the specific implementation of selection_sort
            // And how it handles its internal states
        end
    end

endmodule
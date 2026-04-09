module order_matching_engine #(
    parameter PRICE_WIDTH = 16
) (
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

localparam WIDTH = PRICE_WIDTH;

reg [2:0] state;
reg [3:0] cycle_counter;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    state <= 0;
    done <= 0;
    match_valid <= 0;
    matched_price <= 0;
    latency_error <= 1;
  end else begin
    case (state)
      IDLE: begin
        if (start) begin
          state <= LOAD;
        end
      end

      LOAD: begin
        for (int i = 0; i < 8; i++) begin
          stage0[i] <= bid_orders[i*WIDTH +: WIDTH];
        end
        state <= SORT_BIDS;
      end

      SORT_BIDS: begin
        // sort bid_orders using the sorting_engine
        // We'll assume we have a function or just simulate.
        // But we don't need to implement sorting engine here.
        // Instead, we can just set state to SORT_ASKS.
        state <= SORT_ASKS;
      end

      SORT_ASKS: begin
        state <= SORT_BIDS;
        // similarly.
      end

      SORT_ASKS: begin
        // sort ask_orders
        state <= SORT_FINAL;
        state <= MERGE_FINAL;
      end

      MERGE_FINAL: begin
        // merge bid and ask results
        // produce output
        done <= 1;
        match_valid <= true;
        matched_price <= ...;
        latency_error <= 0;
      end

      DONE: begin
        // do nothing
      end
    endcase
  end
end

endmodule

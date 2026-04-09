module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    localparam IDLE = 2'd0,
                  LOAD = 2'd1,
                  SORT = 2'd2,
                  DONE = 2'd3;

    reg [1:0]  state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [$clog2(N+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;

    // ----- State machine ----
    always @(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
            data_array <= {N{1'b0}};
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    next_state <= LOAD;
                end
                LOAD: begin
                    next_state <= SORT;
                end
                SORT: begin
                    next_state <= DONE;
                end
            endcase
        end
    end

    // ----- Brick‑sort logic ----
    always @(*) begin
        if (state == SORT) begin
            pass_cnt = $clog2(N/2+1);
            for (i = 0; i < N; i += 2) begin
                if (i+1 < N) begin
                    if (data_array[i] > data_array[i+1]) begin
                        data_array[i] <= data_array[i+1];
                        data_array[i+1] <= data_array[i];
                    end
                end
            end
            for (i = 1; i < N; i += 2) begin
                if (i+1 < N) begin
                    if (data_array[i] > data_array[i+1]) begin
                        data_array[i] <= data_array[i+1];
                        data_array[i+1] <= data_array[i];
                    end
                end
            end
        end
    end

    // ----- Output ready ----
    always @(posedge clk) begin
        if (next_state == DONE) begin
            done <= 1;
        end
    end

endmodule

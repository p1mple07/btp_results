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
             LOAD  = 2'd1,
             SORT  = 2'd2,
             DONE  = 2'd3;

reg [1:0] state, next_state;
reg [WIDTH-1:0] data_array[0:N-1];
reg [$clog2(N+1)-1:0] pass_cnt;
reg [$clog2(N/2+1)-1:0] pair_idx;

always @(*) begin
    next_state = state;

    case (state)
        IDLE:
            if (start) begin
                state <= LOAD;
            end
        CASE_EQUALS: LOAD:
            state <= SORT;
        CASE_EQUALS: SORT:
            // Brick‑sort odd‑even passes
            pass_cnt = 0;
            next_state = DONE;
            for (int i = 0; i < N; i += 2) begin
                if (i % 2 == 0) begin // even pass: compare adjacent pairs
                    for (int j = i; j < N; j += 2) begin
                        if (data_array[j] > data_array[j+1]) begin
                            data_array[j] ^= data_array[j+1];
                            data_array[j+1] ^= data_array[j];
                            data_array[j] ^= data_array[j+1];
                        end
                    end
                end else begin // odd pass: compare swapped pairs
                    for (int j = i; j < N; j += 2) begin
                        if (data_array[j+1] > data_array[j]) begin
                            data_array[j+1] ^= data_array[j];
                            data_array[j] ^= data_array[j+1];
                            data_array[j] ^= data_array[j+1];
                        end
                    end
                end
            end
            pass_cnt++;
            if (pass_cnt == N) begin
                next_state = DONE;
            end
        endcase
end

always @(posedge clk) begin
    if (~rst) begin
        state <= IDLE;
        data_array <= {N{1'b0}};
        out_data <= 0;
        done <= 0;
    end else if (done) begin
        state <= IDLE;
    end else if (next_state == DONE) begin
        state <= IDLE;
    end else
        state = next_state;
end

assign out_data = data_array;

endmodule

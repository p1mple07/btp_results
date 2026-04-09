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

reg [1:0] state, next_state;
reg [WIDTH-1:0] data_array [0:N-1];
reg [$clog2(N+1)-1:0] pairs_to_process;

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        data_array <= in_data;
        done <= 1'b0;
        out_data <= in_data;
    end else begin
        next_state = SORT;
        if (state == IDLE) begin
            // Load data
            for (int i=0; i<N; i++) data_array[i] = in_data[i];
            state <= LOAD;
        end else if (state == LOAD) begin
            // Process
            for (int i=0; i<N/2; i++) begin
                int idx1 = 2*i;
                int idx2 = idx1+1;
                if (data_array[idx1] > data_array[idx2]) begin
                    data_array[idx1] ^= (WIDTH-1)'b1 << (WIDTH-1);
                    data_array[idx2] ^= (WIDTH-1)'b1;
                    data_array[idx1] ^= (WIDTH-1)'b1;
                    data_array[idx2] ^= (WIDTH-1)'b1;
                end
            end
            state <= SORT;
        end else if (state == SORT) begin
            for (int i=0; i<N/2; i++) begin
                int idx1 = 2*i+1;
                int idx2 = idx1+1;
                if (data_array[idx1] > data_array[idx2]) begin
                    data_array[idx1] ^= (WIDTH-1)'b1 << (WIDTH-1);
                    data_array[idx2] ^= (WIDTH-1)'b1;
                    data_array[idx1] ^= (WIDTH-1)'b1;
                    data_array[idx2] ^= (WIDTH-1)'b1;
                end
            end
            state <= DONE;
        end else if (state == DONE) begin
            done <= 1'b1;
            out_data <= data_array;
        end
    end
end

endmodule

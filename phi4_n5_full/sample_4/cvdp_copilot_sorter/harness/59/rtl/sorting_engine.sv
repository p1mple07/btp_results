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

    // Internal array
    reg [WIDTH-1:0] array [0:N-1];

    // Merged FSM states to eliminate extra registers.
    // States: IDLE, LOAD, INIT, SHIFT, INSERT, DONE.
    localparam IDLE  = 3'd0,
               LOAD  = 3'd1,
               INIT  = 3'd2, // Setup: load key and set j for insertion
               SHIFT = 3'd3, // Shift elements right until the correct spot is found
               INSERT= 3'd4, // Insert key then prepare for next element
               DONE  = 3'd5;

    reg [2:0] state;

    // Insertion sort variables
    integer i;
    integer j;
    reg [WIDTH-1:0] key;

    // Single always_ff block: merged combinational next-state logic with sequential updates.
    // This reduces the overall register and combinational logic, achieving area savings.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            done    <= 1'b0;
            i       <= 0;
            j       <= 0;
            key     <= {WIDTH{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start)
                        state <= LOAD;
                    else
                        state <= IDLE;
                end

                LOAD: begin
                    // Load input data into the internal array.
                    for (int k = 0; k < N; k = k + 1) begin
                        array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                    end
                    // Start insertion sort from index 1.
                    i <= 1;
                    j <= 0;
                    key <= {WIDTH{1'b0}};
                    state <= INIT;
                end

                INIT: begin
                    if (i < N) begin
                        key <= array[i];
                        j <= i - 1;
                        state <= SHIFT;
                    end else begin
                        state <= DONE;
                    end
                end

                SHIFT: begin
                    if (j >= 0 && array[j] > key) begin
                        array[j+1] <= array[j];
                        j <= j - 1;
                        state <= SHIFT;
                    end else begin
                        state <= INSERT;
                    end
                end

                INSERT: begin
                    array[j+1] <= key;
                    i <= i + 1;
                    state <= INIT;
                end

                DONE: begin
                    done <= 1'b1;
                    // Output the sorted array.
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
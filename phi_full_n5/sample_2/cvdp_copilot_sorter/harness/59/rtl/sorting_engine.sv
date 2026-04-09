
module sorting_engine #(
    parameter N = 8,             // Number of elements to sort
    parameter WIDTH = 8          // Bit-width of each element
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

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] state, next_state;

    // Insertion sort variables
    integer i;
    integer j;
    reg [WIDTH-1:0] key;

    // Combinational logic for key
    always @(posedge clk, negedge clk) begin
        if (!rst) begin
            key <= 0;
        end else begin
            if (state == SORTING) begin
                if (i < N) begin
                    key <= array[i];
                end
            end
        end
    end

    // Sequential logic for shifting and inserting
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            done          <= 0;
            i             <= 0;
            j             <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Load array from in_data
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 1;
                        j <= 0;
                        key <= array[0];
                    end
                end

                SORTING: begin
                    // Perform insertion sort step-by-step
                    if (i < N) begin
                        j <= i - 1;
                        if (j >= 0 && array[j] > key) begin
                            array[j+1] <= array[j];
                        end else begin
                            array[j+1] <= key;
                            i <= i + 1;
                        end
                    end
                end

                DONE: begin
                    done <= 1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end

                default: begin
                    // Should not get here
                end
            endcase
        end
    end

endmodule

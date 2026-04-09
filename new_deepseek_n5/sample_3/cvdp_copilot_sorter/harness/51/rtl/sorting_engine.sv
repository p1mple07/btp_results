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

    // Internal registers to hold the array
    reg [WIDTH-1:0] array [0:N-1];

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0]  state, next_state, swap;
    reg [1:0]  i, j;

    // Wires for comparison and swap
    wire [WIDTH-1:0] val_j;
    wire [WIDTH-1:0] val_j1;
    wire [1:0] swap_w;

    assign val_j  = array[j];
    assign val_j1 = array[j+1];
    assign swap_w = (val_j > val_j1);

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        swap = 0;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
                    i = 0;
                    j = 0;
                end
            SORTING: begin
                if (i == N-1) begin
                    if (j == N-2) begin
                        next_state = DONE;
                    end
                end
                if (swap_w) begin
                    swap = 1;
                    array[j] <= val_j1;
                    array[j+1] <= val_j;
                end
                j = j + swap ? 1 : 0;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // FSM: Output and counter updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            done <= 0;
            swap <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 0;
                        j <= 0;
                    end
                end

                SORTING: begin
                    if (swap_w) begin
                        swap <= 1;
                    end
                    if (j == N-2) begin
                        j <= 0;
                        i <= i + 1;
                    end else begin
                        j <= j + 1;
                    end
                end

                DONE: begin
                    done <= 1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end
                default: begin
                end
            endcase
        end
    end

endmodule
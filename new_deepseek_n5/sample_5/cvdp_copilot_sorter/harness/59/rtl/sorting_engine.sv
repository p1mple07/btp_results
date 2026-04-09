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

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] state, next_state;

    // Insertion sort variables
    integer i;
    integer j;
    reg [WIDTH-1:0] key;

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                if (i == N)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // FSM: main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            done          <= 0;
            i             <= 0;
            j             <= 0;
            key           <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 1;
                        j <= 0;
                        key <= 0;
                    end
                end

                SORTING: begin
                    case (i)
                        0: begin
                            key <= array[0];
                            j <= -1;
                        end
                        1: begin
                            if (array[j+1] > key) begin
                                array[j+1] <= key;
                            end else begin
                                j <= 0;
                            end
                        end
                        default: i <= i + 1;
                    endcase
                end

                DONE: begin
                    done <= 1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end
            endcase
        end
    end

    endmodule
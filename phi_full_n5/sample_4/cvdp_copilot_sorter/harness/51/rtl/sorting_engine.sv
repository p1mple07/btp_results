module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
) (
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

    reg [1:0]  state, next_state;

    // Variables for bubble sort indexing
    integer i;
    integer j;

    // Combinational logic
    wire [WIDTH-1:0] val_j1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        for (i = 0; i < N; i = i + 1) begin
                            array[i] <= in_data[(i+1)*WIDTH-1 -: WIDTH];
                        end
                    end
                end
                SORTING: begin
                    j <= 0;
                    // Perform a single comparison and swap if needed
                    if (array[j] > array[j+1]) begin
                        assign val_j1 = array[j+1];
                        assign array[j+1] = array[j];
                        assign array[j] = val_j1;
                    end
                    j <= j + 1;
                    if (j == N-2) begin
                        j <= 0;
                        i <= i + 1;
                    end
                end
                DONE: begin
                    done <= 1;
                    for (i = 0; i < N; i = i + 1) begin
                        out_data[(i+1)*WIDTH-1 -: WIDTH] <= array[i];
                    end
                end
                default: begin
                end
            endcase
        end
    end

    // FSM: Next state logic
    always @(state) begin
        next_state = state;
        case (state)
            IDLE: begin
                next_state = SORTING if (start) else IDLE;
            end
            SORTING: begin
                next_state = DONE if (j == N-2) else SORTING;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule

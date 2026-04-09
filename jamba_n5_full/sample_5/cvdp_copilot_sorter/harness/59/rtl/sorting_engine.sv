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

    reg [WIDTH-1:0] array [0:N-1];
    reg [1:0] state, next_state;
    reg [1:0] insert_phase;
    reg [WIDTH-1:0] key;
    reg [WIDTH-1:0] i;
    reg [WIDTH-1:0] j;

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                case (insert_phase)
                    0: begin
                        if (i < N) begin
                            key <= array[i];
                            j <= i - 1;
                            insert_phase <= 1;
                        end
                        end

                    1: begin
                        if (j >= 0 && array[j] > key) begin
                            array[j+1] <= array[j];
                            j <= j - 1;
                        end else begin
                            insert_phase <= 2;
                        end
                    end

                    2: begin
                        array[j+1] <= key;
                        i <= i + 1;
                        insert_phase <= 0;
                    end

                    default: insert_phase <= 0;
                endcase
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

endmodule

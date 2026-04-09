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
    reg [1:0]  state, next_state;
    reg [1:0]  next_state_reg;

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
            end
            SORTING: begin
                always @(*) begin
                    next_state_reg = state;
                    case (state)
                        SORTING: begin
                            for (int i = 1; i < N; i++) begin
                                int key = array[i];
                                int j = i - 1;
                                while (j >= 0 && array[j] > key) begin
                                    array[j+1] = array[j];
                                    j = j - 1;
                                end
                                array[j+1] = key;
                            end
                            done <= 1;
                        end
                        default: begin
                            done <= 0;
                        end
                    endcase
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            done <= 0;
        end else begin
            state <= next_state;
        end
    end

endmodule

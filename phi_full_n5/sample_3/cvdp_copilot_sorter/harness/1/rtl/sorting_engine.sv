module sorting_engine #(parameter WIDTH = 8, parameter N = 8) (
    input clk,
    input rst,
    input start,
    input [N*WIDTH-1:0] in_data,
    output reg [N*WIDTH-1:0] out_data,
    output reg done
);

    // State declaration
    typedef enum logic [1:0] {IDLE, SORTING, DONE} state_t;
    state_t state = IDLE;

    // Registers for array and index
    logic [N*WIDTH-1:0] array [N:0];
    logic [N-1:0] index;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            index <= 0;
            array <= {{WIDTH{1'b0}}} {in_data};
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= SORTING;
                        index <= 0;
                    end else
                        state <= IDLE;
                end
                SORTING: begin
                    if (index == N-1) begin
                        state <= DONE;
                    end else begin
                        if (array[index] > array[index+1]) begin
                            wire tmp = array[index];
                            array[index] = array[index+1];
                            array[index+1] = tmp;
                        end
                        index <= index + 1;
                    end
                end
                DONE: begin
                    state <= IDLE;
                    done = 1'b1;
                end
            endcase
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (done) begin
            out_data <= array;
        end else begin
            out_data <= {WIDTH{1'b0}} {in_data};
        end
    end

endmodule

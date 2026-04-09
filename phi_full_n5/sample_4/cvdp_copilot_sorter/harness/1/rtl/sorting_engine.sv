module sorting_engine #(parameter N = 8, parameter WIDTH = 8)
(
    input clk,
    input rst,
    input start,
    input [N*WIDTH-1:0] in_data,
    output reg [N*WIDTH-1:0] out_data,
    output reg done
);

    // State declaration
    typedef enum logic [1:0] {IDLE, SORTING, DONE} state_t;
    state_t state, next_state;

    // Comparator and swap function (pseudo-implementation)
    function logic [WIDTH-1:0] compare_and_swap(logic [WIDTH-1:0] a, logic [WIDTH-1:0] b);
        if (a > b) begin
            return {a[WIDTH-1], a[WIDTH-2], ..., a[0], b};
        end else begin
            return a;
        end
    endfunction

    // State transition logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            out_data <= {N*WIDTH{1'b0}};
            done <= 0;
        end else begin
            case (state)
                IDLE: if (start) begin
                            state <= SORTING;
                        end else begin
                            state <= IDLE;
                        end
                SORTING: begin
                    // Perform (N)*(N-1) passes
                    for (int i = 0; i < N-1; i++) begin
                        for (int j = 0; j < N-i-1; j++) begin
                            out_data <= compare_and_swap(out_data[WIDTH*j:WIDTH*(j+1)-1], in_data[WIDTH*(j+1):WIDTH*(j+2)-1]);
                        end
                    end
                    state <= DONE;
                DONE: done <= 1'b1;
                default: state <= IDLE;
            endcase
        end
    end

    // Sorting pass logic (pseudo-implementation)
    always_comb begin
        if (state == SORTING) begin
            // Initialize out_data with in_data
            for (int i = 0; i < N; i++) begin
                out_data[WIDTH*i:WIDTH*(i+1)-1] = in_data[WIDTH*i:WIDTH*(i+1)-1];
            end
            // Bubble sort algorithm
            for (int i = 0; i < N-1; i++) begin
                for (int j = 0; j < N-i-1; j++) begin
                    if (compare_and_swap(out_data[WIDTH*j:WIDTH*(j+1)-1], out_data[WIDTH*(j+1):WIDTH*(j+2)-1]) > out_data[WIDTH*(j+1):WIDTH*(j+2)-1]) begin
                        out_data[WIDTH*j:WIDTH*(j+1)-1] = compare_and_swap(out_data[WIDTH*j:WIDTH*(j+1)-1], out_data[WIDTH*(j+1):WIDTH*(j+2)-1]);
                    end
                end
            end
        end
    end

endmodule

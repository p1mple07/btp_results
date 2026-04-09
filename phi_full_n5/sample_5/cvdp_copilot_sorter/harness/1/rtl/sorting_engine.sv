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
    state_t state, next_state;

    // State transition logic
    always_comb begin
        case (state)
            IDLE:
                if (start) begin
                    state = SORTING;
                end else begin
                    state = IDLE;
                end
            SORTING:
                // Perform bubble sort
                for (int i = 0; i < N-1; i++) begin
                    for (int j = 0; j < N-i-1; j++) begin
                        if (in_data[j*WIDTH:(j+1)*WIDTH] > in_data[(j+1)*WIDTH:(j+2)*WIDTH]) begin
                            wire temp_wire = in_data[j*WIDTH:(j+1)*WIDTH];
                            in_data[j*WIDTH:(j+1)*WIDTH] = in_data[(j+1)*WIDTH:(j+2)*WIDTH];
                            in_data[(j+1)*WIDTH:(j+2)*WIDTH] = temp_wire;
                        end
                    end
                end
                // Check if the last pass is completed
                if (j == N-1) begin
                    next_state = DONE;
                end else begin
                    next_state = SORTING;
                end
        endcase
    end

    // State transition assignments
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            out_data <= {WIDTH{1'b0}};
            done <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Output logic
    always_comb begin
        if (state == DONE) begin
            out_data <= in_data;
            done <= 1;
        end
    end

endmodule

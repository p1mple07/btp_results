module sorting_engine #(parameter WIDTH = 8, parameter N = 8) (
    input clk,
    input rst,
    input start,
    input [N*WIDTH-1:0] in_data,
    output reg done,
    output reg [N*WIDTH-1:0] out_data
);

    // State declaration
    localparam IDLE = 2'b00,
              SORTING = 2'b01,
              DONE = 2'b10;

    // State register
    reg [2:0] state_reg, state_next;

    // Counter for the number of passes
    reg [N-1:0] pass_count;

    // Internal signals for comparison and swapping
    logic [WIDTH-1:0] temp;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= IDLE;
            pass_count <= 0;
            out_data <= {WDATA{1'b0}}; // Uninitialized output
            done <= 1'b0;
        end else if (start && state_reg == IDLE) begin
            state_reg <= SORTING;
            pass_count <= 0;
            out_data <= {WDATA{1'b0}}; // Uninitialized output
            done <= 1'b0;
        end else if (state_reg == SORTING) begin
            pass_count <= pass_count + 1;
            if (pass_count == N-1) begin
                state_next = DONE;
            end else begin
                state_next = SORTING;
            end
        end else if (state_reg == DONE) begin
            state_next = IDLE;
        end
        state_reg <= state_next;
    end

    // Bubble sort implementation
    always @(posedge clk) begin
        if (state_reg == SORTING) begin
            for (int i = 0; i < N-1; i++) begin
                if (in_data[i*WIDTH] > in_data[i*WIDTH + 1]) begin
                    temp = in_data[i*WIDTH];
                    in_data[i*WIDTH] = in_data[i*WIDTH + 1];
                    in_data[i*WIDTH + 1] = temp;
                end
            end
        end
    end

    // Output assignment
    always @(state_reg == DONE) begin
        out_data <= in_data;
        done <= 1'b1;
    end

endmodule

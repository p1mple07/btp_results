module sorting_engine (
    input clock,
    input rst,
    input start,
    input [N*WIDTH-1:0] in_data,
    output [N*WIDTH-1:0] out_data,
    output done
);

    // State variables
    state state_state;
    reg [N*WIDTH-1:0] shift_reg;
    reg [N*WIDTH-1:0] temp_reg;
    reg [N*WIDTH-1:0] in_data_reg;
    reg done_state;

    // State transition table
    always @* begin
        if (rst) begin
            state_state = IDLE;
            in_data_reg = 0;
            done_state = 0;
        end else if (start) begin
            state_state = SORTING;
            in_data_reg = in_data;
        end else if (done_state) begin
            state_state = DONE;
        end
    end

    // Bubble sort implementation
    always @* begin
        if (state_state == SORTING) begin
            for (int i = 0; i < N-1; i++) begin
                for (int j = 0; j < N-1-i; j++) begin
                    if ((in_data_reg[j] & (1 << (WIDTH-1))) > (in_data_reg[j+1] & (1 << (WIDTH-1)))) begin
                        temp_reg = in_data_reg[j];
                        in_data_reg[j] = in_data_reg[j+1];
                        in_data_reg[j+1] = temp_reg;
                        // Increment swap counter
                    end
                end
            end
            // Check if any swaps occurred
            reg any_swap;
            any_swap = 0;
            for (int j = 0; j < N-1; j++) begin
                if (in_data_reg[j] > in_data_reg[j+1]) begin
                    any_swap = 1;
                    break;
                end
            end
            if (!any_swap) begin
                state_state = DONE;
            end
        end
    end

    // Output the sorted data
    always @* begin
        if (state_state == DONE) begin
            out_data = in_data_reg;
            done_state = 1;
        end
    end

    // Finalize done state
    always @* begin
        if (done_state) begin
            done = 1;
        end
    end
endmodule
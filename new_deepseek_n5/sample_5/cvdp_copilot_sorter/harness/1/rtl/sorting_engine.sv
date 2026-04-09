module sorting_engine (
    input clock,
    input rst,
    input start,
    input [WIDTH-1:0] in_data,
    output [WIDTH-1:0] out_data,
    output done
);

    // State machine
    state state_machine;
    // States: IDLE, SORTING, DONE
    // Registers
    reg [WIDTH-1:0] in_reg;
    reg [WIDTH-1:0] out_reg;
    reg swapped;
    reg done_state;

    // Initial state
    always_ff @(posedge clock or rst) begin
        if (rst) begin
            state_machine = IDLE;
            in_reg = 0;
            out_reg = 0;
            done_state = IDLE;
        end else if (start) begin
            state_machine = SORTING;
        end
    end

    // State: IDLE
    state Machine_IDLE begin
        // Initialize
        in_reg = 0;
        out_reg = 0;
    end

    // State: SORTING
    state Machine_SORTING begin
        // Bubble sort algorithm
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N - 1 - i; j++) begin
                if (in_data[j] > in_data[j + 1]) begin
                    // Swap elements
                    reg tmp = in_data[j];
                    in_data[j] = in_data[j + 1];
                    in_data[j + 1] = tmp;
                end
                // Pack data for output
                if (j == N - 1 - i - 1) begin
                    out_reg = in_data[j];
                end
            end
            // Check if any swaps occurred
            if (!swapped) begin
                // Array is sorted
                state_machine = DONE;
                done_state = DONE;
                swapped = 1;
            end
        end
    end

    // State: DONE
    state MachineDONE begin
        // Assert done signal
        done = 1;
    end

    // Output the packed data
    always @(posedge clock) begin
        if (done_state == DONE) begin
            out_data = out_reg;
        end
    end

    // Pack the data into the output bus
    integer k = 0;
    for (int i = 0; i < N; i++) begin
        out_data[k] = in_data[i];
        k++;
    end

    // Transition states
    state_machine = IDLE;
endmodule
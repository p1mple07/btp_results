module sorting_engine (
    input clock,
    input rst,
    input start,
    input [WIDTH-1:0] in_data,
    output [WIDTH-1:0] out_data,
    output done
);

    // State machine control variables
    enum state Machine = IDLE | SORTING | DONE;
    reg state = IDLE;

    // Register to hold the current data
    reg [WIDTH-1:0] current_data = 0;
    reg [WIDTH-1:0] sorted_data = 0;

    // Comparison and swap logic
    always @* begin
        if (state == IDLE) begin
            // Initialize registers
            current_data = in_data;
            sorted_data = in_data;
        end else if (state == SORTING) begin
            // Bubble sort implementation
            for (int i = 0; i < N-1; i++) begin
                for (int j = 0; j < N-1 - i; j++) begin
                    if ((current_data[j] & (1 << WIDTH)) > (current_data[j+1] & (1 << WIDTH))) begin
                        // Swap elements
                        temp = current_data[j];
                        current_data[j] = current_data[j+1];
                        current_data[j+1] = temp;
                    end
                    // Each comparison and potential swap takes one clock cycle
                    # delay(1);
                end
            end
            // After all passes, transition to DONE state
            state = DONE;
        end else if (state == DONE) begin
            // Set done signal after sorting
            done = 1;
        end
    end

    // Output the sorted data
    always @* begin
        if (state == DONE) begin
            out_data = sorted_data;
        end else begin
            out_data = 0;
        end
    end

    // Reset all registers on reset
    always begin
        if (rst) begin
            state = IDLE;
            current_data = 0;
            sorted_data = 0;
            done = 0;
        end
    end

    // Ensure proper clocking
    # delay(1);
    # delay(1);
endmodule
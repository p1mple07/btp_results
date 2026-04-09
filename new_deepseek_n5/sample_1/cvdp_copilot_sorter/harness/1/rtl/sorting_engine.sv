module sorting_engine (
    input clock,
    input rst,
    input start,
    input [WIDTH-1:0] in_data,
    output [WIDTH-1:0] out_data,
    output done
);

    // State variables
    reg state = IDLE;
    reg [N-1:0] i = 0;
    reg [N-1:0] j = 0;
    reg [N-1:0] passes = 0;

    // Internal data buffers
    reg [WIDTH-1:0] data_reg [N-1:0];
    reg [WIDTH-1:0] temp;

    // State transitions
    always @posedge clock begin
        case(state)
            IDLE:
                // Initialize on first start
                if (start) begin
                    state = SORTING;
                    passes = 0;
                    j = 0;
                end
            SORTING:
                // Bubble sort algorithm
                if (passes < N * (N - 1)) begin
                    // Perform one pass through the array
                    if (j < N - 1) begin
                        if (data_reg[j] > data_reg[j+1]) begin
                            // Swap elements
                            temp = data_reg[j];
                            data_reg[j] = data_reg[j+1];
                            data_reg[j+1] = temp;
                        end
                        j = j + 1;
                    end
                    passes = passes + 1;
                    // If no swaps occurred, the array is sorted
                    if (j >= N - 1) begin
                        state = DONE;
                        done = 1;
                    end
                end else begin
                    // All passes completed
                    state = DONE;
                    done = 1;
                end
        endcase
    end

    // Pack sorted data into output bus
    always @* begin
        if (state == DONE) begin
            out_data = packed_data;
        end
    end

    // Helper function to pack data into output bus
    function [WIDTH-1:0] packed_data;
        integer i;
        packed_data = 0;
        for (i = 0; i < N; i++) begin
            packed_data = packed_data << WIDTH;
            packed_data = packed_data | data_reg[i];
        end
        packed_data = packed_data >> (N * WIDTH);
        packed_data = packed_data << (N * WIDTH);
    endfunction

    // Initial state setup
    initial begin
        $sorting_engine_init();
    end

    // Initialization function
    function $sorting_engine_init;
        $init();
        state = IDLE;
    endfunction

endmodule
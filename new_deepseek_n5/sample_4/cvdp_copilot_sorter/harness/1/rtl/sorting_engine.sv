module sorting_engine (
    input clock,
    input rst,
    input start,
    input [WIDTH-1:0] in_data,
    output [WIDTH-1:0] out_data,
    output done
);

    // State machine states
    state state;
    enum state State = IDLE | SORTING | DONE;

    // State register
    reg state state_state = IDLE;

    // Internal registers
    reg [N*WIDTH-1:0] temp_data = 0;
    reg [N*WIDTH-1:0] sorted_data = 0;
    reg [N*WIDTH-1:0] input_data = 0;
    reg [N*WIDTH-1:0] output_data = 0;
    reg pass = 0;

    // Always blocks
    always @posedge clock begin
        case (state_state)
            IDLE:
                // Initialize on first reset
                if (rst) begin
                    state_state = IDLE;
                    sorted_data = 0;
                    input_data = 0;
                    output_data = 0;
                    pass = 0;
                end
                // Transition to SORTING state when start is asserted
                if (start) begin
                    state_state = SORTING;
                end
            SORTING:
                // Perform bubble sort passes
                if (pass < N*(N-1)) begin
                    // Compare and swap adjacent elements
                    for (int i = 0; i < N-1; i++) begin
                        if (input_data[i] > input_data[i+1]) begin
                            // Swap elements
                            reg [WIDTH-1:0] temp = input_data[i];
                            input_data[i] = input_data[i+1];
                            input_data[i+1] = temp;
                        end
                    end
                    // Decrement pass counter
                    pass = pass + 1;
                end
                // Transition to DONE state after all passes
                if (pass == N*(N-1)) begin
                    state_state = DONE;
                end
            DONE:
                // Output sorted data
                if (rst) begin
                    output_data = 0;
                else
                    output_data = sorted_data;
                end
        default:
            // No action
            state_state = IDLE;
    endcase
endmodule
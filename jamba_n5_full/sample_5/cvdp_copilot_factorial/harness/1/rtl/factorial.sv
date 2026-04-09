// Module for factorial computation in SystemVerilog
module factorial_rtl (
    input wire clk,
    input wire arst_n,
    input wire num_in,
    input wire start,
    output reg busy,
    output reg done,
    output reg [63:0] fact
);

    localparam NUM_STATES = 3;
    reg [NUM_STATES-1:0] state;
    reg next_state;

    // State transitions
    always @(posedge clk) begin
        state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= BUSY;
                    num_in <= 0;
                end
            end
            BUSY: begin
                if (arst_n) begin
                    state <= IDLE;
                end else begin
                    // Simulate factorial calculation for the given input
                    if (num_in == 0) begin
                        fact = 1;
                    end else begin
                        // Loop to multiply from 1 to num_in
                        for (int i = 1; i <= num_in; i++) begin
                            fact *= i;
                        end
                    end

                    // Deassert busy and assert done
                    done = 1'b1;
                end
            end
            DONE: begin
                done <= 1'b1;
                done_next <= 1'b0;
            end
        endcase
    end

    // Output assignments
    assign busy = state == BUSY;
    assign done = state == DONE;
    assign fact = factorial;

endmodule

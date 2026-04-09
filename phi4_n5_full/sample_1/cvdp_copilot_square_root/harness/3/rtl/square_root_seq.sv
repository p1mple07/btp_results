module square_root_seq #(parameter WIDTH = 16) (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);

    // State definitions
    localparam IDLE    = 1'b0;
    localparam COMPUTE = 1'b1;

    // Internal registers for the subtraction-based square root algorithm
    reg state;
    reg [WIDTH-1:0] remainder; // Holds the current remainder value
    reg [WIDTH-1:0] odd;       // Current odd number to subtract
    reg [WIDTH/2-1:0] root;    // Accumulates the square root result

    // Sequential process implementing the state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            remainder    <= 0;
            odd          <= 0;
            root         <= 0;
            final_root   <= 0;
            done         <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Initialization: set remainder to input num, odd to 1, and reset root
                        remainder <= num;
                        odd       <= 1;
                        root      <= 0;
                        state     <= COMPUTE;
                    end else begin
                        // Stay in IDLE and ensure done is cleared when not computing
                        state     <= IDLE;
                        done      <= 0;
                    end
                end

                COMPUTE: begin
                    if (remainder >= odd) begin
                        // Subtract the current odd number from remainder,
                        // increment the square root result, and update odd (next odd = odd + 2)
                        remainder <= remainder - odd;
                        root      <= root + 1;
                        odd       <= odd + 2;
                        state     <= COMPUTE;
                    end else begin
                        // Termination: remainder is less than the current odd number.
                        // Assign the computed square root to final_root and assert done.
                        final_root <= root;
                        done       <= 1;
                        state      <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
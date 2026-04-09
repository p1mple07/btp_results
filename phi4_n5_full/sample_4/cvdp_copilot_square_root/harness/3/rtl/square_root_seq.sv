module square_root_seq #(parameter WIDTH = 16)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg [WIDTH/2-1:0] final_root,
    output reg done
);

    // State machine states
    localparam IDLE   = 1'b0;
    localparam COMPUTE = 1'b1;

    reg state, next_state;

    // Registers for the subtraction-based iterative algorithm
    reg [WIDTH-1:0] remainder; // Holds the remaining value after subtractions
    reg [WIDTH-1:0] odd;       // Current odd number to subtract (initialized to 1)
    reg [WIDTH/2-1:0] root;    // Count of subtractions (the computed square root)

    // Next state logic (combinational)
    always @(*) begin
        next_state = state; // Default: hold current state
        case (state)
            IDLE: begin
                if (start)
                    next_state = COMPUTE;
                else
                    next_state = IDLE;
            end
            COMPUTE: begin
                if (remainder >= odd)
                    next_state = COMPUTE;
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Sequential process: state and register updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            remainder    <= 0;
            odd          <= 0;
            root         <= 0;
            final_root   <= 0;
            done         <= 0;
        end else begin
            state <= next_state;

            // In the IDLE state, if start is asserted, initialize the registers.
            if (state == IDLE) begin
                if (start) begin
                    remainder <= num;  // Load input number into remainder
                    odd       <= 1;    // Initialize the first odd number
                    root      <= 0;    // Reset the square root counter
                end
                done <= 0;
            end
            // In the COMPUTE state, perform the subtraction-based iteration.
            else if (state == COMPUTE) begin
                if (remainder >= odd) begin
                    remainder <= remainder - odd; // Subtract the current odd number
                    root      <= root + 1;         // Increment the square root count
                    odd       <= odd + 2;          // Update to the next odd number
                    done      <= 0;                // Not yet complete
                end else begin
                    final_root <= root;            // Computation complete: assign result
                    done       <= 1;              // Assert done for one clock cycle
                end
            end
        end
    end

endmodule
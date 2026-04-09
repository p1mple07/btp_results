module square_root_seq #(parameter WIDTH = 16) (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [WIDTH-1:0] num,
    output reg  [WIDTH/2-1:0] final_root,
    output reg  done
);

    // State encoding: 00 = IDLE, 01 = COMPUTE, 10 = DONE
    localparam IDLE   = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE   = 2'b10;

    reg [1:0] state;
    reg [WIDTH-1:0] remainder;
    reg [WIDTH-1:0] odd;
    reg [WIDTH/2-1:0] root_reg; // holds the computed square root

    // Sequential process: state machine with asynchronous reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            remainder     <= 0;
            odd           <= 0;
            root_reg      <= 0;
            done          <= 0;
            final_root    <= 0;
        end else begin
            case (state)
                IDLE: begin
                    // Wait for start signal
                    if (start) begin
                        remainder <= num;   // initialize remainder with input number
                        odd       <= 1;     // first odd number is 1
                        root_reg  <= 0;     // reset square root counter
                        state     <= COMPUTE;
                    end
                    // When not started, hold outputs
                    done          <= 0;
                    final_root    <= final_root;
                end

                COMPUTE: begin
                    // Subtraction-based iterative algorithm
                    if (remainder >= odd) begin
                        remainder <= remainder - odd;
                        root_reg  <= root_reg + 1;
                        odd       <= odd + 2;
                        state     <= COMPUTE;
                    end else begin
                        // When remainder is less than the current odd number,
                        // assign the computed square root and transition to DONE state.
                        final_root <= root_reg;
                        state      <= DONE;
                    end
                end

                DONE: begin
                    // Assert done for one clock cycle to indicate completion
                    done <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
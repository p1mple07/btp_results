module binary_multiplier #(
    parameter WIDTH = 32  // Bit-width of operands A and B
)(
    input  logic clk,
    input  logic rst_n,         // Active-low asynchronous reset
    input  logic valid_in,      // Indicates when inputs are valid (asserted for one cycle)
    input  logic [WIDTH-1:0]   A,   // Operand A
    input  logic [WIDTH-1:0]   B,   // Operand B
    output logic [2*WIDTH-1:0] Product, // Final multiplication result
    output logic               valid_out  // Indicates when Product is valid (asserted for one cycle)
);

    // Define state machine states for sequential operation.
    typedef enum logic [1:0] {
        IDLE   = 2'd0,
        COMPUTE = 2'd1,
        WAIT   = 2'd2,
        OUTPUT = 2'd3
    } state_t;

    state_t state, next_state;

    // Internal registers for latching inputs and accumulation.
    reg [WIDTH-1:0] latched_A, latched_B;
    reg [2*WIDTH-1:0] acc;  // Accumulator for partial sum
    integer i;              // Loop counter for bit positions (0 to WIDTH-1)
    
    // Synchronous process with asynchronous reset.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            i           <= 0;
            acc         <= '0;
            latched_A   <= '0;
            latched_B   <= '0;
            Product     <= '0;
            valid_out   <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    // Latch inputs when valid_in is asserted.
                    if (valid_in) begin
                        latched_A <= A;
                        latched_B <= B;
                        acc       <= '0;
                        i         <= 0;
                        state     <= COMPUTE;
                    end
                    else begin
                        state <= IDLE;
                    end
                end

                COMPUTE: begin
                    // Perform one iteration of the add-shift multiplication.
                    if (i < WIDTH) begin
                        // If the current bit of latched_A is 1, add (latched_B << i) to acc.
                        if (latched_A[i])
                            acc <= acc + (latched_B << i);
                        i   <= i + 1;
                        state <= COMPUTE;
                    end
                    else begin
                        // Completed all WIDTH iterations; move to WAIT state.
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    // One additional cycle delay.
                    state <= OUTPUT;
                end

                OUTPUT: begin
                    // Register the accumulated result and assert valid_out.
                    Product   <= acc;
                    valid_out <= 1'b1;
                    state     <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
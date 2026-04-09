module binary_multiplier #(
    parameter WIDTH = 32  // Bit-width of operands A and B
)(
    input  logic         clk,
    input  logic         rst_n,      // Active-low asynchronous reset
    input  logic         valid_in,   // Indicates when inputs are valid
    input  logic [WIDTH-1:0] A,        // Operand A
    input  logic [WIDTH-1:0] B,        // Operand B
    output logic         valid_out,  // Indicates when Product is valid
    output logic [2*WIDTH-1:0] Product  // Final multiplication result
);

    // Define state encoding for the state machine
    localparam STATE_IDLE   = 2'd0,
               STATE_COMPUTE = 2'd1,
               STATE_WAIT    = 2'd2;

    // Internal registers for state machine and computation
    reg [1:0] state;
    reg       start;               // Latched valid_in signal to indicate operation start
    reg [WIDTH-1:0] a_reg, b_reg;  // Latched copies of A and B
    reg [2*WIDTH-1:0] accum;       // Accumulated sum for multiplication
    reg [WIDTH-1:0] counter;       // Counts the number of computed bits (0 to WIDTH-1)
    reg [1:0] wait_counter;        // Counter for the additional 2-cycle delay
    reg [2*WIDTH-1:0] product_reg; // Registered final product output

    // Sequential process: Synchronous logic with asynchronous reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= STATE_IDLE;
            start        <= 1'b0;
            a_reg        <= '0;
            b_reg        <= '0;
            accum        <= '0;
            counter      <= '0;
            wait_counter <= '0;
            product_reg  <= '0;
            valid_out    <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    // Latch inputs and initiate computation when valid_in is asserted
                    if (valid_in) begin
                        a_reg     <= A;
                        b_reg     <= B;
                        accum     <= '0;
                        counter   <= '0;
                        wait_counter <= '0;
                        start     <= 1'b1;
                        state     <= STATE_COMPUTE;
                    end
                end

                STATE_COMPUTE: begin
                    // Perform one iteration of the add-shift multiplication per clock cycle
                    if (start) begin
                        if (counter < WIDTH) begin
                            // If the current bit of A is 1, add shifted B to the accumulator
                            if (a_reg[counter])
                                accum <= accum + (b_reg << counter);
                            counter <= counter + 1;
                        end else begin
                            // Completed WIDTH iterations; move to waiting state for latency
                            state <= STATE_WAIT;
                        end
                    end
                end

                STATE_WAIT: begin
                    // Wait for 2 additional clock cycles to meet the total latency requirement
                    if (wait_counter < 2) begin
                        wait_counter <= wait_counter + 1;
                    end else begin
                        // Register the final accumulated result and assert valid_out
                        product_reg  <= accum;
                        valid_out    <= 1'b1;
                        start        <= 1'b0;
                        state        <= STATE_IDLE;
                    end
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

    // Drive the output Product from the registered product register
    assign Product = product_reg;

endmodule
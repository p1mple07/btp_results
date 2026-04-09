module computes the factorial of a 5-bit input number.
// Ports:
//   clk       : Clock input.
//   arst_n    : Asynchronous active low reset.
//   num_in    : 5-bit input number (0 to 31) whose factorial is to be computed.
//   start     : Start signal to initiate computation (only accepted in IDLE).
//   busy      : Indicates that the design is busy computing.
//   fact      : 64-bit output holding the computed factorial.
//   done      : Asserted for one cycle in DONE state to indicate computation complete.

module factorial(
    input  logic         clk,
    input  logic         arst_n,
    input  logic [4:0]   num_in,
    input  logic         start,
    output logic         busy,
    output logic [63:0]  fact,
    output logic         done
);

    // FSM state definitions
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        BUSY = 2'b01,
        DONE = 2'b10
    } state_t;

    state_t state, next_state;

    // Registers for factorial computation
    logic [63:0] product;  // holds the running product
    logic [4:0]  counter;  // counts the number of multiplications performed

    // Sequential block: update state and computation registers on clock edge or asynchronous reset
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state      <= IDLE;
            product    <= 64'd1;
            counter    <= 5'd0;
        end else begin
            state <= next_state;
            case (next_state)
                IDLE: begin
                    // Prepare for a new computation: reset product and counter
                    product <= 64'd1;
                    counter <= 5'd0;
                end
                BUSY: begin
                    // Multiply product by (counter + 1) each cycle.
                    // When counter == num_in, the loop ends.
                    product <= product * (counter + 1);
                    counter <= counter + 1;
                end
                DONE: begin
                    // Hold the computed result.
                    product <= product;
                    counter <= counter;
                end
                default: begin
                    product <= product;
                    counter <= counter;
                end
            endcase
        end
    end

    // Combinational block: determine next state and output signals
    always_comb begin
        // Default assignments
        next_state = state;
        busy       = 1'b0;
        done       = 1'b0;
        fact       = product;

        case (state)
            IDLE: begin
                // Accept new input only if start is asserted.
                if (start)
                    next_state = BUSY;
                else
                    next_state = IDLE;
            end

            BUSY: begin
                // Continue multiplying until counter reaches num_in.
                if (counter < num_in)
                    next_state = BUSY;
                else
                    next_state = DONE;
            end

            DONE: begin
                // Stay in DONE for one cycle then return to IDLE.
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
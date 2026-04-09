Module for SPI Complex Multiply operation
module spi_complex_mult(
    input rst_async_n,
    input spi_sck,
    input spi_cs_n,
    input spi_mosi,
    output spi_miso
);

    // Internal variables
    reg [IN_WIDTH-1:0] Ar, Ai, Br, Bi;
    reg [OUT_WIDTH-1:0] Or, Oi;

    // Finite State Machine (FSM) states
    enum fsm_state {
        fsm_state_inital,
        fsm_state_load_coeff,
        fsm_state_perform_mult,
        fsm_state_add_sub,
        fsm_state_output,
        fsm_state_idle
    } curr_fsm_state = fsm_state_inital;

    // Coefficients buffer
    reg [
        2^(IN_WIDTH): 0
    ] coeffs = { {0} };

    // Multiplier resources
    multiplier m1, m2, m3, m4;

    // Adder/subtractor resources
    adder a1, a2;

    // Clock enable signals
    wire spi_CLK En, spi_CLKEnNext;

    // Main logic
    always_ff @(posedge spi_sck) begin
        case(curr_fsm_state)
            fsm_state_inital:
                curr_fsm_state = fsm_state_load_coeff;
                coeffs[0] = Ar;
                coeffs[1] = Ai;
                coeffs[2] = Br;
                coeffs[3] = Bi;

            fsm_state_load_coeff:
                curr_fsm_state = fsm_state_perform_mult;
                m1 #(.a1(coeffs[0]), .a2(coeffs[1]), .b1(1), .b2(1)) 
                    (.output() -> coeffs[2]);
                m2 #(.a1(coeffs[0]), .a2(coeffs[1]), .b1(1), .b2(-1)) 
                    (.output() -> coeffs[3]);
                m3 #(.a1(coeffs[2]), .a2(coeffs[3]), .b1(1), .b2(1)) 
                    (.output() -> coeffs[0]);
                m4 #(.a1(coeffs[2]), .a2(coeffs[3]), .b1(1), .b2(-1)) 
                    (.output() -> coeffs[1]);

            fsm_state_perform_mult:
                curr_fsm_state = fsm_state_add_sub;
                a1 #(.a1(coeffs[0]), .a2(coeffs[1]), .b1(coeffs[2]), .b2(coeffs[3]))
                    (.output() -> Or);
                a2 #(.a1(coeffs[0]), .a2(coeffs[1]), .b1(coeffs[2]), .b2(coeffs[3]))
                    (.output() -> Oi);

            fsm_state_add_sub:
                curr_fsm_state = fsm_state_output;
                // Prepare data for transmission
                // ...

            fsm_state_output:
                curr_fsm_state = fsm_state_idle;
                // Reset coefficients and prepare for next operation
                coeffs[0] = 0;
                coeffs[1] = 0;
                coeffs[2] = 0;
                coeffs[3] = 0;

            default:
                // Handle unexpected state transitions
                // ...
        endcase
    endalways;

    // Transmit data on spi_miso after processing
    // ...

endmodule
module hill_cipher (
    input  logic         clk,
    input  logic         reset,
    input  logic         start,
    input  logic [14:0]  plaintext,   // 3 letters, 5 bits each
    input  logic [44:0]  key,         // 9 elements, 5 bits each
    output logic [14:0]  ciphertext,  // 3 letters, 5 bits each 
    output logic         done
);

    // Split plaintext into individual 5-bit letters
    logic [4:0] P0, P1, P2;
    // Extract key matrix elements
    logic [4:0] K00, K01, K02;
    logic [4:0] K10, K11, K12;
    logic [4:0] K20, K21, K22;

    // Intermediate computation registers.
    // Each term (Kxx * Py) % MOD yields a value in [0,25]. Their sum is at most 75,
    // so 7 bits are sufficient to hold the sum without truncation warnings.
    logic [6:0] temp0, temp1, temp2;
    // Final ciphertext registers (each 5 bits)
    logic [4:0] C0_reg, C1_reg, C2_reg;

    // Define modulus constant with an explicit width to match the intermediate results.
    parameter logic [9:0] MOD = 10'd26;

    // Finite state machine states
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        COMPUTE     = 2'b01,
        COMPUTE_MOD = 2'b10,
        DONE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Assign individual plaintext segments
    assign P0 = plaintext[14:10];
    assign P1 = plaintext[9:5];
    assign P2 = plaintext[4:0];

    // Assign key matrix elements from the 45-bit key vector
    assign K00 = key[44:40];
    assign K01 = key[39:35];
    assign K02 = key[34:30];
    assign K10 = key[29:25];
    assign K11 = key[24:20];
    assign K12 = key[19:15];
    assign K20 = key[14:10];
    assign K21 = key[9:5];
    assign K22 = key[4:0];

    // Synchronous state register update
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Combinational next-state logic and done signal generation
    always_comb begin
        next_state = current_state;
        done       = 1'b0;

        case (current_state)
            IDLE: begin
                if (start)
                    next_state = COMPUTE;
            end
            COMPUTE: begin
                next_state = COMPUTE_MOD;
            end
            COMPUTE_MOD: begin
                next_state = DONE;
            end
            DONE: begin
                done       = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Computation and register update logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            temp0  <= 7'b0;
            temp1  <= 7'b0;
            temp2  <= 7'b0;
            C0_reg <= 5'b0;
            C1_reg <= 5'b0;
            C2_reg <= 5'b0;
        end
        else begin
            case (current_state)
                COMPUTE: begin
                    // Each multiplication yields a 10-bit result; applying % MOD (10'd26)
                    // gives a value in [0,25]. We then add three such terms.
                    // Slicing the sum to 7 bits avoids any truncation warnings.
                    temp0 <= ((((K00 * P0) % MOD) + ((K01 * P1) % MOD) + ((K02 * P2) % MOD)))[6:0];
                    temp1 <= ((((K10 * P0) % MOD) + ((K11 * P1) % MOD) + ((K12 * P2) % MOD)))[6:0];
                    temp2 <= ((((K20 * P0) % MOD) + ((K21 * P1) % MOD) + ((K22 * P2) % MOD)))[6:0];
                end
                COMPUTE_MOD: begin
                    // Extend the 7-bit intermediate result to 9 bits to safely perform modulo.
                    // The final result (in the range 0-25) is then sliced to 5 bits.
                    C0_reg <= ( {2{1'b0}, temp0} % MOD )[4:0];
                    C1_reg <= ( {2{1'b0}, temp1} % MOD )[4:0];
                    C2_reg <= ( {2{1'b0}, temp2} % MOD )[4:0];
                end
                default: begin
                    temp0  <= 7'b0;
                    temp1  <= 7'b0;
                    temp2  <= 7'b0;
                    C0_reg <= 5'b0;
                    C1_reg <= 5'b0;
                    C2_reg <= 5'b0;
                end
            endcase
        end
    end

    // Combine the three 5-bit ciphertext registers into a 15-bit output.
    assign ciphertext = {C0_reg, C1_reg, C2_reg};

endmodule
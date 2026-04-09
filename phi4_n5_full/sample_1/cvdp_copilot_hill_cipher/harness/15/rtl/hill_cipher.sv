module hill_cipher (
    input  logic         clk,
    input  logic         reset,
    input  logic         start,
    input  logic [14:0]  plaintext,   // 3 letters, 5 bits each
    input  logic [44:0]  key,         // 9 elements, 5 bits each (3×3 matrix)
    output logic [14:0]  ciphertext,  // 3 letters, 5 bits each
    output logic         done
);

    // Extract plaintext letters
    logic [4:0] P0, P1, P2;
    // Extract key matrix elements
    logic [4:0] K00, K01, K02;
    logic [4:0] K10, K11, K12;
    logic [4:0] K20, K21, K22;

    // Intermediate sums: increased width to 7 bits to safely hold sums up to 75
    logic [6:0] temp0, temp1, temp2;
    // Final ciphertext registers
    logic [4:0] C0_reg, C1_reg, C2_reg;

    // Define modulo constant (26) with explicit width to avoid mismatches
    localparam logic [4:0] MOD_VALUE = 26;

    // State machine definition
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        COMPUTE     = 2'b01,
        COMPUTE_MOD = 2'b10,
        DONE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Assign plaintext letters
    assign P0 = plaintext[14:10];
    assign P1 = plaintext[9:5];
    assign P2 = plaintext[4:0];

    // Assign key matrix elements
    assign K00 = key[44:40];
    assign K01 = key[39:35];
    assign K02 = key[34:30];
    assign K10 = key[29:25];
    assign K11 = key[24:20];
    assign K12 = key[19:15];
    assign K20 = key[14:10];
    assign K21 = key[9:5];
    assign K22 = key[4:0];

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state and done signal generation
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
                done = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Computation logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Use width-matched reset values (7 bits for temp signals)
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
                    // Compute intermediate sums with modulo applied per term.
                    // Each multiplication (5-bit * 5-bit) yields a 10-bit result,
                    // and applying % MOD_VALUE gives a 5-bit value. The sum of three such terms
                    // can be as high as 75, which fits in 7 bits.
                    temp0 <= ((K00 * P0) % MOD_VALUE) 
                         + ((K01 * P1) % MOD_VALUE) 
                         + ((K02 * P2) % MOD_VALUE);
                    temp1 <= ((K10 * P0) % MOD_VALUE) 
                         + ((K11 * P1) % MOD_VALUE) 
                         + ((K12 * P2) % MOD_VALUE);
                    temp2 <= ((K20 * P0) % MOD_VALUE) 
                         + ((K21 * P1) % MOD_VALUE) 
                         + ((K22 * P2) % MOD_VALUE);
                end
                COMPUTE_MOD: begin
                    // Apply modulo to intermediate sums to obtain final ciphertext digits.
                    C0_reg <= temp0 % MOD_VALUE;
                    C1_reg <= temp1 % MOD_VALUE;
                    C2_reg <= temp2 % MOD_VALUE;
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

    // Combine ciphertext registers into final output
    assign ciphertext = {C0_reg, C1_reg, C2_reg};

endmodule
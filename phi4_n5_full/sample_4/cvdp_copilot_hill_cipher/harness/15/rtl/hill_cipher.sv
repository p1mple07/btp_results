module hill_cipher (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [14:0] plaintext,   // 3 letters, 5 bits each
    input logic [44:0] key,         // 9 elements, 5 bits each
    output logic [14:0] ciphertext, // 3 letters, 5 bits each 
    output logic done
);

    // Extract plaintext letters
    logic [4:0] P0, P1, P2;
    // Extract key matrix elements
    logic [4:0] K00, K01, K02;
    logic [4:0] K10, K11, K12;
    logic [4:0] K20, K21, K22;

    // Use wider registers for intermediate multiplication sum
    logic [11:0] temp0, temp1, temp2;
    // Ciphertext registers
    logic [4:0] C0_reg, C1_reg, C2_reg;

    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        COMPUTE     = 2'b01,
        COMPUTE_MOD = 2'b10,
        DONE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Assign plaintext segments
    assign P0 = plaintext[14:10];
    assign P1 = plaintext[9:5];
    assign P2 = plaintext[4:0];

    // Assign key matrix segments
    assign K00 = key[44:40];
    assign K01 = key[39:35];
    assign K02 = key[34:30];
    assign K10 = key[29:25];
    assign K11 = key[24:20];
    assign K12 = key[19:15];
    assign K20 = key[14:10];
    assign K21 = key[9:5];
    assign K22 = key[4:0];

    // State register update
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic and done signal generation
    always_comb begin
        next_state = current_state;
        done = 1'b0;

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

    // Data processing and register updates
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            temp0 <= 12'b0;
            temp1 <= 12'b0;
            temp2 <= 12'b0;
            C0_reg <= 5'b0;
            C1_reg <= 5'b0;
            C2_reg <= 5'b0;
        end
        else begin
            case (current_state)
                COMPUTE: begin
                    // Compute the full multiplication sum for each ciphertext element
                    temp0 <= (K00 * P0) + (K01 * P1) + (K02 * P2);
                    temp1 <= (K10 * P0) + (K11 * P1) + (K12 * P2);
                    temp2 <= (K20 * P0) + (K21 * P1) + (K22 * P2);
                end
                COMPUTE_MOD: begin
                    // Apply modulo operation to obtain final ciphertext digits
                    C0_reg <= temp0 % 5'd26;
                    C1_reg <= temp1 % 5'd26;
                    C2_reg <= temp2 % 5'd26;
                end
                default: begin
                    temp0 <= 12'b0;
                    temp1 <= 12'b0;
                    temp2 <= 12'b0;
                    C0_reg <= 5'b0;
                    C1_reg <= 5'b0;
                    C2_reg <= 5'b0;
                end
            endcase
        end
    end

    // Combine registers to form ciphertext
    assign ciphertext = {C0_reg, C1_reg, C2_reg};

endmodule
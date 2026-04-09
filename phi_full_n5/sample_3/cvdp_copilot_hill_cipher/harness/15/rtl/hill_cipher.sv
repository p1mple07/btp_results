module hill_cipher (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [14:0] plaintext,   // Corrected to 14-bit to match the plaintext size
    input logic [44:0] key,         // Corrected to 44-bit to match the key matrix size
    output logic [14:0] ciphertext, // Corrected to 14-bit to match the plaintext size
    output logic done
);

    logic [4:0] P0, P1, P2;
    logic [4:0] K00, K01, K02, K10, K11, K12, K20, K21, K22;
    logic [5:0] temp0, temp1, temp2;
    logic [5:0] C0_reg, C1_reg, C2_reg;

    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        COMPUTE     = 2'b01,
        COMPUTE_MOD = 2'b10,
        DONE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    assign P0 = plaintext[14:10];
    assign P1 = plaintext[9:5];
    assign P2 = plaintext[4:0];

    assign K00 = key[39:35];
    assign K01 = key[34:30];
    assign K02 = key[33:29];
    assign K10 = key[28:24];
    assign K11 = key[27:23];
    assign K12 = key[26:22];
    assign K20 = key[23:19];
    assign K21 = key[22:18];
    assign K22 = key[21:17];

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

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

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            temp0 <= 0;
            temp1 <= 0;
            temp2 <= 0;
            C0_reg <= 0;
            C1_reg <= 0;
            C2_reg <= 0;
        end
        else begin
            case (current_state)
                COMPUTE: begin
                    temp0 <= (K00 * P0 + K01 * P1 + K02 * P2) % 2^5;
                    temp1 <= (K10 * P0 + K11 * P1 + K12 * P2) % 2^5;
                    temp2 <= (K20 * P0 + K21 * P1 + K22 * P2) % 2^5;
                end
                COMPUTE_MOD: begin
                    C0_reg <= temp0 % 2^5;
                    C1_reg <= temp1 % 2^5;
                    C2_reg <= temp2 % 2^5;
                end
                default: begin
                    temp0 <= 0;
                    temp1 <= 0;
                    temp2 <= 0;
                    C0_reg <= 0;
                    C1_reg <= 0;
                    C2_reg <= 0;
                end
            endcase
        end
    end

    assign ciphertext = {C0_reg, C1_reg, C2_reg};

endmodule

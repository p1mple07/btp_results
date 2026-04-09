module hill_cipher (
    input  logic         clk,
    input  logic         reset,
    input  logic         start,
    input  logic [14:0]  plaintext,  // [14:10] = first letter, [9:5] = second, [4:0] = third
    input  logic [44:0]  key,        // key matrix elements: key[44:40]=K00, key[39:35]=K01, key[34:30]=K02,
                                  // key[29:25]=K10, key[24:20]=K11, key[19:15]=K12,
                                  // key[14:10]=K20, key[9:5]=K21, key[4:0]=K22
    output logic [14:0]  ciphertext, // [14:10] = C0, [9:5] = C1, [4:0] = C2
    output logic         done
);

    // FSM state encoding
    typedef enum logic [2:0] {
        STATE_IDLE   = 3'd0,
        STATE_COMPUTE0 = 3'd1,
        STATE_COMPUTE1 = 3'd2,
        STATE_COMPUTE2 = 3'd3,
        STATE_DONE   = 3'd4
    } state_t;

    state_t state, next_state;

    // Registers to hold the plaintext letters and key matrix elements
    logic [4:0] P0, P1, P2;
    logic [4:0] K00, K01, K02;
    logic [4:0] K10, K11, K12;
    logic [4:0] K20, K21, K22;
    // Registers to hold the computed ciphertext letters
    logic [4:0] C0, C1, C2;

    //-------------------------------------------------------------------------
    // Function: mod26
    // Description: Computes the remainder when a 11-bit number is divided by 26.
    // Input sum is computed from the matrix multiplication (each product is 10 bits).
    //-------------------------------------------------------------------------
    function automatic [4:0] mod26 (input [10:0] sum);
        begin
            mod26 = sum % 26;
        end
    endfunction

    //-------------------------------------------------------------------------
    // FSM: Sequential process for encryption.
    // Latency: The ciphertext is available three clock cycles after start is asserted.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= STATE_IDLE;
            C0         <= 5'd0;
            C1         <= 5'd0;
            C2         <= 5'd0;
            ciphertext <= 15'd0;
            done       <= 1'b0;
        end
        else begin
            case (state)
                STATE_IDLE: begin
                    if (start) begin
                        // Load plaintext and key matrix values
                        P0  <= plaintext[14:10];
                        P1  <= plaintext[9:5];
                        P2  <= plaintext[4:0];
                        K00 <= key[44:40];
                        K01 <= key[39:35];
                        K02 <= key[34:30];
                        K10 <= key[29:25];
                        K11 <= key[24:20];
                        K12 <= key[19:15];
                        K20 <= key[14:10];
                        K21 <= key[9:5];
                        K22 <= key[4:0];
                        state <= STATE_COMPUTE0;
                    end
                end

                STATE_COMPUTE0: begin
                    // Compute row 0: C0 = mod26(K00*P0 + K01*P1 + K02*P2)
                    // Extend 5-bit numbers to 6 bits for multiplication so that the product fits in 11 bits.
                    C0 <= mod26(({1'b0, K00} * P0) + ({1'b0, K01} * P1) + ({1'b0, K02} * P2));
                    state <= STATE_COMPUTE1;
                end

                STATE_COMPUTE1: begin
                    // Compute row 1: C1 = mod26(K10*P0 + K11*P1 + K12*P2)
                    C1 <= mod26(({1'b0, K10} * P0) + ({1'b0, K11} * P1) + ({1'b0, K12} * P2));
                    state <= STATE_COMPUTE2;
                end

                STATE_COMPUTE2: begin
                    // Compute row 2: C2 = mod26(K20*P0 + K21*P1 + K22*P2)
                    C2 <= mod26(({1'b0, K20} * P0) + ({1'b0, K21} * P1) + ({1'b0, K22} * P2));
                    state <= STATE_DONE;
                end

                STATE_DONE: begin
                    // Combine the computed ciphertext letters and assert done.
                    ciphertext <= {C0, C1, C2};
                    done       <= 1'b1;
                    state      <= STATE_IDLE;  // Ready for next encryption block
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
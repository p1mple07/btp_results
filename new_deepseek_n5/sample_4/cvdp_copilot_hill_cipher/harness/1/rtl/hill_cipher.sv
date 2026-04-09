// Module: Hill Cipher Encryption
// Description: RTL implementation of Hill cipher encryption algorithm with 3x3 key matrix
// Inputs: Plaintext (15 bits), Key (45 bits), Clock, Reset
// Outputs: Ciphertext (15 bits), Done signal
// Block size: 3 letters (15 bits total)
// Modular arithmetic: mod 26

// State Machine for Hill Cipher
state state_state;
    // State 0: Initial state, waiting for start
    // State 1: Loading plaintext
    // State 2: Loading key
    // State 3: Performing multiplication
    // State 4: Done
initial state = 0;

// FSM transitions
always_state_state begin
    if (clk) begin
        case (state_state)
            0: state_state = 1; // Wait for start signal
            1: state_state = 2; // Load plaintext
            2: state_state = 3; // Load key
            3: state_state = 4; // Encrypt and done
            default: state_state = 0;
        endcase
    end
end

// Plaintext FIFO
reg [14:0] plaintext_FIFO;
// Key FIFO
reg [44:0] key_FIFO;
// Ciphertext FIFO
reg [14:0] ciphertext_FIFO;

// Key matrix (hardcoded for example)
localparam key_matrix = [
    3, 10, 20,
    1, 9, 15,
    8, 7, 17
];

// Plaintext to number mapping
function int plaintext_to_num;
    input [4:0] b;
    output int res;
    res = 0;
    for (int i = 4; i >= 0; i--) begin
        res = (b[i] << (4 - i)) + res;
    end
    return res;
endfunction

// Number to plaintext mapping
function int num_to_plaintext;
    input [4:0] b;
    output int res;
    res = 0;
    for (int i = 0; i < 5; i++) begin
        res = (b[i] << (4 - i)) + res;
    end
    return res;
endfunction

// Matrix multiplication and mod 26
always_state_state == 3 begin
    // Load plaintext and key from FIFO
    plaintext = plaintext_FIFO;
    key = key_FIFO;
    
    // Process each element of plaintext vector
    int p1 = plaintext_to_num(plaintext[14:10]);
    int p2 = plaintext_to_num(plaintext[9:5]);
    int p3 = plaintext_to_num(plaintext[4:0]);
    
    int c1 = (key[44:40] * p1 + key[43:39] * p2 + key[42:38] * p3) % 26;
    int c2 = (key[37:33] * p1 + key[36:32] * p2 + key[35:31] * p3) % 26;
    int c3 = (key[29:25] * p1 + key[28:24] * p2 + key[27:23] * p3) % 26;
    
    // Store ciphertext in FIFO
    ciphertext_FIFO[14:0] = (c1 << 10) | (c2 << 5) | c3;
    
    // Set done signal
    done = 1;
end
module rtl/hill_cipher (
    input clock,
    input reset,
    input start,
    input plaintext,
    input key,
    output ciphertext,
    output done
);

    // FSM states
    state state = 0;
    state done_state = 0;

    // State transitions
    always_ff+ state begin
        state <= done_state;
    end

    // Key matrix multiplication
    reg [4:0] key_elements = [
        key[44:40], key[39:35], key[34:30],
        key[29:25], key[24:20], key[19:15],
        key[14:10], key[9:5], key[4:0]
    ];

    // Plaintext vector
    reg [14:0] plaintext_vector = [
        plaintext[14:10], plaintext[9:5], plaintext[4:0]
    ];

    // Ciphertext vector
    reg [14:0] ciphertext_vector;

    // Intermediate results
    reg [5:0] temp1, temp2, temp3;

    // Adders
    reg [10:0] adder1, adder2, adder3;

    // Modulo 26 operation
    reg [4:0] mod_result;

    // State machine
    if (start) begin
        state = 1;
        // Initialize
        done_state = 0;
    end

    // Processing
    if (state == 1) begin
        // Extract key elements
        temp1 = key_elements[0] * plaintext_vector[0];
        temp2 = key_elements[1] * plaintext_vector[1];
        temp3 = key_elements[2] * plaintext_vector[2];

        // Sum for C0
        adder1 = temp1 + temp2;
        adder1 = adder1 + temp3;

        // Modulo 26
        mod_result = adder1 % 26;

        // Update state
        state = 2;
    end

    // Next processing step
    if (state == 2) begin
        // Extract next key elements
        temp1 = key_elements[3] * plaintext_vector[0];
        temp2 = key_elements[4] * plaintext_vector[1];
        temp3 = key_elements[5] * plaintext_vector[2];

        // Sum for C1
        adder2 = temp1 + temp2;
        adder2 = adder2 + temp3;

        // Modulo 26
        mod_result = adder2 % 26;

        // Update state
        state = 3;
    end

    // Final processing step
    if (state == 3) begin
        // Extract next key elements
        temp1 = key_elements[6] * plaintext_vector[0];
        temp2 = key_elements[7] * plaintext_vector[1];
        temp3 = key_elements[8] * plaintext_vector[2];

        // Sum for C2
        adder3 = temp1 + temp2;
        adder3 = adder3 + temp3;

        // Modulo 26
        mod_result = adder3 % 26;

        // Update state
        state = 4;
    end

    // Output ciphertext
    if (state == 4) begin
        ciphertext_vector[2] = mod_result;
        ciphertext_vector[1] = mod_result;
        ciphertext_vector[0] = mod_result;

        // Set done signal
        done_state = 1;
    end

    // Output
    ciphertext = ciphertext_vector;
    done = done_state;
end
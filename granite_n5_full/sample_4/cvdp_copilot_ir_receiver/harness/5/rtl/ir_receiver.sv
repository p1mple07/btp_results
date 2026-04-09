module ir_receiver (
    input  logic        reset_in,               // Active HIGH reset
    input  logic        clk_in,                 // System clock (10 KHz, 100us).
    input  logic        ir_signal_in,           // Input signal (IR).
    output logic [6:0]  ir_function_code_out,   // Decoded output for different functions.
    output logic [4:0]  ir_device_address_out,  // "00001": TV, "00010":HDMI1, "00100":USB, "010000":HDMI2, "100000": VCR.
    output logic        ir_output_valid         // Indicates validity of the decoded frame.
);

    typedef enum logic [2:0] {idle, start, decoding, finish, frame_space} ir_state;

    ir_state present_state, next_state;

    logic started;
    logic decoded;
    logic failed;
    logic success;
    logic frame_full;
    logic ir_frame_valid;

    int cycle_counter;
    int frame_space_counter;
    int bit_counter;

    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;
    logic stored;

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in)
        next_state = idle;
    else
        next_state = start;

endmodule
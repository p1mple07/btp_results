module ir_receiver (
    input  logic        reset_in,               // Active HIGH reset
    input  logic        clk_in,                 // System clock (10 KHz, 100us)
    input  logic        ir_signal_in,           // Input signal (IR). It is recommended to split the input signal into two separate inputs, one for address decoding and another for function decoding.
    output logic [6:0]  ir_function_code_out,   // Decoded output for different functions
    output logic [4:0]  ir_device_address_out,  // "00001": TV, "00010":HDMI1, "00100":USB, "01000":HDMI2, "100000": VCR
    output logic        ir_output_valid         // Indicates validity of the decoded frame
);

    typedef enum logic [2:0] {idle, start, decoding, finish, frame_space} ir_state;
    ir_state present_state, next_state;

    logic started;
    logic decoded;
    logic failed;
    logic success;
    logic frame_space;
    logic bit_counter;

    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;
    logic stored;

    always_ff @(posedge clk_in or posedge reset_in.
    always_comb begin
        case (present_state)
            idle: begin
                if (ir_signal_in == 1 and started == 0)
                    next_state = start.
                else if (started == 1 and stored == 0)
                    next_state = idle.
                else
                    next_state = start.
    end

endmodule
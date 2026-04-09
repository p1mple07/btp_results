module ir_receiver (
    input  logic        reset_in,               // Active HIGH reset
    input  logic        clk_in,                 // System clock (10 KHz, 100us)
    input  logic        ir_signal_in,           // Input signal (IR)
    output logic [6:0]  ir_function_code_out,   // Decoded output for different functions
    output logic [4:0]  ir_device_address_out,  // "00001": TV, "00010":HDMI1, "00100":USB, "010000":HDMI2, "100000": VCR
    output logic        ir_output_valid         // Indicates validity of the decoded frame
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
            present_state <= idle;
        else if (started)
            present_state <= start;
        else
            present_state <= idle;
        end

    always_comb begin
        case (present_state)
            idle: begin
                if (ir_signal_in)
                    next_state <= start;
                else if (started)
                    next_state <= decoding;
                else
                    next_state <= idle;
            end
            start: begin
                next_state <= decoding;
            end
            decoding: begin
                if (decoded)
                    next_state <= finish;
                else
                    next_state <= decoding;
            end
            finish: begin
                if (success)
                    next_state <= frame_space;
                else
                    next_state <= finish;
            end
            frame_space: begin
                // Insert code for decoding and frame space logic here
                

endmodule
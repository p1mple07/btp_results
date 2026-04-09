module ir_receiver (
    input  logic        reset_in,               // Active HIGH reset
    input  logic        clk_in,                 // System clock (10 KHz, 100us)
    input  logic        ir_signal_in,           // Input signal (IR)
    output logic [6:0]  ir_function_code_out,   // Decoded output for different functions
    output logic [4:0]  ir_device_address_out,  // "00001": TV, "00010": HDMI1, "00100": USB, "01000": VCR
    output logic        ir_output_valid         // Indicates validity of the decoded frame
);

    typedef enum logic [2:0] { idl, st, dec, fin, fs } ir_state;
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
            present_state <= idl;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idl: begin
                if (ir_signal_in == 1 && started == 0)
                    next_state = st;
                else
                    next_state = idl;
            end
            st: begin
                if (ir_signal_in == 0 && started == 1)
                    next_state = dec;
                else if (failed == 1)
                    next_state = idl;
                else
                    next_state = st;
            end
            dec: begin
                bit_counter <= bit_counter + 1;
                ir_frame_reg <= ir_signal_in;
                if (bit_counter == 12) begin
                    next_state = fin;
                end else if (bit_counter == 11) begin
                    next_state = fs;
                end
            end
            fin: begin
                ir_function_code_out = ir_frame_reg[7:0];
                ir_device_address_out = ir_frame_reg[12:17];
                ir_output_valid = 1;
                next_state = fs;
            end
            fs: begin
                if (success == 1)
                    next_state = fr;
                else
                    next_state = fsp;
            end

            // Finish if no more states
            default: next_state = idl;
        endcase
    end

endmodule

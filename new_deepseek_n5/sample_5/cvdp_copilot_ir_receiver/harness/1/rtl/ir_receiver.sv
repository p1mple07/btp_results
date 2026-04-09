module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    typedef enum logic [1:0] {idle, start, decoding, finish} ir_state;
    ir_state present_state, next_state;

    logic started; 
    logic decoded; 
    logic failed; 
    logic success;

    int cycle_counter; 
    int bit_counter;          

    logic [11:0] ir_frame_reg; 
    logic stored;                       

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            idle: begin
                // Start bit detection
                if (!reset_in) begin
                    if (!ir_signal_in && present_state == idle) begin
                        present_state = start;
                    end
                end
            end
            start: begin
                // Data bit detection
                if (!reset_in) begin
                    bit_counter = 0;
                    ir_frame_reg = 0;
                    present_state = decoding;
                end
            end
            decoding: begin
                if (!reset_in && bit_counter < 12) begin
                    // Process data bit
                    if (ir_signal_in) begin
                        ir_frame_reg[bit_counter] = 1;
                    end else begin
                        ir_frame_reg[bit_counter] = 0;
                    end
                    bit_counter++;
                    present_state = decoding;
                end
            end
            finish: begin
                // Finalize output
                if (!reset_in) begin
                    ir_frame_valid = 1;
                    present_state = finish;
                end
            end
        end
    end

    // Edge case handling
    always @(posedge clk_in) begin
        if (!reset_in && present_state == idle) begin
            if (ir_signal_in && present_state == idle) begin
                present_state = start;
            end else begin
                present_state = idle;
            end
        end
        if (!reset_in && present_state == start) begin
            if (!ir_signal_in) begin
                present_state = idle;
            end
        end
        if (!reset_in && present_state == decoding) begin
            if (bit_counter != 12) begin
                present_state = decoding;
            end else begin
                present_state = finish;
            end
        end
    end
endmodule
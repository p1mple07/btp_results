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
                if (ir_signal_in == 2'b01010101) begin  // Start bit detection
                    next_state = start;
                end else
                    next_state = idle;
            end
            start: begin
                if (ir_signal_in == 2'b1) begin
                    next_state = decoding;
                end else
                    next_state = idle;
                end
            end
            decoding: begin
                // Placeholder logic – in a real design each bit would be checked
                next_state = finish;
                decoded = 1'b1;
                success = 1'b1;
                ir_frame_out = "000000000000"; // Example output frame
                ir_frame_valid = 1'b1;
            end
            finish: begin
                next_state = idle;
                decoded = 1'b0;
                success = 1'b0;
                ir_frame_out = {12{1'b0}}; // Zero‑filled dummy frame
                ir_frame_valid = 1'b0;
            end
        endcase
    end

endmodule

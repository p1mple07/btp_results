module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic [11:0] ir_signal_in,   // Input signal (IR)
    output logic [11:0] ir_frame_out,   // Decoded 12-bit frame
    output logic        ir_frame_valid  // Indicates validity of the decoded frame
);

    typedef enum logic [1:0] {idle, start, decoding, finish, error} ir_state;
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
                if (ir_signal_in == 1'b0 && started) begin
                    started <= 0;
                    ir_frame_reg <= 12'b0;
                    bit_counter <= 0;
                    cycle_counter <= 0;
                    decoded <= 0;
                    started <= 0;
                    success <= 0;
                    failed <= 0;
                end
            end
            start: begin
                started <= 1;
                decoded <= 0;
                failed <= 0;
                success <= 0;
            end
            decoding: begin
                if (bit_counter == 0) begin
                    if (ir_signal_in == 1'b0 && cycle_counter == 0.6) begin
                        ir_frame_reg[bit_counter] <= 1'b0;
                        cycle_counter <= cycle_counter + 0.6;
                        bit_counter <= bit_counter + 1;
                    end else begin
                        failed <= 1;
                        decoded <= 0;
                    end
                end else begin
                    if (ir_signal_in == 1'b1 && cycle_counter == 0.6 ||
                        ir_signal_in == 1'b1 && cycle_counter == 1.2) begin
                        ir_frame_reg[bit_counter] <= ir_signal_in;
                        cycle_counter <= cycle_counter + ir_signal_in;
                        bit_counter <= bit_counter + 1;
                    end else begin
                        failed <= 1;
                        decoded <= 0;
                    end
                end
            end
            finish: begin
                decoded <= 1;
                ir_frame_valid <= 1;
                started <= 0;
            end
            error: begin
                failed <= 1;
                decoded <= 0;
            end
        endcase
    end

    always_ff @(posedge clk_in) begin
        if (failed)
            ir_frame_out <= 12'b0;
        else if (decoded)
            ir_frame_out <= ir_frame_reg;
        else
            ir_frame_out <= 12'b0;
    end

endmodule

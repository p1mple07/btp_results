module ir_receiver (
    input  logic        reset_in,       // Active HIGH reset
    input  logic        clk_in,         // System clock (100 KHz, 10us)
    input  logic        ir_signal_in,   // Input signal (IR)
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
                if (ir_signal_in) begin
                    started <= 1;
                    cycle_counter <= 0;
                    bit_counter <= 0;
                end else
                    started <= 0;
            end
            start: begin
                if (!started || (cycle_counter >= 2400)) begin
                    started <= 0;
                    cycle_counter <= 0;
                    bit_counter <= 0;
                    decoded <= 0;
                    failed <= 0;
                    success <= 0;
                end
                else begin
                    cycle_counter <= cycle_counter + 1;
                    if (cycle_counter == 2400) begin
                        decoded <= 1;
                        started <= 0;
                    end
                end
            end
            decoding: begin
                if (cycle_counter < 1800) begin
                    bit_counter <= bit_counter + 1;
                    if (cycle_counter < 600) begin
                        if (ir_signal_in) begin
                            ir_frame_reg[bit_counter] <= 0;
                        end else begin
                            failed <= 1;
                            decoded <= 0;
                        end
                    end else begin
                        if (cycle_counter < 1200) begin
                            ir_frame_reg[bit_counter] <= 1;
                        end else begin
                            failed <= 1;
                            decoded <= 0;
                        end
                    end
                end else begin
                    if (bit_counter == 12) begin
                        ir_frame_valid <= 1;
                        success <= 1;
                        decoded <= 1;
                        finished <= 1;
                    end else begin
                        failed <= 1;
                        decoded <= 0;
                    end
                end
            end
            finish: begin
                if (decoded) begin
                    ir_frame_out <= ir_frame_reg;
                    ir_frame_valid <= 1;
                    finished <= 1;
                end else begin
                    ir_frame_valid <= 0;
                    finished <= 1;
                end
            end
            error: begin
                ir_frame_valid <= 0;
                finished <= 1;
            end
        endcase
    end

endmodule

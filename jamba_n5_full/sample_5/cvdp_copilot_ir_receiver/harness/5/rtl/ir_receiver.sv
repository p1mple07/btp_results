module ir_receiver (
    input  logic        reset_in,
    input  logic        clk_in,
    input  logic        ir_signal_in,
    output logic [6:0]  ir_function_code_out,
    output logic [4:0]  ir_device_address_out,
    output logic        ir_output_valid
);

    localparam IDLE   = 2'b00;
    localparam START  = 2'b01;
    localparam DECODE = 2'b10;
    localparam FINISH = 2'b11;
    localparam FRAME_SPACE = 2'b100;

    reg [2:0] present_state;
    reg started;
    reg decoded;
    reg failed;
    reg success;
    reg frame_full;
    reg ir_frame_valid;

    int cycle_counter;
    int frame_space_counter;
    int bit_counter;

    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            IDLE: begin
                if (ir_signal_in == 1) begin
                    next_state = START;
                end else
                    next_state = IDLE;
                end
            end
            START: begin
                if (ir_signal_in == 0) begin
                    next_state = DECODE;
                end else if (failed == 1)
                    next_state = IDLE;
                else
                    next_state = START;
                end
            end
            DECODE: begin
                for (int bit_index = 0; bit_index < 12; bit_index++) begin
                    if (bit_counter == bit_index) begin
                        if (ir_frame_reg[bit_index] == '1) begin
                            // 0 pattern
                            if (bit_index == 0) { ... }
                            else if (bit_index == 1) { ... }
                        end else begin
                            if (ir_frame_reg[bit_index] == '0) begin
                                // 1 pattern
                                if (bit_index == 0) { ... }
                                else if (bit_index == 1) { ... }
                            end else begin
                                failed = 1;
                                success = 0;
                                next_state = IDLE;
                                break;
                            end
                        end
                    end else if (ir_frame_reg[bit_index] == '0) begin
                        // continue reading all bits
                    end
                end
                if (success == 1) begin
                    next_state = FRAME_SPACE;
                end else
                    next_state = FINISH;
                end
            end
            FINISH: begin
                if (success == 1) begin
                    next_state = frame_space;
                end else
                    next_state = FINISH;
                end
            end
            FRAME_SPACE: begin
                if (frame_full == 1) begin
                    next_state = IDLE;
                end else
                    next_state = FRAME_SPACE;
                end
            end
        endcase
    end

endmodule

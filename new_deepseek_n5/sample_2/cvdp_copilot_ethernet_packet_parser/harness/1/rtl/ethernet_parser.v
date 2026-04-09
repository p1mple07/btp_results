module rtl/ethernet_parser (
    input clock,
    input reset,
    input valid,
    input start_of_frame,
    input data,
    input end_of_frame,
    output acknowledge,
    output field
);

    // State control signals
    input [1] vld;
    input [1] sof;
    input [1] eof;

    // State register
    reg [1] state = 0; // IDLE

    // Internal state variables
    reg beat_cnt = 0;
    reg [15:0] field = 0;
    reg field_vld = 0;

    // State machine transitions
    always @posedge clock begin
        case (state)
            0: 
                if (vld & sof) begin
                    state = 1;
                    beat_cnt = 0;
                    field = 0;
                    field_vld = 0;
                end
            1: 
                if (beat_cnt == 1) begin
                    // Extract data from data[31:16]
                    field = data[31:16];
                    field_vld = 1;
                    state = 2;
                end
            2: 
                if (eof) begin
                    field_vld = 0;
                    state = 0;
                end
            3: 
                // FAIL_FINAL state
                field_vld = 0;
                state = 0;
        endcase
    end

    // Acknowledge signal is always high
    acknowledge = 1;

    // Field output
    field = field;
endmodule
module rtl/ethernet_parser (
    input clock,
    input rst,
    input vld,
    input sof,
    input data,
    output ack,
    output field,
    output field_vld
);

    // State machine control
    input [1] state;

    // Internal state variables
    reg [3] beat_cnt;
    reg [15:0] temp_extracted_field;
    reg field_vld;

    // State transitions
    always @(posedge clock or posedge rst) begin
        case(state)
        // IDLE state: awaiting start of frame
            2: 
                if (vld && sof) begin
                    // Initialize
                    beat_cnt = 0;
                    field_vld = 0;
                    temp_extracted_field = 0;
                    state = 1;
                end
        // EXTRACTING state: extracting 2nd beat
            1: 
                if (vld) begin
                    if (beat_cnt == 1) begin
                        // Extract 2 bytes from data[31:16]
                        temp_extracted_field = data[31:16];
                        field_vld = 1;
                        // Transition to DONE state
                        state = 2;
                    end
                end
        // DONE state: output extracted field
            0: 
                field = temp_extracted_field;
                field_vld = 1;
        // FAIL_FINAL state: handle errors
            3: 
                field_vld = 0;
                state = 2;
        endcase
    end

    // Acknowledge signal is always high
    ack = 1;

endmodule
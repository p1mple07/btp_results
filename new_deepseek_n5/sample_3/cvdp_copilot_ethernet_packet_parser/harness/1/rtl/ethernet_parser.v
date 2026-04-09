module rtl/ethernet_parser (
    input clock,
    input reset,
    input vld,
    input sof,
    input data,
    output ack,
    output field
);

    // State machine control variables
    input [3:0] state;
    output [3:0] beat_cnt;
    output [15:0] temp_extracted_field;
    output field_vld;

    // State transitions
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state = 0;
            beat_cnt = 0;
            temp_extracted_field = 0;
            field_vld = 0;
        else if (vld & sof) begin
            state = 1;
        else if (state == 1 && vld) begin
            beat_cnt = beat_cnt + 1;
            if (beat_cnt == 1) begin
                temp_extracted_field = data[31:16];
                field_vld = 1;
            end
            state = 2;
        else if (state == 2 && vld) begin
            field = temp_extracted_field;
            field_vld = 1;
            state = 3;
        else if (state == 3 && eof) begin
            field_vld = 0;
            state = 0;
        end
    end

    // Acknowledge signal is always high
    ack = 1;

    // Output field
    field = field;
endmodule
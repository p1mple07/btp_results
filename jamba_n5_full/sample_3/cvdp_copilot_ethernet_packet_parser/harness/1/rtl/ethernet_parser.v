module extract_bytes (
    input wire clk,
    input wire rst,
    input wire vld,
    input wire sof,
    input wire data[31:0],
    input wire eof,
    output wire ack,
    output reg field,
    output reg field_vld
);

// internal signals
reg [3:0] beat_cnt;
reg [4:0] temp_extracted_field;
bit [1:0] state;

initial begin
    beat_cnt <= 0;
    temp_extracted_field <= 0;
    state <= IDLE;
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        beat_cnt <= 0;
        temp_extracted_field <= 0;
        state <= IDLE;
        ack <= 1;
        field <= 0;
        field_vld <= 1'b1;
    end else begin
        case (state)
            IDLE: begin
                if (sof && vld) begin
                    state <= EXTRACTING;
                end
                // else wait
            end
            EXTRACTING: begin
                if (beat_cnt == 1) begin
                    temp_extracted_field <= {data[31:16]};
                end
                // else continue
            end
            DONE: begin
                field <= temp_extracted_field;
                field_vld <= 1'b1;
            end
            FAIL_FINAL: begin
                field_vld <= 1'b0;
                state <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    if (ack) begin
        ack = 1;
    end else begin
        ack = 1'b0;
    end
end

endmodule

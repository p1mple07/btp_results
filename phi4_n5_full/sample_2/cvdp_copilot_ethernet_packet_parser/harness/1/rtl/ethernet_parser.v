module ethernet_parser (
    input         clk,
    input         rst,
    input         vld,
    input         sof,
    input  [31:0] data,
    input         eof,
    output reg    ack,
    output reg [15:0] field,
    output reg    field_vld
);

    // State encoding
    localparam IDLE        = 2'b00,
               EXTRACTING  = 2'b01,
               DONE        = 2'b10,
               FAIL_FINAL  = 2'b11;

    reg [1:0] state;
    reg [3:0] beat_cnt;
    reg [15:0] temp_extracted_field;

    // ack is fixed as high
    always @(*) begin
        ack = 1'b1;
    end

    // State machine and register updates
    always @(posedge clk) begin
        if (rst) begin
            state            <= IDLE;
            beat_cnt         <= 4'd0;
            field            <= 16'd0;
            field_vld        <= 1'b0;
            temp_extracted_field <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (sof && vld) begin
                        state            <= EXTRACTING;
                        beat_cnt         <= 4'd0;
                        field_vld        <= 1'b0;
                        temp_extracted_field <= 16'd0;
                    end else begin
                        state <= IDLE;
                    end
                end

                EXTRACTING: begin
                    if (vld) begin
                        if (beat_cnt == 4'd1) begin
                            // Capture the 2 most significant bytes (data[31:16])
                            temp_extracted_field <= data[31:16];
                            state <= DONE;
                        end else begin
                            beat_cnt <= beat_cnt + 1;
                            state <= EXTRACTING;
                        end
                    end else begin
                        state <= EXTRACTING;
                    end
                end

                DONE: begin
                    field <= temp_extracted_field;
                    field_vld <= 1'b1;
                    if (eof) begin
                        state <= FAIL_FINAL;
                    end else begin
                        state <= DONE;
                    end
                end

                FAIL_FINAL: begin
                    field_vld <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
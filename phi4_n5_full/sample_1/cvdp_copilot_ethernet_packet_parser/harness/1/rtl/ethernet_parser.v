module ethernet_parser(
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
  localparam [1:0] IDLE       = 2'b00;
  localparam [1:0] EXTRACTING = 2'b01;
  localparam [1:0] DONE       = 2'b10;
  localparam [1:0] FAIL_FINAL = 2'b11;

  reg [1:0] state;
  reg [3:0] beat_cnt;
  reg [15:0] temp_extracted_field;

  // Synchronous state machine
  always @(posedge clk) begin
    if (rst) begin
      state            <= IDLE;
      beat_cnt         <= 4'd0;
      temp_extracted_field <= 16'd0;
      field            <= 16'd0;
      field_vld        <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          if (sof && vld) begin
            state            <= EXTRACTING;
            beat_cnt         <= 4'd0;
          end else begin
            state            <= IDLE;
          end
        end

        EXTRACTING: begin
          if (eof) begin
            state <= FAIL_FINAL;
          end else if (vld) begin
            if (beat_cnt == 4'd0) begin
              // On the first beat (starting from 0), the next beat (beat_cnt becomes 1)
              // is the 2nd beat. Capture the upper 16 bits.
              beat_cnt         <= 4'd1;
              temp_extracted_field <= data[31:16];
              state            <= DONE;
            end else begin
              beat_cnt <= beat_cnt + 1;
            end
          end else begin
            state <= EXTRACTING;
          end
        end

        DONE: begin
          if (eof) begin
            state <= FAIL_FINAL;
          end else begin
            state <= DONE;
          end
        end

        FAIL_FINAL: begin
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

  // The ack signal is always high.
  always @(*) begin
    ack = 1'b1;
  end

  // Drive the field output and its valid flag.
  // Once extraction is complete in DONE state, field holds the captured value and field_vld is asserted.
  always @(*) begin
    if (state == DONE)
      field = temp_extracted_field;
    else
      field = 16'd0;
    field_vld = (state == DONE);
  end

endmodule
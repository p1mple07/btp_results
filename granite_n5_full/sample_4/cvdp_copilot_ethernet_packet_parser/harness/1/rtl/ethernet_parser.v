module ethernet_parser(
  input wire clk, rst,
  input wire vld, sof, eof,
  output wire ack,
  input wire [31:0] data,
  output reg [15:0] field,
  output reg field_vld
);

  // Define internal signals and variables
  reg [3:0] beat_cnt;
  reg [15:0] temp_extracted_field;
  reg [1:0] state;

  // State transition table
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    EXTRACTING = 2'b01,
    DONE = 2'b10,
    FAIL_FINAL = 2'b11
  } states_t;

  // State machine logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      beat_cnt <= 0;
      state <= IDLE;
      field <= 16'h0;
      field_vld <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (vld && sof) begin
            beat_cnt <= 0;
            state <= EXTRACTING;
          end
        end
        EXTRACTING: begin
          if (beat_cnt == 1) begin
            temp_extracted_field <= data[31:16];
            state <= DONE;
          end else begin
            beat_cnt <= beat_cnt + 1;
          end
        end
        DONE: begin
          field <= temp_extracted_field;
          field_vld <= 1;
          state <= FAIL_FINAL;
        end
        FAIL_FINAL: begin
          field_vld <= 0;
          state <= IDLE;
        end
      endcase
    end
  end

  // Protocol compliance assertions
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ack <= 1'b1;
    end else begin
      if (eof) begin
        ack <= 1'b0;
        state <= IDLE;
      end else begin
        ack <= 1'b1;
      end
    end
  end

endmodule
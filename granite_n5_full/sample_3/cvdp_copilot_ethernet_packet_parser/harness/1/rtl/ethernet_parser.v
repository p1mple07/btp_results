module ethernet_parser (
  input wire clk,
  input wire rst,
  input wire vld,
  input wire sof,
  input wire [31:0] data,
  input wire eof,
  output reg [15:0] field,
  output reg field_vld,
  output reg ack
);

  reg [3:0] beat_cnt;
  reg [15:0] temp_extracted_field;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      beat_cnt <= 0;
      temp_extracted_field <= 0;
      field <= 0;
      field_vld <= 0;
      ack <= 0;
    end else begin
      if (vld && sof) begin
        beat_cnt <= 0;
        temp_extracted_field <= 0;
        field <= 0;
        field_vld <= 0;
        ack <= 1;
      end else if (eof) begin
        field_vld <= 0;
        ack <= 0;
      end else begin
        if (beat_cnt == 1) begin
          temp_extracted_field <= data[31:16];
          field <= temp_extracted_field;
          field_vld <= 1;
          ack <= 0;
        end else begin
          beat_cnt <= beat_cnt + 1;
          ack <= 0;
        end
      end
    end
  end

endmodule
module ethernet_parser (
  input clk, rst,
  input vld, sof, eof,
  input [31:0] data,
  output reg [15:0] field,
  output reg field_vld
);

reg [3:0] beat_cnt;
reg [15:0] temp_extracted_field;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    beat_cnt <= 0;
    temp_extracted_field <= 0;
    field <= 0;
    field_vld <= 0;
  end else begin
    if (vld && sof) begin
      beat_cnt <= 0;
      temp_extracted_field <= 0;
      field_vld <= 0;
    end else if (beat_cnt == 1 && vld) begin
      temp_extracted_field <= data[31:16];
      field <= temp_extracted_field;
      field_vld <= 1;
    end else if (eof) begin
      field_vld <= 0;
    end
  end
end

endmodule
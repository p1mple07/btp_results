module ethernet_parser(
  input wire clk,
  input wire rst,
  
  input wire vld,
  input wire sof,
  input wire [31:0] data,
  input wire eof,
  
  output reg ack,
  output reg [15:0] field,
  output reg field_vld
);

  reg [3:0] beat_cnt;
  reg [15:0] temp_extracted_field;

  // State machine
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      beat_cnt <= 0;
      temp_extracted_field <= 0;
      field <= 0;
      field_vld <= 0;
    end else begin
      case (state)
        0: begin
          if (vld && sof) begin
            beat_cnt <= 0;
            temp_extracted_field <= 0;
            field_vld <= 0;
            state <= 1;
          end
        end
        1: begin
          if (beat_cnt == 1) begin
            temp_extracted_field <= data[31:16];
            state <= 2;
          end
        end
        2: begin
          if (eof) begin
            field <= temp_extracted_field;
            field_vld <= 1;
            state <= 3;
          end
        end
        3: begin
          field_vld <= 0;
          state <= 0;
        end
      endcase
    end
  end

  // Protocol compliance
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= 0;
    end else begin
      case (state)
        1: begin
          if (beat_cnt == 1) begin
            state <= 2;
          end
        end
        2: begin
          if (eof) begin
            state <= 3;
          end
        end
        3: begin
          state <= 0;
        end
      endcase
    end
  end

  // Outputs
  assign ack = 1'b1;
  assign field = temp_extracted_field;

endmodule
module ethernet_parser(
  input clk, rst, vld, sof, data, eof, ack, field, field_vld
);

  // States
  parameter IDLE = 2'b00;
  parameter EXTRACTING = 2'b01;
  parameter DONE = 2'b10;
  parameter FAIL_FINAL = 2'b11;
  
  reg [3:0] beat_cnt;
  reg [15:0] temp_extracted_field;
  reg [1:0] state;
  wire [1:0] next_state;
  
  assign ack = 1'b1;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      beat_cnt <= 0;
      state <= IDLE;
      field <= 16'h0000;
      field_vld <= 1'b0;
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
          end
          beat_cnt <= beat_cnt + 1;
        end
        DONE: begin
          field <= temp_extracted_field;
          field_vld <= 1'b1;
          state <= IDLE;
        end
        FAIL_FINAL: begin
          field_vld <= 1'b0;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

  assign next_state = 
    (state == IDLE && vld && sof)? EXTRACTING :
    (state == EXTRACTING && beat_cnt == 1)? DONE :
    (state == DONE && eof)? FAIL_FINAL :
    state;

  always @(next_state) begin
    case (next_state)
      IDLE: begin
        // Initialization actions here
      end
      EXTRACTING: begin
        // Actions during extraction here
      end
      DONE: begin
        // Actions upon successful extraction here
      end
      FAIL_FINAL: begin
        // Actions upon failed extraction here
      end
      default: begin
        // Default action here
      end
    endcase
  end

endmodule
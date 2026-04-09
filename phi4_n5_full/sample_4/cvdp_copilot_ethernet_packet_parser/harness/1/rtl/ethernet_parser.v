module ethernet_parser (
  input  wire         clk,
  input  wire         rst,
  input  wire         vld,
  input  wire         sof,
  input  wire         eof,
  input  wire [31:0]  data,
  output wire         ack,
  output reg  [15:0]  field,
  output reg          field_vld
);

  // State Encoding
  localparam [1:0] IDLE       = 2'b00,
                   EXTRACTING = 2'b01,
                   DONE       = 2'b10,
                   FAIL_FINAL = 2'b11;

  // Internal registers
  reg [1:0] state;         // State machine state
  reg [3:0] beat_cnt;      // Beat counter (4 bits for up to 16 beats)
  reg [15:0] temp_extracted_field; // Temporary storage for extracted bytes

  // Acknowledge is always high (1)
  assign ack = 1'b1;

  // State Machine and Beat Counter Logic
  always @(posedge clk) begin
    if (rst) begin
      // Reset: go to IDLE and clear registers
      state              <= IDLE;
      beat_cnt           <= 4'd0;
      temp_extracted_field <= 16'd0;
      field              <= 16'd0;
      field_vld          <= 1'b0;
    end
    else begin
      case (state)
        IDLE: begin
          // Wait for start-of-frame to begin extraction
          if (sof && vld) begin
            state              <= EXTRACTING;
            beat_cnt           <= 4'd0; // Reset beat counter at start of burst
          end
        end

        EXTRACTING: begin
          if (vld) begin
            // Increment beat counter for each valid beat
            beat_cnt <= beat_cnt + 1;

            // On the 2nd beat (beat_cnt == 1), capture data[31:16]
            if (beat_cnt == 4'd1) begin
              temp_extracted_field <= data[31:16];
              state <= DONE;
            end
          end
        end

        DONE: begin
          // Output the extracted field and assert field_vld
          field              <= temp_extracted_field;
          field_vld          <= 1'b1;
          // Remain in DONE until end-of-frame is detected
          if (eof) begin
            state <= FAIL_FINAL;
          end
        end

        FAIL_FINAL: begin
          // Clear field_vld and return to IDLE for next burst
          field_vld <= 1'b0;
          state     <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
module ethernet_parser (
    input  wire         clk,
    input  wire         rst,
    input  wire         vld,
    input  wire         sof,
    input  wire [31:0]  data,
    input  wire         eof,
    output wire         ack,
    output wire [15:0]  field,
    output wire         field_vld
);

  // State encoding: 2-bit state machine
  localparam IDLE          = 2'b00;
  localparam EXTRACTING    = 2'b01;
  localparam DONE          = 2'b10;
  localparam FAIL_FINAL    = 2'b11;

  // Internal registers
  reg [1:0] state;              // Current state of the state machine
  reg [3:0] beat_cnt;           // Beat counter (4-bit)
  reg [15:0] temp_extracted_field; // Temporary storage for the extracted 16-bit field

  // Output assignments
  // ack is always high to indicate that data is always accepted.
  assign ack = 1'b1;
  // In IDLE and EXTRACTING (if extraction not yet performed), field and field_vld are deasserted.
  // In DONE state, field is driven by the captured value and field_vld is asserted.
  assign field    = (state == DONE) ? temp_extracted_field : 16'b0;
  assign field_vld = (state == DONE) ? 1'b1 : 1'b0;

  // Sequential logic: Synchronous process for state machine and registers
  always @(posedge clk) begin
    if (rst) begin
      // Reset: go to IDLE and clear all registers.
      state                   <= IDLE;
      beat_cnt                <= 4'd0;
      temp_extracted_field    <= 16'd0;
    end
    else if (eof) begin
      // End-of-frame: clear field_vld and reset to IDLE.
      state                   <= IDLE;
      beat_cnt                <= 4'd0;
      temp_extracted_field    <= 16'd0;
    end
    else begin
      case (state)
        IDLE: begin
          // Wait for the start-of-frame signal to initiate extraction.
          if (sof && vld) begin
            state             <= EXTRACTING;
            beat_cnt          <= 4'd0;
            temp_extracted_field <= 16'd0;
          end
          else begin
            state <= IDLE;
          end
        end

        EXTRACTING: begin
          // On each valid beat, increment the beat counter.
          if (vld) begin
            beat_cnt <= beat_cnt + 1;
            // Check if we have reached the 2nd beat (beat_cnt == 1).
            if (beat_cnt == 4'd1) begin
              // Capture the 2 most significant bytes from data.
              temp_extracted_field <= data[31:16];
              state <= DONE;
            end
            else begin
              state <= EXTRACTING;
            end
          end
          else begin
            state <= EXTRACTING;
          end
        end

        DONE: begin
          // In DONE state, output the captured field.
          // Remain in DONE until eof is asserted.
          state <= DONE;
        end

        FAIL_FINAL: begin
          // On eof, clear field_vld and return to IDLE.
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
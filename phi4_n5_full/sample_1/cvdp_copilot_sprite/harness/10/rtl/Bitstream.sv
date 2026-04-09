module Bitstream(
    input  logic clk,
    input  logic rst_n,
    input  logic enb,
    input  logic rempty_in,
    input  logic rinc_in,
    input  logic [7:0] i_byte,
    output logic o_bit,
    output logic rempty_out,
    output logic rinc_out
);

  // Use 3‐bit state encoding to match the parameters
  localparam [2:0] IDLE   = 3'b000;
  localparam [2:0] WAIT_R = 3'b001;
  localparam [2:0] READY  = 3'b010;

  // State registers
  logic [2:0] curr_state, next_state;

  // Internal registers: load the full byte and use a 3‐bit pointer (0 to 7)
  logic [7:0] byte_buf;
  logic [2:0] bp;  // bp goes from 0 to 7

  // Signal to indicate when a new byte should be loaded
  logic new_byte;

  // Next state and output logic (all assignments are made to avoid latch inference)
  always_comb begin
    next_state = curr_state;   // default: hold state
    rinc_out   = 1'b0;
    rempty_out = 1'b1;         // buffer is empty by default

    case (curr_state)
      IDLE: begin
        // Wait for enable; then load a new byte.
        if (enb)
          next_state = WAIT_R;
      end

      WAIT_R: begin
        // Wait until the receiver is not empty (i.e. !rempty_in)
        if (!rempty_in) begin
          next_state = READY;
          rinc_out   = 1'b1;  // Assert rinc_out to signal that a byte is being loaded
        end
      end

      READY: begin
        // Output bits from the byte buffer.
        // When all 8 bits have been output (bp == 7), return to IDLE.
        if (bp == 3'b111)
          next_state = IDLE;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // State register update
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      curr_state <= IDLE;
    else
      curr_state <= next_state;
  end

  // Generate a signal to load a new byte when in WAIT_R and receiver is ready.
  always_comb begin
    new_byte = 1'b0;
    case (curr_state)
      WAIT_R: begin
        if (!rempty_in)
          new_byte = 1'b1;
      end
      default: new_byte = 1'b0;
    endcase
  end

  // Sequential logic: load a new byte and update the bit pointer.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      byte_buf <= 8'b0;
      bp       <= 3'b0;
    end
    else begin
      // When transitioning from WAIT_R to READY, load the new byte and reset bp.
      if (curr_state == WAIT_R && new_byte) begin
        byte_buf <= i_byte;  // Load the full byte (no truncation)
        bp       <= 3'b0;
      end
      // In READY state, if the downstream has accepted the bit (rinc_in asserted),
      // increment the bit pointer.
      else if (curr_state == READY && rinc_in) begin
        bp <= bp + 1;
      end
    end
  end

  // Output the current bit from the byte buffer.
  // (Assuming LSB-first output: bp==0 gives byte_buf[0], bp==7 gives byte_buf[7].)
  assign o_bit = byte_buf[bp];

endmodule
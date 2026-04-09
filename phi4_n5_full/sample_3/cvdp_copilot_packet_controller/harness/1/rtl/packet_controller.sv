module packet_controller (
  input  logic         clk,
  input  logic         rst,
  input  logic         rx_valid_i,
  input  logic [7:0]   rx_data_8_i,
  input  logic         tx_done_tick_i,
  output logic         tx_start_o,
  output logic [7:0]   tx_data_8_o
);

  // State encoding
  localparam S_IDLE            = 3'd0;
  localparam S_GOT_8_BYTES     = 3'd1;
  localparam S_RECV_CHECKSUM   = 3'd2;
  localparam S_BUILD_RESPONSE  = 3'd3;
  localparam S_SEND_FIRST_BYTE = 3'd4;
  localparam S_RESPONSE_READY  = 3'd5;

  // Registers for FSM and data handling
  logic [2:0] state, next_state;
  logic [2:0] rx_count, resp_count;
  logic [7:0] rx_checksum;
  logic [15:0] num1, num2, result;
  logic [7:0] opcode, resp_checksum;
  logic [7:0] rx_buffer [0:7];
  logic [7:0] resp_buffer [0:4];

  //-------------------------------------------------------------------------
  // Next state logic (combinational)
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = state; // Default: hold state
    case (state)
      S_IDLE: begin
        if (rx_valid_i) begin
          // Sample incoming byte into buffer and count
          if (rx_count < 7)
            next_state = S_IDLE;
          else
            next_state = S_GOT_8_BYTES;
        end
      end

      S_GOT_8_BYTES: begin
        // Check header: first 16 bits must equal 16'hBACD.
        if ({rx_buffer[1], rx_buffer[0]} != 16'hBACD)
          next_state = S_IDLE;
        else
          next_state = S_RECV_CHECKSUM;
      end

      S_RECV_CHECKSUM: begin
        // Validate checksum: the sum of all 8 bytes mod 256 must equal 0.
        if (rx_checksum == 8'h00)
          next_state = S_BUILD_RESPONSE;
        else
          next_state = S_IDLE;
      end

      S_BUILD_RESPONSE: begin
        next_state = S_SEND_FIRST_BYTE;
      end

      S_SEND_FIRST_BYTE: begin
        if (tx_done_tick_i)
          next_state = S_RESPONSE_READY;
        else
          next_state = S_SEND_FIRST_BYTE;
      end

      S_RESPONSE_READY: begin
        if (tx_done_tick_i) begin
          if (resp_count == 4)
            next_state = S_IDLE;
          else
            next_state = S_RESPONSE_READY;
        end
        else
          next_state = S_RESPONSE_READY;
      end

      default: next_state = S_IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Sequential logic: state register and data handling
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state         <= S_IDLE;
      rx_count      <= 3'd0;
      resp_count    <= 3'd0;
      rx_checksum   <= 8'd0;
    end
    else begin
      state <= next_state;
      case (state)
        S_IDLE: begin
          if (rx_valid_i) begin
            rx_buffer[rx_count] <= rx_data_8_i;
            if (rx_count < 7)
              rx_count <= rx_count + 1;
          end
        end

        S_GOT_8_BYTES: begin
          // Compute checksum from the 8 received bytes.
          rx_checksum <= rx_buffer[0] + rx_buffer[1] + rx_buffer[2] + rx_buffer[3] +
                         rx_buffer[4] + rx_buffer[5] + rx_buffer[6] + rx_buffer[7];
        end

        S_RECV_CHECKSUM: begin
          // If checksum is valid, extract payload:
          // Payload: num1 (bytes 2-3), num2 (bytes 4-5), opcode (byte 6).
          if (rx_checksum == 8'h00) begin
            num1 <= {rx_buffer[3], rx_buffer[2]};
            num2 <= {rx_buffer[5], rx_buffer[4]};
            opcode <= rx_buffer[6];
          end
          // Otherwise, packet is invalid and FSM will reset in next state.
        end

        S_BUILD_RESPONSE: begin
          // Compute result based on opcode:
          // opcode = 8'h00: addition; opcode = 8'h01: subtraction; else result = 0.
          if (opcode == 8'h00)
            result <= num1 + num2;
          else if (opcode == 8'h01)
            result <= num1 - num2;
          else
            result <= 16'h0000;

          // Compute response checksum.
          // Outgoing response packet format:
          // Header: fixed 16'hABCD, Payload: result (16-bit), Checksum: such that
          // (header + result) mod 256 == 0.
          // Let header (ABCD) have high byte = 8'hAB, low byte = 8'hCD.
          // Compute sum_temp = 8'hAB + 8'hCD + result[15:8] + result[7:0].
          // Then resp_checksum = (256 - sum_temp) mod 256 = ~sum_temp + 1.
          resp_checksum <= ~((result[15:8] + result[7:0] + 8'hAB + 8'hCD)) + 1;

          // Load response buffer (5 bytes total):
          // Byte0: header high byte, Byte1: header low byte,
          // Byte2: result high byte, Byte3: result low byte,
          // Byte4: response checksum.
          resp_buffer[0] <= 8'hAB;
          resp_buffer[1] <= 8'hCD;
          resp_buffer[2] <= result[15:8];
          resp_buffer[3] <= result[7:0];
          resp_buffer[4] <= resp_checksum;

          // Reset response byte counter.
          resp_count <= 3'd0;
        end

        S_SEND_FIRST_BYTE: begin
          // Waiting for tx_done_tick_i to advance transmission.
          // Nothing to update here.
        end

        S_RESPONSE_READY: begin
          if (tx_done_tick_i)
            resp_count <= resp_count + 1;
        end

        default: ;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Output logic: drive tx_start_o and tx_data_8_o based on state
  //-------------------------------------------------------------------------
  always_comb begin
    tx_start_o   = 1'b0;
    tx_data_8_o  = 8'd0;
    case (state)
      S_SEND_FIRST_BYTE: begin
        tx_start_o   = 1'b1;
        tx_data_8_o  = resp_buffer[0];
      end

      S_RESPONSE_READY: begin
        tx_start_o   = 1'b1;
        tx_data_8_o  = resp_buffer[resp_count];
      end

      default: begin
        tx_start_o   = 1'b0;
        tx_data_8_o  = 8'd0;
      end
    endcase
  end

endmodule
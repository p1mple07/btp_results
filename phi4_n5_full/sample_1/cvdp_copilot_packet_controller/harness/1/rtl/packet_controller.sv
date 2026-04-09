module packet_controller (
    input  logic         clk,
    input  logic         rst,
    input  logic         rx_valid_i,
    input  logic [7:0]   rx_data_8_i,
    input  logic         tx_done_tick_i,
    output logic         tx_start_o,
    output logic [7:0]   tx_data_8_o
);

  //-------------------------------------------------------------------------
  // State Encoding
  //-------------------------------------------------------------------------
  localparam logic [2:0] S_IDLE           = 3'd0;
  localparam logic [2:0] S_GOT_8_BYTES    = 3'd1;
  localparam logic [2:0] S_RECV_CHECKSUM  = 3'd2;
  localparam logic [2:0] S_BUILD_RESPONSE = 3'd3;
  localparam logic [2:0] S_SEND_FIRST_BYTE= 3'd4;
  localparam logic [2:0] S_RESPONSE_READY = 3'd5;

  //-------------------------------------------------------------------------
  // Registers & Wires for FSM and Data Buffering
  //-------------------------------------------------------------------------
  reg [2:0] state, next_state;

  // Buffer to hold 8 received bytes
  reg [7:0] rx_buffer [0:7];
  reg [2:0] rx_count; // Counts 0 to 7

  // Registers for response packet (5 bytes total)
  reg [7:0] tx_buffer [0:4];

  // Register to hold computed 16-bit result for response payload
  reg [15:0] result_reg;

  // Register to hold computed response checksum (byte 4)
  reg [7:0] resp_checksum_reg;

  // Counter for transmitting response bytes in S_RESPONSE_READY
  reg [1:0] tx_byte_cnt;  // counts 0 to 3 (after S_SEND_FIRST_BYTE)

  //-------------------------------------------------------------------------
  // Internal combinational signals for incoming packet checksum and header check
  //-------------------------------------------------------------------------
  // Sum of the first 7 bytes (bytes 0 to 6) of the received packet
  wire [11:0] sum_rx = rx_buffer[0] + rx_buffer[1] + rx_buffer[2] +
                         rx_buffer[3] + rx_buffer[4] + rx_buffer[5] +
                         rx_buffer[6];
  // Expected checksum = (256 - (sum_rx mod 256)) mod 256
  wire [7:0] expected_rx_checksum = ((8'd256 - (sum_rx % 8'd256)) % 8'd256);
  // Check if received checksum (byte 7) matches expected value
  wire valid_rx = (rx_buffer[7] == expected_rx_checksum);

  // Header check: first two bytes must be 0xBA and 0xCD respectively
  wire header_valid = (rx_buffer[0] == 8'hBA) && (rx_buffer[1] == 8'hCD);

  //-------------------------------------------------------------------------
  // Next State Logic (combinational)
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = state;
    // Default output assignments
    tx_start_o = 1'b0;
    tx_data_8_o = 8'd0;

    case (state)
      S_IDLE: begin
        if (rx_valid_i)
          next_state = S_GOT_8_BYTES;
      end
      S_GOT_8_BYTES: begin
        next_state = S_RECV_CHECKSUM;
      end
      S_RECV_CHECKSUM: begin
        if (header_valid && valid_rx)
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
      end
      S_RESPONSE_READY: begin
        if (tx_done_tick_i)
          next_state = S_IDLE;
      end
      default: next_state = S_IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Sequential Logic: State Register and Data Handling
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state         <= S_IDLE;
      rx_count      <= 3'd0;
      tx_byte_cnt   <= 2'd0;
      // Clear rx_buffer
      integer i;
      for (i = 0; i < 8; i = i + 1)
        rx_buffer[i] <= 8'd0;
    end
    else begin
      state <= next_state;
      case (state)
        S_IDLE: begin
          if (rx_valid_i) begin
            rx_buffer[rx_count] <= rx_data_8_i;
            rx_count <= rx_count + 1;
            if (rx_count == 7)
              rx_count <= 3'd0; // Reset counter after 8 bytes received
          end
        end
        S_GOT_8_BYTES: begin
          // Nothing to do; simply transition to checksum validation
        end
        S_RECV_CHECKSUM: begin
          // Checksum and header already evaluated in combinational logic
        end
        S_BUILD_RESPONSE: begin
          // Prepare the outgoing response packet:
          // Fixed header: 0xAB, 0xCD
          tx_buffer[0] <= 8'hAB;
          tx_buffer[1] <= 8'hCD;
          // Extract num1 and num2 from received packet:
          // num1 is bytes 2 and 3; num2 is bytes 4 and 5.
          case (rx_buffer[6])  // opcode is byte 6
            8'h00: result_reg <= {rx_buffer[2], rx_buffer[3]} + {rx_buffer[4], rx_buffer[5]};
            8'h01: result_reg <= {rx_buffer[2], rx_buffer[3]} - {rx_buffer[4], rx_buffer[5]};
            default: result_reg <= 16'd0;
          endcase
        end
        S_SEND_FIRST_BYTE: begin
          // Begin transmission of the first byte of the response.
          tx_start_o    <= 1'b1;
          tx_data_8_o   <= tx_buffer[0];
          tx_byte_cnt   <= 2'd1;  // Next byte index to send is 1
        end
        S_RESPONSE_READY: begin
          if (tx_done_tick_i) begin
            tx_data_8_o <= tx_buffer[tx_byte_cnt];
            tx_byte_cnt <= tx_byte_cnt + 1;
          end
        end
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Combinational Logic: Compute Response Checksum based on result_reg
  //-------------------------------------------------------------------------
  // The response packet structure is:
  // Byte0: Header high = 0xAB
  // Byte1: Header low  = 0xCD
  // Byte2: Result high (MSB of 16-bit result)
  // Byte3: Result low  (LSB of 16-bit result)
  // Byte4: Checksum computed so that (Byte0+Byte1+Byte2+Byte3+Checksum) mod 256 = 0
  always_comb begin
    // Compute sum of first 4 bytes of the response:
    // Note: result_reg is available from S_BUILD_RESPONSE.
    // Use the fixed header and the computed result.
    resp_checksum_reg = ((8'hAB + 8'hCD + result_reg[15:8] + result_reg[7:0]) % 8'd256);
    // To satisfy (sum + checksum) mod 256 = 0, the checksum must be:
    resp_checksum_reg = (8'd256 - resp_checksum_reg) % 8'd256;
  end

  //-------------------------------------------------------------------------
  // Sequential Logic: Update tx_buffer with computed checksum in S_BUILD_RESPONSE
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Clear tx_buffer on reset
      integer j;
      for (j = 0; j < 5; j = j + 1)
        tx_buffer[j] <= 8'd0;
    end
    else if (state == S_BUILD_RESPONSE) begin
      // Set payload bytes based on computed result_reg
      tx_buffer[2] <= result_reg[15:8];
      tx_buffer[3] <= result_reg[7:0];
      // Set computed checksum as the 5th byte
      tx_buffer[4] <= resp_checksum_reg;
    end
  end

endmodule
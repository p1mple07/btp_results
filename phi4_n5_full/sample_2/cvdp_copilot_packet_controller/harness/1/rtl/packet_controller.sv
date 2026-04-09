// File: rtl/packet_controller.sv
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
  // FSM State Encoding
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    S_IDLE            = 3'd0,
    S_GOT_8_BYTES     = 3'd1,
    S_RECV_CHECKSUM   = 3'd2,
    S_BUILD_RESPONSE  = 3'd3,
    S_SEND_FIRST_BYTE = 3'd4,
    S_RESPONSE_READY  = 3'd5
  } state_t;

  state_t state, next_state;

  //-------------------------------------------------------------------------
  // Registers for Incoming Packet Buffer & Counters
  //-------------------------------------------------------------------------
  // Buffer to store 8 received bytes.
  logic [7:0] rx_buffer [0:7];
  logic [2:0] rx_cnt;  // 3 bits are enough for 0..7

  // Payload registers extracted from the packet.
  logic [15:0] num1, num2;
  logic [7:0]  opcode;

  // Transmission counter (0 to 4 bytes for the response).
  logic [2:0] tx_cnt;

  //-------------------------------------------------------------------------
  // Response Packet and Computation Registers
  //-------------------------------------------------------------------------
  // Response packet: 5 bytes.
  // Byte0: Header high (fixed 0xAB)
  // Byte1: Header low (fixed 0xCD)
  // Byte2: Result high byte
  // Byte3: Result low byte
  // Byte4: Checksum byte
  logic [7:0] resp_packet [0:4];
  logic [15:0] result;
  // A register to capture the computed checksum.
  logic [7:0] computed_checksum_reg;

  //-------------------------------------------------------------------------
  // Combinational Logic: Incoming Packet Checksum Calculation
  //-------------------------------------------------------------------------
  // Sum all 8 received bytes (mod 256).
  logic [7:0] rx_sum;
  always_comb begin
    integer i;
    rx_sum = 8'd0;
    for (i = 0; i < 8; i = i + 1) begin
      rx_sum = rx_sum + rx_buffer[i];
    end
  end

  //-------------------------------------------------------------------------
  // Combinational Logic: Response Checksum Computation
  //-------------------------------------------------------------------------
  // The response packet must satisfy:
  //   (0xAB + 0xCD + result_hi + result_lo + checksum) mod 256 = 0
  // Therefore, checksum = (256 - (0xAB + 0xCD + result
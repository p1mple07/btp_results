// rtl/packet_controller.sv
module packet_controller(
    input  logic         clk,
    input  logic         rst,
    input  logic         rx_valid_i,
    input  logic [7:0]   rx_data_8_i,
    input  logic         tx_done_tick_i,
    output logic         tx_start_o,
    output logic [7:0]   tx_data_8_o
);

  // FSM state encoding
  typedef enum logic [2:0] {
    S_IDLE            = 3'd0,
    S_GOT_8_BYTES     = 3'd1,
    S_RECV_CHECKSUM   = 3'd2,
    S_BUILD_RESPONSE  = 3'd3,
    S_SEND_FIRST_BYTE = 3'd4,
    S_RESPONSE_READY  = 3'd5
  } state_t;

  state_t state, next_state;

  // Registers for incoming packet accumulation (8 bytes total)
  reg [7:0] rx_buffer [0:7];
  reg [2:0] rx_count;  // counts 0 to 7

  // Registers for outgoing response (5 bytes total)
  reg [7:0] tx_buffer [0:4];
  reg [2:0] tx_count;  // counts transmitted bytes (0 to 4)

  // Computed result register (8-bit result from arithmetic)
  reg [7:0] result_reg;

  // Register for computed outgoing checksum
  reg [7:0] tx_checksum_reg;

  // Sequential logic: state register, rx accumulation, tx loading, etc.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state         <= S_IDLE;
      rx_count      <= 3'd0;
      tx_count      <= 3'd0;
      tx_start_o    <= 1'b0;
      tx_data_8_o   <= 8'd0;
      result_reg    <= 8'd0;
      tx_checksum_reg <= 8'd0;
      integer i;
      for (i = 0; i < 8; i = i + 1)
        rx_buffer[i] <= 8'd0;
      for (i = 0; i < 5; i = i + 1)
        tx_buffer[i] <= 8'd0;
    end
    else begin
      state <= next_state;

      // In S_IDLE: accumulate incoming bytes when rx_valid_i is high.
      if (state == S_IDLE) begin
        if (rx_valid_i) begin
          if (rx_count < 3'd7) begin
            rx_buffer[rx_count] <= rx_data_8_i;
            rx_count <= rx_count + 1;
          end
          else begin
            rx_buffer[rx_count] <= rx_data_8_i;
            // rx_count remains at 7; next state will be updated combinationaly.
          end
        end
      end

      // In S_BUILD_RESPONSE: load the outgoing packet.
      if (state == S_BUILD_RESPONSE) begin
        tx_buffer[0] <= 8'hAB;         // Header MSB fixed
        tx_buffer[1] <= 8'hCD;         // Header LSB fixed
        tx_buffer[2] <= result_reg;    // Computed result (8-bit)
        tx_buffer[3] <= 8'h00;         // Reserved byte (for alignment/padding)
        // Compute checksum: sum = AB + CD + result_reg + 00.
        // Then checksum = (256 - (sum mod 256)) mod 256.
        tx_checksum_reg <= (256 - (((8'hAB + 8'hCD + result_reg + 8'h00) % 256))) % 256;
        tx_buffer[4] <= tx_checksum_reg;
      end

      // In transmission states, increment tx_count on tx_done_tick_i.
      if ((state == S_SEND_FIRST_BYTE) || (state == S_RESPONSE_READY)) begin
        if (tx_done_tick_i)
          tx_count <= tx_count + 1;
      end

      // Drive tx_data output during transmission.
      if ((state == S_SEND_FIRST_BYTE) || (state == S_RESPONSE_READY))
        tx_data_8_o <= tx_buffer[tx_count];
      else
        tx_data_8_o <= 8'd0;

      // Assert tx_start_o during transmission.
      if ((state == S_SEND_FIRST_BYTE) || (state == S_RESPONSE_READY))
        tx_start_o <= 1'b1;
      else
        tx_start_o <= 1'b0;
    end
  end

  // Combinational logic for next state and result computation.
  always_comb begin
    next_state = state;  // Default hold state

    unique case (state)
      S_IDLE: begin
        if (rx_valid_i) begin
          if (rx_count < 3'd7)
            next_state = S_IDLE;
          else
            next_state = S_GOT_8_BYTES;
        end
      end
      S_GOT_8_BYTES: begin
        // Validate header: must be 16'hBACD (BA, CD)
        if ((rx_buffer[0] !== 8'hBA
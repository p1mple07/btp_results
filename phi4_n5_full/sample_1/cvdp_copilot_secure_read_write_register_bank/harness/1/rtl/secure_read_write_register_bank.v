module secure_read_write_register_bank #(
  parameter int p_address_width = 8,
  parameter int p_data_width    = 8,
  parameter logic [p_data_width-1:0] p_unlock_code_0 = 8'hAB,
  parameter logic [p_data_width-1:0] p_unlock_code_1 = 8'hCD
)(
  input  logic                   i_capture_pulse,
  input  logic                   i_rst_n,
  input  logic [p_address_width-1:0] i_addr,
  input  logic [p_data_width-1:0]    i_data_in,
  input  logic                   i_read_write_enable, // 0: write, 1: read
  output logic [p_data_width-1:0]    o_data_out
);

  // State encoding:
  //  2'b00 : LOCKED
  //  2'b01 : WAIT_FOR_UNLOCK1 (unlock code 0 has been written correctly)
  //  2'b10 : UNLOCKED (both unlock codes have been written in immediate succession)
  localparam LOCKED          = 2'd0;
  localparam WAIT_FOR_UNLOCK1 = 2'd1;
  localparam UNLOCKED        = 2'd2;

  reg [1:0] state_r;

  // Memory array for register bank.
  // Size is 2^(p_address_width) registers. Assumes p_address_width is a constant.
  reg [p_data_width-1:0] reg_bank [0:((1 << p_address_width) - 1)];

  // Combined state machine and register bank operations.
  // Operations are triggered on the rising edge of i_capture_pulse.
  // i_rst_n is asynchronous active low.
  always_ff @(posedge i_capture_pulse or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_r <= LOCKED;
    end
    else begin
      if (i_read_write_enable == 0) begin  // Write operation
        if (state_r == LOCKED) begin
          // Only address 0 is allowed in LOCKED state for initiating unlock.
          if (i_addr == 0) begin
            if (i_data_in == p_unlock_code_0)
              state_r <= WAIT_FOR_UNLOCK1;
            else
              state_r <= LOCKED;
          end
          // Writing to address 1 while locked is invalid.
          else if (i_addr == 1) begin
            state_r <= LOCKED;
          end
          // For any other address, no write is allowed.
        end
        else if (state_r == WAIT_FOR_UNLOCK1) begin
          // In WAIT_FOR_UNLOCK1 state, only address 1 is allowed.
          if (i_addr == 1) begin
            if (i_data_in == p_unlock_code_1)
              state_r <= UNLOCKED;
            else
              state_r <= LOCKED;
          end
          else begin
            // Any write to an address other than 1 resets the unlock sequence.
            state_r <= LOCKED;
          end
        end
        else if (state_r == UNLOCKED) begin
          // When unlocked, allow write to any address.
          // Note: Addresses 0 and 1 remain write-only (read always returns 0).
          reg_bank[i_addr] <= i_data_in;
        end
        // For write operations, o_data_out is forced to 0.
        o_data_out <= '0;
      end
      else begin  // Read operation
        // Reading is allowed only when unlocked and for addresses other than 0 and 1.
        if (state_r == UNLOCKED && (i_addr != 0) && (i_addr != 1))
          o_data_out <= reg_bank[i_addr];
        else
          o_data_out <= '0;
      end
    end
  end

endmodule
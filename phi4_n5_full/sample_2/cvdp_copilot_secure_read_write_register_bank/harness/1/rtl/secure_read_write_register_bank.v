module secure_read_write_register_bank #(
  parameter p_address_width = 8,
  parameter p_data_width    = 8,
  parameter p_unlock_code_0 = 8'hAB,
  parameter p_unlock_code_1 = 8'hCD
)(
  input  wire [p_address_width-1:0] i_addr,
  input  wire [p_data_width-1:0]    i_data_in,
  input  wire                       i_read_write_enable, // 0 = write, 1 = read
  input  wire                       i_capture_pulse,
  input  wire                       i_rst_n,
  output reg  [p_data_width-1:0]    o_data_out
);

  //-------------------------------------------------------------------------
  // Register bank: an array of 2^(p_address_width) registers, each p_data_width bits.
  //-------------------------------------------------------------------------
  reg [p_data_width-1:0] reg_bank [0:((1<<p_address_width)-1)];

  //-------------------------------------------------------------------------
  // Unlock state machine signals
  //-------------------------------------------------------------------------
  // locked: 1 means the register bank is locked (unlock sequence not complete)
  //          0 means unlocked.
  reg locked;
  // first_unlock: set when a correct unlock code is written to address 0.
  reg first_unlock;

  //-------------------------------------------------------------------------
  // Synchronous process: Triggered on the rising edge of i_capture_pulse
  // or on asynchronous active-low reset (i_rst_n).
  //-------------------------------------------------------------------------
  always @(posedge i_capture_pulse or negedge i_rst_n) begin
    if (!i_rst_n) begin
      locked      <= 1'b1;
      first_unlock<= 1'b0;
      // Optionally, one could clear the register bank here.
      // integer j;
      // for (j = 0; j < (1<<p_address_width); j = j + 1)
      //   reg_bank[j] <= {p_data_width{1'b0}};
    end
    else begin
      // Determine operation type:
      // i_read_write_enable = 0 --> Write operation
      // i_read_write_enable = 1 --> Read operation
      if (!i_read_write_enable) begin  // Write operation
        if (locked) begin
          // When locked, only addresses 0 and 1 are allowed.
          if (i_addr == p_address_width'd0) begin
            // If not already waiting for the second unlock code...
            if (first_unlock == 1'b0) begin
              if (i_data_in == p_unlock_code_0) begin
                first_unlock <= 1'b1;  // Record that unlock code 0 has been written.
                reg_bank[0]  <= i_data_in;
              end
              else begin
                // Incorrect code; remain locked.
                first_unlock <= 1'b0;
              end
            end
            else begin
              // Already waiting for the second code: ignore any additional write to address 0.
              first_unlock <= 1'b0;
            end
          end
          else if (i_addr == p_address_width'd1) begin
            if (first_unlock == 1'b1) begin
              if (i_data_in == p_unlock_code_1) begin
                // Correct second unlock code received; complete the unlock sequence.
                locked      <= 1'b0;
                first_unlock<= 1'b0;
                reg_bank[1] <= i_data_in;
              end
              else begin
                // Incorrect code; remain locked.
                first_unlock <= 1'b0;
              end
            end
            else begin
              // Not in the proper state for unlocking; ignore write.
              first_unlock <= 1'b0;
            end
          end
          else begin
            // Attempt to write to any address other than 0 or 1 while locked is not allowed.
            // Do nothing.
          end
        end
        else begin
          // Unlocked: allow write to any address.
          reg_bank[i_addr] <= i_data_in;
        end
        // For write operations, output 0 on the data bus.
        o_data_out <= {p_data_width{1'b0}};
      end
      else begin  // Read operation
        if (locked) begin
          // While locked, always output 0.
          o_data_out <= {p_data_width{1'b0}};
        end
        else begin
          // In unlocked state, only addresses 0 and 1 are write-only.
          if ((i_addr == p_address_width'd0) || (i_addr == p_address_width'd1))
            o_data_out <= {p_data_width{1'b0}};
          else
            o_data_out <= reg_bank[i_addr];
        end
      end
    end
  end

endmodule
module secure_read_write_register_bank #(
  parameter int p_address_width = 8,
  parameter int p_data_width = 8,
  parameter bit[7:0] p_unlock_code_0 = 8'hAB,
  parameter bit[7:0] p_unlock_code_1 = 8'hCD
) (
  input  logic [p_address_width-1:0] i_addr,
  input  logic [p_data_width-1:0]    i_data_in,
  input  logic                         i_read_write_enable,
  input  logic                         i_capture_pulse,
  input  logic                         i_rst_n,
  output logic [p_data_width-1:0]    o_data_out
);

  // Unlock State Machine
  typedef enum { UNLOCKED, UNLOCKING } unlock_state_t;
  logic [7:0] addr_q;
  unlock_state_t unlock_state_q;
  assign o_data_out = (i_read_write_enable &&!i_capture_pulse)? 0 : i_data_in;
  
  always_ff @(posedge i_capture_pulse) begin
    if (i_rst_n == 0) begin
      addr_q <= 8'b0000000;
      unlock_state_q <= UNLOCKED;
    end else begin
      case (unlock_state_q)
        UNLOCKED: begin
          if (i_addr == 8'h00) begin
            if (i_data_in == p_unlock_code_0) begin
              addr_q <= 8'b0000000;
              unlock_state_q <= UNLOCKING;
            end else begin
              addr_q <= 8'b0000000;
              unlock_state_q <= UNLOCKED;
            end
          end else if (i_addr == 8'h01) begin
            if (i_data_in == p_unlock_code_1) begin
              addr_q <= 8'b0000000;
              unlock_state_q <= UNLOCKING;
            end else begin
              addr_q <= 8'b0000000;
              unlock_state_q <= UNLOCKED;
            end
          end else begin
            addr_q <= 8'b0000000;
            unlock_state_q <= UNLOCKED;
          end
        end
        UNLOCKING: begin
          if (i_addr == 8'h00 || i_addr == 8'h01) begin
            addr_q <= 8'b0000000;
            unlock_state_q <= UNLOCKED;
          end else begin
            addr_q <= 8'b0000000;
            unlock_state_q <= UNLOCKING;
          end
        end
        default: begin
          addr_q <= 8'b0000000;
          unlock_state_q <= UNLOCKED;
        end
      endcase
    end
  end
  
  always_comb begin
    if (i_read_write_enable &&!i_capture_pulse) begin
      if (i_addr == 8'h00) begin
        o_data_out = 8'h00;
      end else if (i_addr == 8'h01) begin
        o_data_out = 8'h00;
      end else if (addr_q == 8'h00) begin
        o_data_out = 8'h00;
      end else if (addr_q == 8'h01) begin
        o_data_out = 8'h00;
      end else begin
        o_data_out = 8'h00;
      end
    end else begin
      o_data_out = 8'h00;
    end
  end
  
endmodule
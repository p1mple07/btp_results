module secure_read_write_register_bank #(
  parameter int p_address_width = 8,
  parameter int p_data_width    = 8,
  parameter int p_unlock_code_0 = 8'hAB,
  parameter int p_unlock_code_1 = 8'hCD
) (
  input  logic [p_address_width-1:0] i_addr,
  input  logic [p_data_width-1:0]      i_data_in,
  input  logic                           i_read_write_enable,
  input  logic                           i_capture_pulse,
  input  logic                           i_rst_n,
  output logic [p_data_width-1:0]      o_data_out
);

  localparam int UnlockAddrWidth = p_address_width;
  localparam int UnlockDataWidth = p_data_width;

  logic [UnlockAddrWidth-1:0] addr_reg;
  logic [UnlockDataWidth-1:0] data_reg;

  logic is_write;
  logic is_read;
  assign is_write = ~is_read && i_read_write_enable;
  assign is_read  =  is_read && i_read_write_enable;

  always_ff @(posedge i_capture_pulse, posedge i_rst_n) begin
    if (!i_rst_n) begin
      addr_reg <= '0;
      data_reg <= '0;
    end else begin
      if (is_write) begin
        if ((i_addr == p_unlock_code_0) || (i_addr == p_unlock_code_1)) begin
          addr_reg <= i_addr;
          data_reg <= i_data_in;
        end
      end else if (is_read) begin
        case (addr_reg)
          p_unlock_code_0: begin
            if (i_addr == p_unlock_code_0) begin
              addr_reg <= '0;
              data_reg <= '0;
            end
          end
          p_unlock_code_1: begin
            if (i_addr == p_unlock_code_1) begin
              addr_reg <= '0;
              data_reg <= '0;
            end
          end
          default: begin
            addr_reg <= '0;
            data_reg <= '0;
          end
        endcase
      end
    end
  end

  always_comb begin
    case (addr_reg)
      p_unlock_code_0: o_data_out = data_reg;
      p_unlock_code_1: o_data_out = data_reg;
      default            : o_data_out = '0;
    endcase
  end

endmodule
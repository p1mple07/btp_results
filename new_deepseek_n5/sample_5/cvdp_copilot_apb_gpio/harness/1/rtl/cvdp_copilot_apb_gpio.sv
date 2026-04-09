parameter GPIO_WIDTH = 8;
input
  pclk,
  preset_n,
  psel,
  paddr[7:2],
  penable,
  pwrite,
  pwdata[31:0],
  gpio_in[GPIO_WIDTH-1:0];

output
  prdata[31:0],
  pready,
  pslverr,
  gpio_out[GPIO_WIDTH-1:0],
  gpio_enable[GPIO_WIDTH-1:0],
  gpio_int[GPIO_WIDTH-1:0],
  comb_int;

reg
  reg_out[31:0],
  reg_addr[7:2],
  reg_data[31:0],
  reg_int[GPIO_WIDTH-1:0],
  reg_int_pol,
  reg_int Sensitivity,
  reg_int_mask;

always
  case (paddr[7:3])
    8'b11111111: reg_addr = 7;
    8'b11111110: reg_addr = 6;
    // ... other address cases ...
  default: reg_addr = 0;
  endcase

  if (penable & pwrite) begin
    case (paddr[7:3])
      8'b11111111: reg_data = pwdata;
      default: reg_data = 0;
    endcase
    prdata = reg_data;
  else if (pwrite) begin
    case (paddr[7:3])
      8'b11111111: reg_data = pwdata;
      default: reg_data = 0;
    endcase
  end else
    prdata = 0;
  end

  // GPIO Output Control
  if (gpio_enable[i]) begin
    if (pwrite & paddr == i+8) begin
      if (pwdata) begin
        if (pclk) begin
          reg_out[i] = 1;
        end
      end else begin
        if (!pclk) begin
          reg_out[i] = 1;
        end
      end
    end else begin
      reg_out[i] = 0;
    end
  end

  // Interrupt Generation
  if (gpio_int[i]) begin
    if (gpio_int_pol & (gpio_in[i] ^ reg_in_state[i])) begin
      reg_int_mask |= (1 << i);
    end
  end

  comb_int = reg_int_mask;
endmodule
module behavior
  always_comb begin
    if (reset_n) begin
      tx_block#WORD_WIDTH(.clk(clock), .reset_n(reset_n), .data_in(data_in), .sel(sel)) #WORD_WIDTH(.serial_out(0), .done(0), .serial_clk(0));
      rx_block#WORD_WIDTH(.clk(serial_clk), .reset_n(reset_n), .data_in(0), .sel(sel)) #WORD_WIDTH(.data_out(0), .done(0));
    else begin
      tx_block#WORD_WIDTH(.clk(clock), .reset_n(reset_n), .data_in(data_in), .sel(sel)) #WORD_WIDTH(.serial_out(0), .done(0), .serial_clk(0));
      serial high after 1 clock: #1
      rx_block#WORD_WIDTH(.clk(serial_clk), .reset_n(reset_n), .data_in(0), .sel(sel)) #WORD_WIDTH(.data_out(0), .done(0));
      serial high after 1 clock: #1
    end
  end
endmodule

rtl/tx_block
  input clock, reset_n, data_in, sel;
  output serial_out, done, serial_clk;

  // Tx block behavior
  always_comb begin
    if (reset_n) begin
      serial_out = 0;
      done = 0;
      serial_clk = 0;
    else begin
      if (sel == 000) begin
        serial_out = 0;
        done = 0;
        serial_clk = 0;
      else begin
        case (sel)
          001: begin
            serial_out = data_in[7:0];
            done = 0;
            serial_clk = 1;
          end
          010: begin
            serial_out = data_in[15:0];
            done = 0;
            serial_clk = 1;
          end
          011: begin
            serial_out = data_in[31:0];
            done = 0;
            serial_clk = 1;
          end
          100: begin
            serial_out = data_in[63:0];
            done = 0;
            serial_clk = 1;
          end
          default: begin
            serial_out = 0;
            done = 0;
            serial_clk = 0;
          end
        endcase
      end
    end
  end
endmodule

rtl/rx_block
  input clock, reset_n, data_in, sel;
  output data_out, done;
  input serial_clk;

  // Rx block behavior
  reg indata;
  reg valid;
  reg data_out;
  reg done;

  parameter RX SerWidth = 64;

  always_comb begin
    if (reset_n) begin
      indata = 0;
      valid = 0;
      data_out = 0;
      done = 0;
    else begin
      if (valid) begin
        data_out = indata;
        done = 1;
        valid = 0;
      end
    end
  end

  // Rx block behavior
  always_comb begin
    if (reset_n) begin
      indata = 0;
      valid = 0;
    else begin
      if (sel == 000) begin
        data_out = 0;
        valid = 0;
      else begin
        case (sel)
          001: begin
            data_out = {56'h0, data_in[7:0]};
            valid = 1;
          end
          010: begin
            data_out = {48'h0, data_in[15:0]};
            valid = 1;
          end
          011: begin
            data_out = {32'h0, data_in[31:0]};
            valid = 1;
          end
          100: begin
            data_out = data_in[63:0];
            valid = 1;
          end
          default: begin
            data_out = 0;
            valid = 0;
          end
        endcase
      end
    end
  end
endmodule
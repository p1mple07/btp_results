
case(paddr)
  16'h0a: begin 
    TEMP_LOW    <= pwdata;
    pslverr     <= 1'b0;
    end
  16'h0b: begin 
    TEMP_MED    <= pwdata;
    pslverr     <= 1'b0;
    end
  16'h0c: begin
    TEMP_HIGH   <= pwdata;
    pslverr     <= 1'b0;
    end
  16'h0f: begin
    temp_adc_in <= pwdata;
    pslverr     <= 1'b0;
    end
  default:pslverr     <= 1'b1;
endcase

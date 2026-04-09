
assign misaligned_addr = 1'b0;
...
case (ex_if_type_i)
  2'b00: begin  
      case (data_addr_int[1:0])
        2'b00:   dmem_be = 4'b0001;
        2'b01:   dmem_be = 4'b0010;
        2'b10:   dmem_be = 4'b0100;
        2'b11:   dmem_be = 4'b1000;
        default: dmem_be = 4'b0000;
      endcase
  end
  2'b01: begin  
      case (data_addr_int[1:0])
        2'b00:   dmem_be = 4'b0011;
        2'b10:   dmem_be = 4'b1100;
        default: begin
            dmem_be = 4'b0000;
            misaligned_addr = 1'b1;
        end
      endcase
  end
  2'b10: begin  
      case (data_addr_int[1:0])
        2'b00:   dmem_be = 4'b1111;
        default: begin
            dmem_be = 4'b0000;
            misaligned_addr = 1'b1;
        end
      endcase
  end
  default: begin
      dmem_be = 4'b0000;
      misaligned_addr = 1'b1;
  end 
endcase

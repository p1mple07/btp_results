module unpack_one_hot(
    input sign,
    input size,
    input [2:0] one_hot_selector,
    input [255:0] source_reg,
    output [511:0] destination_reg
);
    parameter i;
    integer i;
    integer chunk_size;
    integer src_offset;
    integer dst_offset;
    
    always begin
        destination_reg = 0;
        
        case (one_hot_selector)
        // 3'b001: unpack each bit into 8-bit
        3'b001:
            chunk_size = 1;
            src_offset = 0;
            for (i = 0; i < 256; i = i + chunk_size) {
                // unpack 1 bit into 8-bit
                byte b = (source_reg[src_offset] >> 7 - src_offset) & 1;
                if (sign) {
                    b = b ? (8'b11111111) : (8'b00000000);
                } else {
                    b = b ? (8'b00000000) : (8'b11111111);
                }
                destination_reg[dst_offset:dst_offset+7] = b;
                src_offset += chunk_size;
                dst_offset += chunk_size;
            }
            break;
        // 3'b010: unpack each 2-bit segment into 8-bit
        3'b010:
            chunk_size = 2;
            src_offset = 0;
            for (i = 0; i < 256; i = i + chunk_size) {
                // unpack 2 bits into 8-bit
                byte b = (source_reg[src_offset + 1] >> 7 - src_offset) & 2;
                if (sign) {
                    b = b ? (8'b11111111) : (8'b00000000);
                } else {
                    b = b ? (8'b00000000) : (8'b11111111);
                }
                destination_reg[dst_offset:dst_offset+7] = b;
                src_offset += chunk_size;
                dst_offset += chunk_size;
            }
            break;
        // 3'b100: size-dependent
        3'b100:
            if (size) {
                // unpack 8-bit into 16-bit
                byte src8 = source_reg[src_offset:src_offset+7];
                if (sign) {
                    src8 = src8 ? (16'b10_0000_0000_0000) : (16'b00_0000_0000_0000);
                } else {
                    src8 = src8 ? (16'b00_0000_0000_0000) : (16'b11_1111_1111_1111);
                }
                destination_reg[dst_offset:dst_offset+15] = src8;
                src_offset += 8;
                dst_offset += 16;
            } else {
                // unpack 4-bit into 8-bit
                byte src4 = source_reg[src_offset:src_offset+3];
                if (sign) {
                    src4 = src4 ? (8'b1111_0000) : (8'b0000_1111);
                } else {
                    src4 = src4 ? (8'b0000_1111) : (8'b1111_0000);
                }
                destination_reg[dst_offset:dst_offset+7] = src4;
                src_offset += 4;
                dst_offset += 8;
            }
            break;
        default:
            // assign source_reg directly to destination_reg
            destination_reg = source_reg;
            break;
        endcase
    end
endmodule
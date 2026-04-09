module unpack_one_hot (
    input         sign,
    input         size,
    input  [2:0]  one_hot_selector,
    input  [255:0] source_reg,
    output reg [511:0] destination_reg
);

  // In this implementation the destination register is always 512 bits wide.
  // To achieve this, the unpacking is performed over only a portion of source_reg
  // so that the total expanded width equals 512 bits.
  //
  // For one_hot_selector = 3'b001:
  //   Each 1-bit segment (from the lower 64 bits of source_reg) is expanded to 8 bits.
  //   (64 segments x 8 bits = 512 bits)
  //
  // For one_hot_selector = 3'b010:
  //   Each 2-bit segment (from the lower 128 bits of source_reg) is expanded to 8 bits.
  //   (64 segments x 8 bits = 512 bits)
  //
  // For one_hot_selector = 3'b100:
  //   When size = 1:
  //     Each 8-bit segment (all 256 bits of source_reg divided into 32 segments)
  //     is expanded to 16 bits.
  //     (32 segments x 16 bits = 512 bits)
  //
  //   When size = 0:
  //     Each 4-bit segment (all 256 bits divided into 64 segments)
  //     is expanded to 8 bits.
  //     (64 segments x 8 bits = 512 bits)
  //
  // Default case:
  //   The source_reg is directly assigned to the lower 256 bits of destination_reg
  //   (the upper 256 bits remain zero).

  integer i;
  reg [7:0] seg;  // temporary register to hold the extracted segment

  always @(*) begin
    // Default initialization: clear destination register
    destination_reg = 512'd0;

    case(one_hot_selector)
      3'b001: begin
        // Unpack lower 64 bits of source_reg:
        // Each 1-bit segment is expanded to an 8-bit segment.
        for(i = 0; i < 64; i = i + 1) begin
          // Extract the i-th bit from source_reg.
          if (sign)
            // Sign-extend: replicate the bit into all upper bits.
            destination_reg[8*i+7:8*i] = {{7{source_reg[i]}}, source_reg[i]};
          else
            // Zero-extend.
            destination_reg[8*i+7:8*i] = {7'b0, source_reg[i]};
        end
      end

      3'b010: begin
        // Unpack lower 128 bits of source_reg:
        // Each 2-bit segment is expanded to an 8-bit segment.
        // (There are 64 segments: 64 x 2 = 128 bits used from source_reg.)
        for(i = 0; i < 64; i = i + 1) begin
          seg = source_reg[2*i+1:2*i];  // extract 2 bits
          if (sign)
            destination_reg[8*i+7:8*i] = {{7{seg[1]}}, seg};
          else
            destination_reg[8*i+7:8*i] = {7'b0, seg};
        end
      end

      3'b100: begin
        if (size) begin
          // size = 1: Each 8-bit segment (from the full 256-bit source_reg)
          // is expanded to a 16-bit segment.
          // (256/8 = 32 segments; 32 x 16 = 512 bits)
          for(i = 0; i < 32; i = i + 1) begin
            seg = source_reg[8*i+7:8*i];  // extract 8 bits
            if (sign)
              destination_reg[16*i+15:16*i] = {{7{seg[7]}}, seg};
            else
              destination_reg[16*i+15:16*i] = {7'b0, seg};
          end
        end
        else begin
          // size = 0: Each 4-bit segment (from the full 256-bit source_reg)
          // is expanded to an 8-bit segment.
          // (256/4 = 64 segments; 64 x 8 = 512 bits)
          for(i = 0; i < 64; i = i + 1) begin
            seg = source_reg[4*i+3:4*i];  // extract 4 bits
            if (sign)
              destination_reg[8*i+7:8*i] = {{7{seg[3]}}, seg};
            else
              destination_reg[8*i+7:8*i] = {7'b0, seg};
          end
        end
      end

      default: begin
        // Default behavior: assign source_reg directly to the lower 256 bits
        // of destination_reg; the upper 256 bits remain zero.
        destination_reg = {256'd0, source_reg};
      end
    endcase
  end

endmodule
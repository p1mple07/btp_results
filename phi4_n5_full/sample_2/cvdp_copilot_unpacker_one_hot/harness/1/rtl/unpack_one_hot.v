module unpack_one_hot (
  input         sign,
  input         size,
  input  [2:0]  one_hot_selector,
  input  [255:0] source_reg,
  output reg [511:0] destination_reg
);

  // The module unpacks data from source_reg into destination_reg.
  // Depending on one_hot_selector, a subset of source_reg is used.
  // Note:
  //   • For one_hot_selector = 3'b001, each 1‐bit segment is expanded to 8 bits.
  //     (64 segments are used; 64 bits of source_reg are processed.)
  //   • For one_hot_selector = 3'b010, each 2‐bit segment is expanded to 8 bits.
  //     (64 segments are used; 128 bits of source_reg are processed.)
  //   • For one_hot_selector = 3'b100:
  //       – If size == 1, each 8‐bit segment is sign/zero‐extended to 16 bits.
  //         (32 segments are used; all 256 bits of source_reg are processed.)
  //       – If size == 0, each 4‐bit segment is sign/zero‐extended to 8 bits.
  //         (64 segments are used; all 256 bits of source_reg are processed.)
  //   • In the default case, source_reg is assigned to the lower 256 bits of
  //     destination_reg (the upper 256 bits are zero).

  always @(*) begin
    case(one_hot_selector)
      3'b001: begin
        // Case: one_hot_selector = 3'b001
        // Process 64 segments. Each segment is 1 bit from source_reg,
        // expanded to 8 bits. (Only the lower 64 bits of source_reg are used.)
        integer i;
        reg [511:0] temp;
        temp = 0;
        for (i = 0; i < 64; i = i + 1) begin
          // Extract 1 bit from source_reg at position i.
          // If sign==1, perform sign extension; otherwise, zero extend.
          temp[i*8 +: 8] = (sign ? {7{source_reg[i]}, source_reg[i]} : {7'b0, source_reg[i]});
        end
        destination_reg = temp;
      end
      3'b010: begin
        // Case: one_hot_selector = 3'b010
        // Process 64 segments. Each segment is 2 bits from source_reg,
        // expanded to 8 bits. (Only the lower 128 bits of source_reg are used.)
        integer i;
        reg [511:0] temp;
        temp = 0;
        for (i = 0; i < 64; i = i + 1) begin
          // Extract 2 bits starting at bit position 2*i.
          // Note: source_reg[2*i+1 -: 2] extracts bits [2*i+1:2*i].
          temp[i*8 +: 8] = (sign ? {7{source_reg[2*i+1]}, source_reg[2*i+1 -: 2]} : {7'b0, source_reg[2*i+1 -: 2]});
        end
        destination_reg = temp;
      end
      3'b100: begin
        // Case: one_hot_selector = 3'b100
        if (size == 1) begin
          // When size==1: Process 32 segments.
          // Each segment is 8 bits from source_reg, expanded to 16 bits.
          // (All 256 bits of source_reg are used.)
          integer i;
          reg [511:0] temp;
          temp = 0;
          for (i = 0; i < 32; i = i + 1) begin
            // Extract 8 bits starting at bit position 8*i.
            // source_reg[8*i+7 -: 8] extracts bits [8*i+7 : 8*i].
            temp[i*16 +: 16] = (sign ? {15{source_reg[8*i+7]}, source_reg[8*i+7 -: 8]} : {15'b0, source_reg[8*i+7 -: 8]});
          end
          destination_reg = temp;
        end else begin
          // When size==0: Process 64 segments.
          // Each segment is 4 bits from source_reg, expanded to 8 bits.
          // (All 256 bits of source_reg are used.)
          integer i;
          reg [511:0] temp;
          temp = 0;
          for (i = 0; i < 64; i = i + 1) begin
            // Extract 4 bits starting at bit position 4*i.
            // source_reg[4*i+3 -: 4] extracts bits [4*i+3 : 4*i].
            temp[i*8 +: 8] = (sign ? {7{source_reg[4*i+3]}, source_reg[4*i+3 -: 4]} : {7'b0, source_reg[4*i+3 -: 4]});
          end
          destination_reg = temp;
        end
      end
      default: begin
        // Default: Directly assign source_reg to the lower 256 bits of destination_reg.
        destination_reg = {256'd0, source_reg};
      end
    endcase
  end

endmodule
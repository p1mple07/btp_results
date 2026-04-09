module unpack_one_hot (
  input           sign,         // 1-bit sign control: 1 = signed, 0 = unsigned
  input           size,         // 1-bit size control (used when one_hot_selector == 3'b100)
  input  [2:0]    one_hot_selector, // One-hot encoded selector for unpacking granularity
  input  [255:0]  source_reg,   // 256-bit packed input data
  output reg [511:0] destination_reg // 512-bit destination register
);

  // Default assignment: destination_reg lower 256 bits = source_reg, rest zero.
  // This default will be overridden by valid one_hot_selector cases.
  always @(*) begin
    destination_reg = {256'b0, source_reg};

    case (one_hot_selector)
      3'b001: begin
        // Case 1: Each 1-bit segment of source_reg is unpacked into an 8-bit segment.
        // We use only the lower 64 segments (64*8 = 512 bits).
        integer i;
        for (i = 0; i < 64; i = i + 1) begin
          // Extract 1-bit chunk from source_reg at position i.
          bit bit_val = source_reg[i];
          if (sign)
            destination_reg[i*8 +: 8] = {7{bit_val}};
          else
            destination_reg[i*8 +: 8] = {7'b0, bit_val};
        end
      end

      3'b010: begin
        // Case 2: Each 2-bit segment of source_reg is unpacked into an 8-bit segment.
        // We use only the lower 64 segments (64*8 = 512 bits).
        integer i;
        for (i = 0; i < 64; i = i + 1) begin
          // Extract 2-bit chunk starting at bit 2*i.
          bit [1:0] chunk;
          {chunk} = source_reg[2*i +: 2];
          if (sign)
            destination_reg[i*8 +: 8] = {{6{chunk[1]}}, chunk};
          else
            destination_reg[i*8 +: 8] = {6'b0, chunk};
        end
      end

      3'b100: begin
        // Case 3: Size-dependent behavior.
        if (size) begin
          // When size == 1: Each 8-bit segment of source_reg is unpacked into a 16-bit segment.
          // 256/8 = 32 segments, each 16 bits -> 32*16 = 512 bits.
          integer i;
          for (i = 0; i < 32; i = i + 1) begin
            // Extract 8-bit chunk starting at bit 8*i.
            bit [7:0] chunk;
            {chunk} = source_reg[8*i +: 8];
            if (sign)
              destination_reg[i*16 +: 16] = {{7{chunk[7]}}, chunk};
            else
              destination_reg[i*16 +: 16] = {7'b0, chunk};
          end
        end
        else begin
          // When size == 0: Each 4-bit segment of source_reg is unpacked into an 8-bit segment.
          // 256/4 = 64 segments, each 8 bits -> 64*8 = 512 bits.
          integer i;
          for (i = 0; i < 64; i = i + 1) begin
            // Extract 4-bit chunk starting at bit 4*i.
            bit [3:0] chunk;
            {chunk} = source_reg[4*i +: 4];
            if (sign)
              destination_reg[i*8 +: 8] = {{3{chunk[3]}}, chunk};
            else
              destination_reg[i*8 +: 8] = {3'b0, chunk};
          end
        end
      end

      default: begin
        // Default case: No valid one_hot_selector provided.
        // The source_reg is directly assigned to the lower 256 bits of destination_reg.
        destination_reg = {256'b0, source_reg};
      end
    endcase
  end

endmodule
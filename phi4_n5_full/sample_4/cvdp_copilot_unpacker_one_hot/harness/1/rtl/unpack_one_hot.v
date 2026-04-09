module implementing a flexible unpacking mechanism.
// The module expands a 256‐bit source register into a 512‐bit destination register
// according to a one‐hot selector, a sign control, and a size control.
//
// Cases:
//   • one_hot_selector = 3'b001:
//         Each 1‐bit from source_reg is expanded to an 8‐bit segment.
//         For sign==1, a 1 bit becomes 0x00 or 0xFF; for sign==0, it becomes 0x00 or 0x01.
//   • one_hot_selector = 3'b010:
//         Each 2‐bit segment from source_reg is expanded to an 8‐bit segment.
//         The 2 bits are sign‐ or zero‐extended to 8 bits.
//   • one_hot_selector = 3'b100:
//         If size==1:
//             Each 8‐bit segment from source_reg is expanded to a 16‐bit segment.
//         Else (size==0):
//             Each 4‐bit segment from source_reg is expanded to an 8‐bit segment.
//         In both cases, the extracted value is sign‐ or zero‐extended as indicated by “sign”.
//   • Default:
//         The entire source_reg is assigned to the lower 256 bits of destination_reg (upper 256 bits = 0).
//
module unpack_one_hot (
  input         sign,         // 1: sign-extend, 0: zero-extend
  input         size,         // For one_hot_selector==3'b100: 1 => 8-bit source chunks, 0 => 4-bit source chunks
  input  [2:0]  one_hot_selector, // One-hot selector controlling granularity
  input  [255:0] source_reg,    // Packed 256-bit input data
  output reg [511:0] destination_reg // Expanded 512-bit output data
);

  integer i;
  // Temporary registers for segment extraction.
  reg [7:0] seg;       // Used for 8-bit segments
  reg [15:0] seg16;    // Used for 16-bit segments

  always @(*) begin
    // Default initialization: clear destination register.
    destination_reg = 512'd0;

    case (one_hot_selector)
      3'b001: begin
        // Case 3'b001: Each 1-bit segment from source_reg becomes an 8-bit segment.
        // Number of segments = 512/8 = 64.
        for (i = 0; i < 64; i = i + 1) begin
          // Extract one bit from source_reg.
          // (Assumes source_reg is at least 64 bits; unused bits default to 0.)
          if (sign)
            seg = (source_reg[i]) ? 8'hFF : 8'h00;
          else
            seg = (source_reg[i]) ? 8'h01 : 8'h00;
          destination_reg[i*8 +: 8] = seg;
        end
      end

      3'b010: begin
        // Case 3'b010: Each 2-bit segment from source_reg becomes an 8-bit segment.
        // Number of segments = 64 (using 128 bits of source_reg).
        for (i = 0; i < 64; i = i + 1) begin
          // Extract 2 bits from source_reg.
          seg = source_reg[i*2 +: 2];
          if (sign)
            // Sign-extend the 2-bit value to 8 bits.
            seg = {{6{seg[1]}}, seg};
          else
            // Zero-extend the 2-bit value.
            seg = {{6'd0}, seg};
          destination_reg[i*8 +: 8] = seg;
        end
      end

      3'b100: begin
        // Case 3'b100: Behavior depends on the "size" signal.
        if (size == 1) begin
          // When size==1:
          // Each segment is 16 bits in the destination.
          // Number of segments = 512/16 = 32.
          // Each segment uses 8 bits from source_reg (total 256 bits used).
          for (i = 0; i < 32; i = i + 1) begin
            seg = source_reg[i*8 +: 8];
            if (sign)
              // Sign-extend the 8-bit value to 16 bits.
              seg16 = {{8{seg[7]}}, seg};
            else
              // Zero-extend the 8-bit value.
              seg16 = {8'd0, seg};
            destination_reg[i*16 +: 16] = seg16;
          end
        end
        else begin
          // When size==0:
          // Each segment is 8 bits in the destination.
          // Number of segments = 64 (using 256 bits of source_reg, 4 bits per segment).
          for (i = 0; i < 64; i = i + 1) begin
            seg = source_reg[i*4 +: 4];
            if (sign)
              // Sign-extend the 4-bit value to 8 bits.
              seg = {{7{seg[3]}}, seg};
            else
              // Zero-extend the 4-bit value.
              seg = {7'd0, seg};
            destination_reg[i*8 +: 8] = seg;
          end
        end
      end

      default: begin
        // Default case: assign source_reg directly to the lower 256 bits of destination_reg.
        destination_reg = {source_reg, 256'd0};
      end
    endcase
  end

endmodule
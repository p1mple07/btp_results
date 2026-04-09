module unpack_one_hot
(
    input sign,
    input size,
    input [2:0] one_hot_selector,
    input source_reg,
    output [511:0] destination_reg
);

    // Initialize destination register to zero
    destination_reg <= 0;

    // Determine the number of bits to unpack and the size of the destination segment
    case (one_hot_selector)
    // Case 001: unpack each bit into 8-bit segment
    3'b001:
        // Each bit is sign-extended to 8 bits
        size <= 8;
        // Unpack each bit into 8-bit segment
        for (i = 0; i < 256; i = i + 1) begin
            // Extract the ith bit from source_reg
            bit [7:0] bit_val = source_reg[i];
            // Sign-extend to 8 bits
            destination_reg[(i * 8) + 0:7] = (bit_val & 0x1) ? - (bit_val) : bit_val;
        end
        break;

    // Case 010: unpack each 2-bit segment into 8-bit segment
    3'b010:
        // Each 2-bit segment is zero-extended to 8 bits
        size <= 8;
        // Unpack each 2-bit segment into 8-bit segment
        for (i = 0; i < 128; i = i + 1) begin
            // Extract the 2-bit segment from source_reg
            bit [7:0] seg_val = source_reg[i * 2: i * 2 + 1];
            // Zero-extend to 8 bits
            destination_reg[(i * 8) + 0:7] = seg_val;
        end
        break;

    // Case 100: handle size-dependent behavior
    3'b100:
        // Determine the segment size based on 'size' input
        if (size == 1) begin
            // Each 8-bit segment is sign-extended to 16 bits
            size <= 16;
            for (i = 0; i < 32; i = i + 1) begin
                // Extract the 8-bit segment from source_reg
                bit [15:0] seg_val = source_reg[i * 8: i * 8 + 7];
                // Sign-extend to 16 bits
                destination_reg[(i * 16) + 0:15] = (seg_val & 0xFF) ? - (seg_val) : seg_val;
            end
        else begin
            // Each 4-bit segment is zero-extended to 8 bits
            size <= 8;
            for (i = 0; i < 64; i = i + 1) begin
                // Extract the 4-bit segment from source_reg
                bit [7:0] seg_val = source_reg[i * 4: i * 4 + 3];
                // Zero-extend to 8 bits
                destination_reg[(i * 8) + 0:7] = seg_val;
            end
        end
        break;

    // Default case: assign source_reg directly to destination_reg
    default:
        size <= 1;
        for (i = 0; i < 256; i = i + 1) begin
            // Assign each bit to destination_reg
            destination_reg[i] = source_reg[i];
        end
        break;

    endcase
endmodule
module unpack_one_hot(
    input sign,
    input size,
    input [2:0] one_hot_selector,
    input [255:0] source_reg,
    output [511:0] destination_reg
);
    parameter i;
    integer i;
    
    // Initialize destination register
    destination_reg = 0;
    
    // Determine unpacking granularity
    case one_hot_selector
    // Case 001: 1-bit to 8-bit unpacking
    .case 3'b001
        // Each bit is unpacked into 8 bits
        for (i = 0; i < 256; i = i + 1) begin
            // Extract the ith bit from source_reg
            bit b = source_reg[255 - i];
            // Pack into 8 bits with sign extension
            destination_reg[8 - (i % 8) + (i % 8)*8] = (b ? -128 : 127) + (b ? 127 : 0);
        end
    // Case 010: 2-bit to 8-bit unpacking
    .case 3'b010
        // Each 2 bits are unpacked into 8 bits
        for (i = 0; i < 128; i = i + 1) begin
            // Extract the 2-bit segment from source_reg
            byte b = source_reg[255 - (i*2):255 - (i*2)+1];
            // Pack into 8 bits with zero extension
            destination_reg[8 - (i % 4) + (i % 4)*4] = b + (b >= 128 ? -128 : 0);
        end
    // Case 100: Size-dependent unpacking
    .case 3'b100
        // Handle size control
        if (size) begin
            // 8-bit to 16-bit unpacking
            for (i = 0; i < 64; i = i + 1) begin
                // Extract the 8-bit segment from source_reg
                byte b = source_reg[255 - (i*4):255 - (i*4)+7];
                // Pack into 16 bits with sign extension
                destination_reg[16 - (i % 8) + (i % 8)*8] = (b ? -128 : 127) + (b ? 127 : 0);
            end
        else begin
            // 4-bit to 8-bit unpacking
            for (i = 0; i < 128; i = i + 1) begin
                // Extract the 4-bit segment from source_reg
                byte b = source_reg[255 - (i*2):255 - (i*2)+3];
                // Pack into 8 bits with zero extension
                destination_reg[8 - (i % 2) + (i % 2)*4] = b + (b >= 128 ? -128 : 0);
            end
        end
    // Default case: direct assignment
    .default
        destination_reg = source_reg;
endmodule
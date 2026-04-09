
always @(*) begin
    // Default assignments
    ram_t0_we = 1'b0;
    ram_t1_we = 1'b0;
    data_0_out = 9'b0;
    data_1_out = 9'b0;

    if (write_enable) begin
         // Write operation: drive write enable signals and assign addresses
         ram_t0_we = 1'b1;
         ram_t1_we = 1'b1;
         ram_t0_addr = write_addr[7:0];
         ram_t1_addr = write_addr[7:0];
         // In write mode, we don't read data, so data_0_out and data_1_out can be undefined or set to a known value.
         data_0_out = {1'b1, write_addr[7:0]};
         data_1_out = {1'b1, write_addr[7:0]};
    end else begin
         // Read operation: use the input addresses to read from external SRAM
         // Assuming external SRAM returns data immediately.
         // For now, we simply pass through the SRAM data.
         // We need to extract valid bit and tag.
         // Let's assume the valid bit is the MSB of the output, and we set it to 1 if the tag is non-zero.
         data_0_out = { (ram_t0_data != 8'h0) ? 1'b1 : 1'b0, ram_t0_data };
         data_1_out = { (ram_t1_data != 8'h0) ? 1'b1 : 1'b0, ram_t1_data };
         // Also drive addresses for read operation
         ram_t0_addr = read_addr_0;
         ram_t1_addr = read_addr_1;
         ram_t0_we = 1'b0;
         ram_t1_we = 1'b0;
    end
end

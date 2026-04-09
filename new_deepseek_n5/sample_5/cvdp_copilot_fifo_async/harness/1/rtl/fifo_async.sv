module rtl/fifo_async (
    parameter integer DATA_WIDTH,
    parameter integer DEPTH,
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire w_data,
    input wire r_clk,
    input wire r_rst,
    input wire r_inc,
    output wire w_full,
    output wire r_empty,
    output wire r_data
);

    // Pointers with overflow bit
    integer write_ptr, read_ptr;
    integer write_ptr_overflow, read_ptr_overflow;

    // Gray counter for write pointer
    reg gray_write_ptr, gray_write_ptr_next;
    always @*+ write_ptr_next = write_ptr ^ (write_ptr & -write_ptr);
    always @*+ gray_write_ptr = write_ptr_next;

    // Gray counter for read pointer
    reg gray_read_ptr, gray_read_ptr_next;
    always @*+ gray_read_ptr_next = gray_read_ptr ^ (gray_read_ptr & -gray_read_ptr);
    always @*+ gray_read_ptr = gray_read_ptr_next;

    // Synchronize pointers between clocks
    reg write_ptr_sync, read_ptr_sync;
    always @*+ write_ptr_sync = gray_write_ptr;
    always @*+ gray_write_ptr = write_ptr_sync;
    always @*+ read_ptr_sync = gray_read_ptr;
    always @*+ gray_read_ptr = read_ptr_sync;

    // Initialize pointers
    initial begin
        write_ptr = 0;
        read_ptr = 0;
        write_ptr_overflow = 0;
        read_ptr_overflow = 0;
    end

    // Write operation
    always @*+ w_rst? w_data: 
        if (w_inc) begin
            gray_write_ptr = write_ptr;
            write_ptr = write_ptr ^ (write_ptr & -write_ptr);
            write_ptr_overflow = write_ptr >= DEPTH;
            w_full = write_ptr_overflow;
        end
    always @*+ w_rst? w_data: 
        if (w_inc) begin
            gray_write_ptr = write_ptr;
            write_ptr = write_ptr ^ (write_ptr & -write_ptr);
            write_ptr_overflow = write_ptr >= DEPTH;
            w_full = write_ptr_overflow;
        end

    // Read operation
    always @*+ r_rst? r_data: 
        if (r_inc) begin
            gray_read_ptr = read_ptr;
            read_ptr = read_ptr ^ (read_ptr & -read_ptr);
            read_ptr_overflow = read_ptr >= DEPTH;
            r_empty = read_ptr_overflow;
        end
    always @*+ r_rst? r_data: 
        if (r_inc) begin
            gray_read_ptr = read_ptr;
            read_ptr = read_ptr ^ (read_ptr & -read_ptr);
            read_ptr_overflow = read_ptr >= DEPTH;
            r_empty = read_ptr_overflow;
        end

    // Data write
    always @*+ w_rst? w_data: 
        if (w_inc) begin
            w_data <= gray_write_ptr;
        end

    // Data read
    always @*+ r_rst? r_data: 
        if (r_inc) begin
            r_data = gray_read_ptr;
        end

endmodule
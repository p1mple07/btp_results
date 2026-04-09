// -----------------------------
// FIFO Buffer Write
// -----------------------------
always @(posedge aclk) begin
    if (!aresetn) begin
        write_ptr <= 0;
        full <= 0;
    end else if (fifo_write) begin
        // Update FIFO write pointer only after register computations
        if (!empty) begin
            fifo_data[write_ptr] <= {y_reg[7:3], cb_reg[7:2], cr_reg[7:3]}; // Store YCbCr in buffer
            fifo_tlast[write_ptr] <= s_axis_tlast;
            fifo_tuser[write_ptr] <= s_axis_tuser;
            write_ptr <= write_ptr + 1;
            full <= (write_ptr == FIFO_DEPTH-1);
        end
    end
end

// -----------------------------
// FIFO Buffer Read
// -----------------------------
always @(posedge aclk) begin
    if (!aresetn) begin
        read_ptr <= 0;
    end else if (fifo_read) begin
        // Update FIFO read pointer only after register computations
        if (!empty) begin
            read_ptr <= read_ptr + 1;
        end
    end
end

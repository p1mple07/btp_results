always @(posedge aclk) begin
    if (!aresetn) begin
        write_ptr <= 0;
        full <= 0;
        read_ptr <= 0; // Initialize read_ptr to 0 at reset
    end else if (fifo_write) begin
        if (!full) begin
            fifo_data[write_ptr] <= {y_reg[7:3], cb_reg[7:2], cr_reg[7:3]}; // Store YCbCr in buffer
            fifo_tlast[write_ptr] <= s_axis_tlast;
            fifo_tuser[write_ptr] <= s_axis_tuser;
            write_ptr <= write_ptr + 1;
            full <= (write_ptr == FIFO_DEPTH-1);
        end
    end
end

always @(posedge aclk) begin
    if (!aresetn) begin
        read_ptr <= 0; // Initialize read_ptr to 0 at reset
    end else if (fifo_read) begin
        if (!full) begin
            read_ptr <= read_ptr + 1;
        end
    end
end

always @(posedge aclk) begin
    if (!aresetn) begin
        y_reg <= 0;
        cb_reg <= 0;
        cr_reg <= 0;
    end else begin
        if (fifo_write) begin
            y_reg  <= y_calc;
            cb_reg <= cb_calc;
            cr_reg <= cr_calc;
        end
    end
end

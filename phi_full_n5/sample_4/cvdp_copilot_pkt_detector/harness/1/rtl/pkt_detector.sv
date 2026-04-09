// Additional logic for `S_ACTIVE` state to update `byte_cnt` and `pkt_reg`
always_ff @(posedge clk or negedge reset) begin
    if (!reset)
        byte_cnt <= 0;
    else if (curr_state == S_ACTIVE)
        byte_cnt <= byte_cnt + 1;
end

always_comb begin
    case (curr_state)
        S_ACTIVE: 
            if (byte_cnt < PKT_BYTES) begin
                pkt_reg <= {pkt_reg, data_in};
            end else begin
                byte_cnt <= 0; // Reset byte counter after packet is fully captured
            end
            nxt_state = (byte_cnt == PKT_BYTES) ? S_WAIT_END : S_ACTIVE;
    endcase
end

// Logic to validate packet and update outputs in `S_WAIT_END` state
always_comb begin
    if (curr_state == S_WAIT_END) begin
        if (pkt_reg[159:152] == END_SYMBOL) begin
            pkt_data <= pkt_reg;
            pkt_count <= pkt_count + 1;

            // Decode packet header to set detection flags
            case (pkt_reg[31:24])
                8'h00: begin
                    mem_read_detected <= 1'b1;
                    mem_write_detected <= 1'b0;
                    io_read_detected <= 1'b0;
                    io_write_detected <= 1'b0;
                    cfg_read0_detected <= 1'b0;
                    cfg_write0_detected <= 1'b0;
                    cfg_read1_detected <= 1'b0;
                    cfg_write1_detected <= 1'b0;
                end
                8'h01: begin
                    mem_read_detected <= 1'b0;
                    mem_write_detected <= 1'b1;
                    io_read_detected <= 1'b0;
                    io_write_detected <= 1'b0;
                    cfg_read0_detected <= 1'b0;
                    cfg_write0_detected <= 1'b0;
                    cfg_read1_detected <= 1'b0;
                    cfg_write1_detected <= 1'b0;
                end
                // Add additional cases for each operation type based on the packet header
                default: begin
                    mem_read_detected <= 1'b0;
                    mem_write_detected <= 1'b0;
                    io_read_detected <= 1'b0;
                    io_write_detected <= 1'b0;
                    cfg_read0_detected <= 1'b0;
                    cfg_write0_detected <= 1'b0;
                    cfg_read1_detected <= 1'b0;
                    cfg_write1_detected <= 1'b0;
                    error_detected <= 1'b0; // Default to no error
                end
            end

            nxt_state = S_IDLE;
        end else begin
            error_detected <= 1'b1; // Flag error if END_SYMBOL is not detected
            nxt_state = S_ERROR;
        end
    end
end

// Reset behavior
always_ff @(posedge clk or negedge reset) begin
    if (!reset)
        byte_cnt <= 0;
    else
        pkt_count <= 0;
        pkt_data <= 160'b0;
        mem_read_detected <= 1'b0;
        mem_write_detected <= 1'b0;
        io_read_detected <= 1'b0;
        io_write_detected <= 1'b0;
        cfg_read0_detected <= 1'b0;
        cfg_write0_detected <= 1'b0;
        cfg_read1_detected <= 1'b0;
        cfg_write1_detected <= 1'b0;
        completion_detected <= 1'b0;
        completion_data_detected <= 1'b0;
        error_detected <= 1'b0;
end

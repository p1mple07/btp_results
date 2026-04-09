// Update byte_cnt and pkt_reg during S_ACTIVE
always_comb begin
    if (byte_cnt == PKT_BYTES - 1) begin
        byte_cnt <= 0;
        pkt_reg <= {pkt_reg[158:0], data_in};
    end else begin
        byte_cnt <= byte_cnt + 1;
    end
end

// Validate the packet and update pkt_data, pkt_count, and flags in S_WAIT_END
always_comb begin
    if (pkt_reg[159:152] == END_SYMBOL) begin
        pkt_count <= pkt_count + 1;
        pkt_data <= pkt_reg;
        completion_detected <= 1'b1;
        completion_data_detected <= 1'b1;
        mem_read_detected <= pkt_reg[159:152];
        mem_write_detected <= pkt_reg[159];
        io_read_detected <= pkt_reg[158];
        io_write_detected <= pkt_reg[158];
        cfg_read0_detected <= pkt_reg[157];
        cfg_write0_detected <= pkt_reg[157];
        cfg_read1_detected <= pkt_reg[156];
        cfg_write1_detected <= pkt_reg[156];
        nxt_state = S_IDLE;
    end else begin
        nxt_state = S_ERROR;
    end
end

// Set error_detected appropriately in S_ERROR
always_comb begin
    if (data_in == START_SYMBOL && data_k_flag == 1'b1) begin
        error_detected <= 1'b0;
        nxt_state = S_ACTIVE;
    end else begin
        error_detected <= 1'b1;
        nxt_state = S_ERROR;
    end
end

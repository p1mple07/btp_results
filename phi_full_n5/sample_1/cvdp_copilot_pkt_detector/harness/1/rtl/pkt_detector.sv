// State Register
always_ff @(posedge clk or negedge reset) begin
    if (!reset)
        curr_state <= S_IDLE;
    else
        curr_state <= nxt_state;
end

// Next State Logic
always_comb begin
    case (curr_state)
        S_IDLE: 
            if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                nxt_state = S_ACTIVE;
            else
                nxt_state = S_IDLE;

        S_ACTIVE: 
            if (byte_cnt == PKT_BYTES)
                nxt_state = S_WAIT_END;
            else
                nxt_state = S_ACTIVE;

        S_WAIT_END: 
            if (pkt_reg[159:152] == END_SYMBOL)
                nxt_state = S_IDLE;
            else
                nxt_state = S_ERROR;

        S_ERROR: 
            if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                nxt_state = S_ACTIVE;
            else
                nxt_state = S_ERROR;

        default: nxt_state = S_IDLE;
    endcase
end

// State Logic
always_comb begin
    case (curr_state)
        S_ACTIVE: 
            begin
                byte_cnt <= byte_cnt + 1;
                pkt_reg <= {pkt_reg[8:0], data_in};
            end
        S_WAIT_END: 
            begin
                // Update packet data
                pkt_data <= pkt_reg;

                // Update packet count
                pkt_count <= pkt_count + 1;

                // Detect operations based on packet header
                mem_read_detected <= (pkt_reg[31:24] == 4'h00);
                mem_write_detected <= (pkt_reg[31:24] == 4'h01);
                io_read_detected <= (pkt_reg[31:24] == 4'h10);
                io_write_detected <= (pkt_reg[31:24] == 4'h11);
                cfg_read0_detected <= (pkt_reg[31] == 4'h00);
                cfg_write0_detected <= (pkt_reg[31] == 4'h01);
                cfg_read1_detected <= (pkt_reg[30] == 4'h00);
                cfg_write1_detected <= (pkt_reg[30] == 4'h01);
                completion_detected <= 1'b1;
                completion_data_detected <= pkt_data;
            end
        S_ERROR: 
            begin
                error_detected <= 1'b1;
                byte_cnt <= 0;
                pkt_reg <= 160'h0;
            end
        default: begin
            byte_cnt <= 0;
            pkt_reg <= 160'h0;
        end
    endcase
end

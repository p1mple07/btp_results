// Continuing the provided partial code

// State Transition Logic
always_comb begin
    case (curr_state)
        S_ACTIVE: 
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt < PKT_BYTES) begin
                pkt_reg <= {pkt_reg[7:0], data_in};
            end else begin
                nxt_state = S_WAIT_END;
            end

        S_WAIT_END: 
            if (pkt_reg[159:152] == END_SYMBOL) begin
                pkt_count <= pkt_count + 1;
                pkt_data <= pkt_reg;
                mem_read_detected <= (pkt_reg[159:152] == 8'h00);
                mem_write_detected <= (pkt_reg[159:152] == 8'h01);
                io_read_detected <= (pkt_reg[159:149] == 8'h00);
                io_write_detected <= (pkt_reg[159:149] == 8'h01);
                cfg_read0_detected <= (pkt_reg[148:144] == 8'h00);
                cfg_write0_detected <= (pkt_reg[148:144] == 8'h01);
                cfg_read1_detected <= (pkt_reg[144:140] == 8'h00);
                cfg_write1_detected <= (pkt_reg[144:140] == 8'h01);
                completion_detected <= 1'b1;
                completion_data_detected <= pkt_data;
                byte_cnt <= 0;
                nxt_state = S_IDLE;
            end else begin
                nxt_state = S_ERROR;
            end

        S_ERROR: 
            error_detected <= 1'b1;
            nxt_state = S_IDLE;

        default: nxt_state = S_IDLE;
    endcase
end

endmodule

// FSM code
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        current_state <= IDLE;
        addr_counter <= 0;
        data_counter <= 0;
        wait_counter <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                rw <= 0;
                next_state = INIT_WRITE;
            end
            INIT_WRITE: begin
                addr_counter <= 0;
                data_counter <= 24'hFF0000;
                rw <= 1;
                next_state = WRITE;
            end
            WRITE: begin
                if (addr_counter == N_ROM - 1) begin
                    rw <= 0;
                    addr_counter <= 0;
                    data_counter <= 0;
                    wait_counter <= 0;
                    next_state = INIT_READ;
                end else begin
                    write_addr <= addr_counter;
                    write_data <= data_counter;
                    addr_counter <= addr_counter + 1;
                    data_counter <= data_counter + 1;
                    next_state = WRITE;
                end
            end
            INIT_READ: begin
                addr_counter <= 0;
                rw <= 0;
                next_state = READ;
            end
            READ: begin
                if (addr_counter == N_ROM - 1) begin
                    rw <= 0;
                    addr_counter <= 0;
                    wait_counter <= i_wait;
                    next_state = WAIT;
                end else begin
                    write_addr <= addr_counter;
                    x_pos <= (addr_counter % SPRITE_WIDTH);
                    y_pos <= (addr_counter / SPRITE_WIDTH);
                    addr_counter <= addr_counter + 1;
                    next_state = READ;
                end
            end
            WAIT: begin
                if (wait_counter == i_wait) begin
                    rw <= 0;
                    done <= 1;
                    next_state = DONE;
                end else begin
                    wait_counter <= wait_counter + 1;
                    next_state = WAIT;
                end
            end
            DONE: begin
                done <= 1;
                next_state = IDLE;
            end
        endcase
    end
end

// Signal generation
assign x_pos = addr_counter & ((1 << SPRITE_WIDTH) - 1);
assign y_pos = (addr_counter >> SPRITE_WIDTH) & ((1 << SPRITE_HEIGHT) - 1);

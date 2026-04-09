// FSM state logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
        addr_counter <= (0 >> (MEM_ADDR_WIDTH - 1));
        data_counter <= (0 >> (PIXEL_WIDTH - 1));
        wait_counter <= 0;
    end else begin
        current_state <= next_state;
        if (current_state == IDLE) begin
            // IDLE actions
            rw <= 0;
            addr_counter <= (0 >> (MEM_ADDR_WIDTH - 1));
            data_counter <= (0 >> (PIXEL_WIDTH - 1));
            next_state <= INIT_WRITE;
        end else if (current_state == INIT_WRITE) begin
            // INIT_WRITE actions
            addr_counter <= (0 >> (MEM_ADDR_WIDTH - 1));
            write_data <= (24'hFF << (PIXEL_WIDTH - 1));
            rw <= 1;
            next_state <= WRITE;
        end else if (current_state == WRITE) begin
            // WRITE actions
            write_addr <= addr_counter;
            write_data <= data_counter;
            if (addr_counter == N_ROM - 1) begin
                addr_counter <= (addr_counter + 1);
                data_counter <= (data_counter + 1);
                next_state <= INIT_READ;
            end else begin
                next_state <= WRITE;
            end
        end else if (current_state == INIT_READ) begin
            // INIT_READ actions
            addr_counter <= (0 >> (MEM_ADDR_WIDTH - 1));
            rw <= 0;
            next_state <= READ;
        end else if (current_state == READ) begin
            // READ actions
            write_addr <= addr_counter;
            x_pos <= (addr_counter >> (X_WIDTH - 1));
            y_pos <= (addr_counter >> (Y_WIDTH - 1));
            if (addr_counter == N_ROM - 1) begin
                addr_counter <= (addr_counter + 1);
                wait_counter <= i_wait;
                next_state <= WAIT;
            end else begin
                next_state <= READ;
            end
        end else if (current_state == WAIT) begin
            // WAIT actions
            if (wait_counter == i_wait) begin
                done <= 1;
                next_state <= DONE;
            end else begin
                wait_counter <= wait_counter + 1;
                next_state <= WAIT;
            end
        end else if (current_state == DONE) begin
            // DONE actions
            done <= 0;
            next_state <= IDLE;
        end
    end
end

// Output logic
assign x_pos = x_pos & (SPRITE_WIDTH - 1);
assign y_pos = y_pos & (SPRITE_HEIGHT - 1);

// Ensure signals do not exceed their constraints
assign write_data = (write_data > (24'h00000000)) ? (24'h00000000) : write_data;
assign write_addr = write_addr & (N_ROM - 1);

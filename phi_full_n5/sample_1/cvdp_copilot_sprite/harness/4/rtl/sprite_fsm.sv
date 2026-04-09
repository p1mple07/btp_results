// FSM code
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        current_state <= IDLE;
        addr_counter <= (0 >> MEM_ADDR_WIDTH-1) << MEM_ADDR_WIDTH-1; // Reset to 0
        data_counter <= (0 >> PIXEL_WIDTH-1) << PIXEL_WIDTH-1;     // Reset to 0
        wait_counter <= (0 >> WAIT_WIDTH-1) << WAIT_WIDTH-1;       // Reset to 0
    end else begin
        case (current_state)
            IDLE: begin
                rw <= 0; // Set to read mode
                next_state <= INIT_WRITE;
            end
            INIT_WRITE: begin
                addr_counter <= 0;
                data_counter <= 24'hFF0000; // Initial data value
                rw <= 1; // Set to write mode
                next_state <= WRITE;
            end
            WRITE: begin
                if (addr_counter == N_ROM - 1) begin
                    next_state <= INIT_READ;
                end else begin
                    next_state <= WRITE;
                end
            end
            INIT_READ: begin
                addr_counter <= 0;
                rw <= 0; // Set to read mode
                next_state <= READ;
            end
            READ: begin
                x_pos <= (addr_counter >> (SPRITE_WIDTH * (PIXEL_WIDTH - 1) - 1)) & ((1 << SPRITE_WIDTH) - 1);
                y_pos <= (addr_counter >> (PIXEL_WIDTH - 1)) & ((1 << SPRITE_HEIGHT) - 1);
                write_addr <= addr_counter;
                next_state <= WAIT;
            end
            WAIT: begin
                if (wait_counter >= i_wait) begin
                    done <= 1;
                    next_state <= DONE;
                end else begin
                    next_state <= WAIT;
                end
            end
            DONE: begin
                done <= 0;
                next_state <= IDLE;
            end
        endcase
    end
end

// Signal generation
assign x_pos = (addr_counter >> (SPRITE_WIDTH * (PIXEL_WIDTH - 1) - 1)) & ((1 << SPRITE_WIDTH) - 1);
assign y_pos = (addr_counter >> (PIXEL_WIDTH - 1)) & ((1 << SPRITE_HEIGHT) - 1);

// Output assignments
assign write_addr = addr_counter;
assign write_data = data_counter;
assign done = 1; // For one clock cycle

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        h_counter   <= 10'd0;
        v_counter   <= 10'd0;
        h_state     <= H_ACTIVE_STATE;
        v_state     <= V_ACTIVE_STATE;
        line_done   <= LOW;
    end
    else begin
        case (h_state)
            H_ACTIVE_STATE: begin
                if (h_counter < H_ACTIVE - 1) begin
                    h_counter <= h_counter + 1;
                    hsync <= HIGH;
                end else begin
                    h_counter <= H_FRONT;
                    hsync <= LOW;
                    h_state <= H_FRONT_STATE;
                end
            end
            H_FRONT_STATE: begin
                if (h_counter < H_FRONT - 1) begin
                    h_counter <= h_counter + 1;
                    hsync <= HIGH;
                end else begin
                    h_counter <= H_PULSE;
                    hsync <= LOW;
                    h_state <= H_PULSE_STATE;
                end
            end
            H_PULSE_STATE: begin
                hsync <= LOW;
                h_counter <= h_counter + 1;
                if (h_counter == H_PULSE - 1) begin
                    h_state <= H_BACK_STATE;
                end
            end
            H_BACK_STATE: begin
                hsync <= HIGH;
                h_counter <= h_counter + 1;
                if (h_counter == H_BACK - 1) begin
                    h_state <= H_ACTIVE_STATE;
                    line_done <= HIGH;
                end
            end
        endcase

        case (v_state)
            V_ACTIVE_STATE: begin
                if (v_counter < V_ACTIVE - 1) begin
                    v_counter <= v_counter + 1;
                    vsync <= HIGH;
                end else begin
                    v_counter <= V_FRONT;
                    vsync <= LOW;
                    v_state <= V_FRONT_STATE;
                end
            end
            V_FRONT_STATE: begin
                if (v_counter < V_FRONT - 1) begin
                    v_counter <= v_counter + 1;
                    vsync <= HIGH;
                end else begin
                    v_counter <= V_PULSE;
                    vsync <= LOW;
                    v_state <= V_PULSE_STATE;
                end
            end
            V_PULSE_STATE: begin
                vsync <= LOW;
                v_counter <= v_counter + 1;
                if (v_counter == V_PULSE - 1) begin
                    v_state <= V_BACK_STATE;
                end
            end
            V_BACK_STATE: begin
                vsync <= HIGH;
                v_counter <= v_counter + 1;
                if (v_counter == V_BACK - 1) begin
                    v_state <= V_ACTIVE_STATE;
                end
            end
        endcase

        // Insert the code to handle the RGB signals based on active states
        // Assuming color_in is valid for all states
        case (h_state | v_state)
            H_ACTIVE_STATE | V_ACTIVE_STATE: begin
                red <= color_in;
                green <= color_in;
                blue <= color_in;
            end
            // Handle other states where RGB should be zero
            default: begin
                red <= 8'd0;
                green <= 8'd0;
                blue <= 8'd0;
            end
        endcase
    end
end

assign clk = clock;
assign sync = 1'b0;
assign blank = hsync & vsync;

assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

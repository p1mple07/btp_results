module vga_controller (
    input logic clock,
    input logic reset,
    input logic [7:0] color_in,
    output logic [9:0] next_x,
    output logic [9:0] next_y,
    output logic hsync,
    output logic vsync,
    output logic [7:0] red,
    output logic [7:0] green,
    output logic [7:0] blue,
    output logic sync,
    output logic clk,
    output logic blank,
    output logic [7:0] h_state,
    output logic [7:0] v_state,
);

    parameter logic [9:0] H_ACTIVE  = 10'd640;
    parameter logic [9:0] H_FRONT   = 10'd16;
    parameter logic [9:0] H_PULSE   = 10'd96;
    parameter logic [9:0] H_BACK    = 10'd48;
    parameter logic [9:0] V_ACTIVE  = 10'd480;
    parameter logic [9:0] V_FRONT   = 10'd10;
    parameter logic [9:0] V_PULSE   = 10'd2;
    parameter logic [9:0] V_BACK    = 10'd33;
    parameter logic LOW   = 1'b0;
    parameter logic HIGH  = 1'b1;
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    logic line_done;
    logic [9:0] h_counter;
    logic [9:0] v_counter;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter   <= 10'd0;
            v_counter   <= 10'd0;
            h_state     <= H_ACTIVE_STATE;
            v_state     <= V_ACTIVE_STATE;
            line_done   <= LOW;
        end else begin
            case (h_state)
                H_ACTIVE_STATE: begin
                    if (h_counter < H_ACTIVE_STATE - 1) begin
                        h_counter <= h_counter + 1;
                    end else begin
                        h_state <= H_FRONT_STATE;
                    end
                end
                H_FRONT_STATE: begin
                    if (h_counter < H_FRONT - 1) begin
                        h_counter <= h_counter + 1;
                    end else begin
                        h_state <= H_PULSE_STATE;
                    end
                end
                H_PULSE_STATE: begin
                    hsync <= LOW;
                    if (h_counter < H_PULSE_STATE - 1) begin
                        h_counter <= h_counter + 1;
                    end else begin
                        h_state <= H_BACK_STATE;
                    end
                end
                H_BACK_STATE: begin
                    h_state <= H_ACTIVE_STATE;
                    hsync <= HIGH;
                    h_counter <= 10'd0;
                end
            endcase

            case (v_state)
                V_ACTIVE_STATE: begin
                    if (v_counter < V_ACTIVE - 1) begin
                        v_counter <= v_counter + 1;
                    end else begin
                        v_state <= V_FRONT_STATE;
                    end
                end
                V_FRONT_STATE: begin
                    if (v_counter < V_FRONT - 1) begin
                        v_counter <= v_counter + 1;
                    end else begin
                        v_state <= V_PULSE_STATE;
                    end
                end
                V_PULSE_STATE: begin
                    vsync <= LOW;
                    if (v_counter < V_PULSE_STATE - 1) begin
                        v_counter <= v_counter + 1;
                    end else begin
                        v_state <= V_BACK_STATE;
                    end
                end
                V_BACK_STATE: begin
                    v_state <= V_ACTIVE_STATE;
                    vsync <= HIGH;
                    v_counter <= 10'd0;
                end
            endcase

            // RGB handling
            if (h_state == H_ACTIVE_STATE) begin
                red   <= color_in[0];
                green <= color_in[1];
                blue  <= color_in[2];
            end else begin
                red   <= 0;
                green <= 0;
                blue  <= 0;
            end
        end
    end

    assign clk = clock;
    assign sync = 1'b0;
    assign blank = hsync & vsync;

    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule

module vga_controller(
    input clk,
    input reset,
    input [7:0] color_in,
    output reg hsync,
    output reg vsync,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue,
    output reg [9:0] next_x,
    output reg [9:0] next_y,
    output reg sync,
    output reg clk,
    output reg blank
);

    // State definitions for horizontal and vertical state machines
    typedef enum logic [31:0] {
        H_ACTIVE,
        H_FRONT,
        H_PULSE,
        H_BACK
    } h_state_t;

    typedef enum logic [31:0] {
        V_ACTIVE,
        V_FRONT,
        V_PULSE,
        V_BACK
    } v_state_t;

    // State machines
    reg [31:0] h_state, v_state;

    // Counters
    reg [9:0] h_counter = 0, v_counter = 0;

    // Parameters
    localparam H_ACTIVE_CNT = 640;
    localparam H_FRONT_CNT = 16;
    localparam H_PULSE_CNT = 96;
    localparam H_BACK_CNT = 48;

    localparam V_ACTIVE_CNT = 480;
    localparam V_FRONT_CNT = 10;
    localparam V_PULSE_CNT = 2;
    localparam V_BACK_CNT = 33;

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            h_state <= H_ACTIVE;
            v_state <= V_ACTIVE;
            h_counter <= 0;
            v_counter <= 0;
            line_done <= 1'b0;
            sync <= 1'b0;
            blank <= 1'b0;
        end else begin
            case (h_state)
                H_ACTIVE: begin
                    if (h_counter == H_ACTIVE_CNT) begin
                        h_state <= H_FRONT;
                        line_done <= 1'b0;
                    end else begin
                        h_counter <= h_counter + 1;
                    end
                end
                H_FRONT: begin
                    if (h_counter == H_FRONT_CNT) begin
                        h_state <= H_PULSE;
                        line_done <= 1'b0;
                    end else begin
                        h_counter <= h_counter + 1;
                    end
                end
                H_PULSE: begin
                    if (h_counter == H_PULSE_CNT) begin
                        h_state <= H_BACK;
                        line_done <= 1'b0;
                    end else begin
                        h_counter <= h_counter + 1;
                    end
                end
                H_BACK: begin
                    if (h_counter == H_BACK_CNT) begin
                        h_state <= H_ACTIVE;
                        line_done <= 1'b0;
                    end else begin
                        h_counter <= h_counter + 1;
                    end
                end
                default: h_state <= H_ACTIVE;
            endcase

            case (v_state)
                V_ACTIVE: begin
                    if (v_counter == V_ACTIVE_CNT) begin
                        v_state <= V_FRONT;
                        next_y <= next_y + 1;
                    end else begin
                        v_counter <= v_counter + 1;
                    end
                end
                V_FRONT: begin
                    if (v_counter == V_FRONT_CNT) begin
                        v_state <= V_PULSE;
                        next_x <= next_x + 1;
                    end else begin
                        v_counter <= v_counter + 1;
                    end
                end
                V_PULSE: begin
                    if (v_counter == V_PULSE_CNT) begin
                        v_state <= V_BACK;
                        next_y <= next_y + 1;
                    end else begin
                        v_counter <= v_counter + 1;
                    end
                end
                V_BACK: begin
                    if (v_counter == V_BACK_CNT) begin
                        v_state <= V_ACTIVE;
                        next_x <= next_x + 1;
                    end else begin
                        v_counter <= v_counter + 1;
                    end
                end
                default: v_state <= V_ACTIVE;
            endcase
        end

        // RGB signal assignment
        always_comb begin
            if (h_state == H_ACTIVE || v_state == V_ACTIVE) begin
                red <= color_in[7:5];
                green <= color_in[4:2];
                blue <= color_in[1:0];
            end else begin
                red <= 8'd0;
                green <= 8'd0;
                blue <= 8'd0;
            end
        end

        // Sync signal assignment
        always_comb begin
            sync <= 1'b0;
            if (h_state == H_PULSE || v_state == V_PULSE) begin
                sync <= 1'b1;
            end

        // Blanking signal logic
        always_comb begin
            blank <= hsync | vsync;
        end
    endmodule

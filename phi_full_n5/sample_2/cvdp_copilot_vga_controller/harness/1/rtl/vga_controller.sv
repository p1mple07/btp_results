module vga_controller(
    input clk,
    input reset,
    input [7:0] color_in,
    output reg hsync,
    output reg vsync,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue,
    output [9:0] next_x,
    output [9:0] next_y,
    output sync,
    output reg clk_in
);

    // State definitions
    typedef enum logic [1:0] {
        H_ACTIVE,
        H_FRONT,
        H_PULSE,
        H_BACK
    } horizontal_state_t;

    typedef enum logic [1:0] {
        V_ACTIVE,
        V_FRONT,
        V_PULSE,
        V_BACK
    } vertical_state_t;

    // State machine for horizontal timing
    always_ff @(posedge clk) begin
        if (reset) begin
            h_counter <= 9'b0;
            horizontal_state_t h_state = H_ACTIVE;
        end else begin
            case (horizontal_state_t)
                H_ACTIVE: if (h_counter == 640) begin
                              h_state = H_FRONT;
                              h_counter <= 16;
                          end else begin
                              h_counter <= h_counter + 1;
                              h_state = H_ACTIVE;
                          end
                H_FRONT: h_state = H_PULSE;
                H_PULSE: if (h_counter == 96) begin
                              h_state = H_BACK;
                              h_counter <= 48;
                          end else begin
                              h_counter <= h_counter + 1;
                              h_state = H_PULSE;
                          end
                H_BACK: h_state = H_FRONT;
            endcase
        end
    end

    // State machine for vertical timing
    always_ff @(posedge clk) begin
        if (reset) begin
            v_counter <= 10'b0;
            vertical_state_t v_state = V_ACTIVE;
        end else begin
            case (vertical_state_t)
                V_ACTIVE: if (v_counter == 480) begin
                                v_state = V_FRONT;
                                v_counter <= 10;
                            end else begin
                                v_counter <= v_counter + 1;
                                v_state = V_ACTIVE;
                            end
                V_FRONT: v_state = V_PULSE;
                V_PULSE: if (v_counter == 482) begin
                                v_state = V_BACK;
                                v_counter <= 33;
                            end else begin
                                v_counter <= v_counter + 1;
                                v_state = V_PULSE;
                            end
                V_BACK: v_state = V_ACTIVE;
            endcase
        end
    end

    // RGB output logic
    always @* begin
        if (h_state == H_ACTIVE && v_state == V_ACTIVE) begin
            next_x <= h_counter;
            next_y <= v_counter;
            red <= color_in[7:5];
            green <= color_in[4:2];
            blue <= color_in[1:0];
        end else begin
            next_x <= 9'b0;
            next_y <= 9'b0;
            red <= 8'd0;
            green <= 8'd0;
            blue <= 8'd0;
        end
    end

    // Sync signal generation
    always @* begin
        if (h_state == H_PULSE || v_state == V_PULSE) begin
            hsync = 1'b0;
            vsync = 1'b0;
        end else begin
            hsync = 1'b1;
            vsync = 1'b1;
        end
    end

    // Display blanking control
    always @(reset or hsync or vsync) begin
        sync = hsync | vsync;
    end

endmodule

module vga_controller (
    input clk,
    input reset,
    input [7:0] color_in,
    output reg hsync,
    output reg vsync,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue,
    output reg [9:0] next_x,
    output [9:0] next_y,
    output reg sync,
    output reg clk_out,
    output reg blank
);

    // Counter and signal initialization
    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;
    reg line_done = 0;

    // State definitions
    localparam H_ACTIVE = 640;
    localparam H_FRONT = 16;
    localparam H_PULSE = 96;
    localparam H_BACK = 48;

    localparam V_ACTIVE = 480;
    localparam V_FRONT = 10;
    localparam V_PULSE = 2;
    localparam V_BACK = 33;

    // State machines
    always @(posedge clk) begin
        if (reset) begin
            h_counter <= 0;
            v_counter <= 0;
            line_done <= 0;
        end else begin
            case (h_counter)
                H_ACTIVE: begin
                    // Active state logic
                    if (h_counter == H_ACTIVE - 1) begin
                        hsync <= ~hsync; // Toggle hsync
                        h_counter <= 0;
                        if (h_counter == H_FRONT - 1) begin
                            line_done <= 1;
                        end
                    end
                end
                H_FRONT: begin
                    // Front porch logic
                    if (h_counter == H_FRONT - 1) begin
                        line_done <= 0;
                    end
                end
                H_PULSE: begin
                    // Horizontal sync pulse logic
                    if (h_counter == H_PULSE - 1) begin
                        hsync <= ~hsync;
                        h_counter <= 0;
                    end
                end
                H_BACK: begin
                    // Back porch logic
                    if (h_counter == H_BACK - 1) begin
                        hsync <= ~hsync;
                        h_counter <= 0;
                    end
                end
            endcase

            case (v_counter)
                V_ACTIVE: begin
                    // Active state logic
                    if (v_counter == V_ACTIVE - 1) begin
                        vsync <= ~vsync; // Toggle vsync
                        v_counter <= 0;
                    end
                end
                V_FRONT: begin
                    // Vertical front porch logic
                    if (v_counter == V_FRONT - 1) begin
                        vsync <= ~vsync;
                    end
                end
                V_PULSE: begin
                    // Vertical sync pulse logic
                    if (v_counter == V_PULSE - 1) begin
                        vsync <= ~vsync;
                    end
                end
                V_BACK: begin
                    // Vertical back porch logic
                    if (v_counter == V_BACK - 1) begin
                        vsync <= ~vsync;
                    end
                end
            endcase
        end
    end

    // Color output logic
    always @(posedge clk) begin
        if (line_done) begin
            red <= color_in[7:5];
            green <= color_in[4:2];
            blue <= color_in[1:0];
        end else begin
            red <= 8'b0;
            green <= 8'b0;
            blue <= 8'b0;
        end
    end

    // Sync and blanking control logic
    always @(posedge clk) begin
        sync <= 0; // Fixed to LOW as per design
        blank <= (hsync && vsync);
    end

endmodule
rtl/vga_controller.sv

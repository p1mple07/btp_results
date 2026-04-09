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

    // State and counter declarations
    typedef enum logic [1:0] {
        H_ACTIVE,
        H_FRONT,
        H_PULSE,
        H_BACK
    } h_state_t;
    
    logic [9:0] h_counter;
    logic [9:0] v_counter;
    
    // State machine and timing parameters
    logic [2:0] h_state, v_state;
    localparam H_ACTIVE_TIME = 640;
    localparam H_FRONT_TIME = 16;
    localparam H_PULSE_TIME = 96;
    localparam H_BACK_TIME = 48;
    localparam V_ACTIVE_LINES = 480;
    localparam V_FRONT_LINES = 10;
    localparam V_PULSE_LINES = 2;
    localparam V_BACK_LINES = 33;
    
    // State transition logic
    always_ff @(posedge clk) begin
        case (h_state)
            H_ACTIVE: begin
                if (reset) begin
                    h_counter <= 0;
                    h_state <= H_ACTIVE;
                    line_done <= 0;
                end else begin
                    h_counter <= h_counter + 1;
                    if (h_counter >= H_ACTIVE_TIME) begin
                        h_state <= H_FRONT;
                    end
                end
            end
            H_FRONT: begin
                if (h_counter >= H_FRONT_TIME) begin
                    h_state <= H_PULSE;
                end
            end
            H_PULSE: begin
                if (h_counter >= H_PULSE_TIME) begin
                    h_state <= H_BACK;
                end
            end
            H_BACK: begin
                if (h_counter >= H_BACK_TIME) begin
                    h_state <= H_ACTIVE;
                    line_done <= 1;
                end
            end
        endcase
        
        case (v_state)
            V_ACTIVE: begin
                if (reset) begin
                    v_counter <= 0;
                    v_state <= V_ACTIVE;
                end else begin
                    v_counter <= v_counter + 1;
                    if (v_counter >= V_ACTIVE_LINES) begin
                        v_state <= V_FRONT;
                    end
                end
            end
            V_FRONT: begin
                if (v_counter >= V_FRONT_LINES) begin
                    v_state <= V_PULSE;
                end
            end
            V_PULSE: begin
                if (v_counter >= V_PULSE_LINES) begin
                    v_state <= V_BACK;
                end
            end
            V_BACK: begin
                if (v_counter >= V_BACK_LINES) begin
                    v_state <= V_ACTIVE;
                end
            end
        endcase
    end
    
    // Color output logic
    always_ff @(posedge clk) begin
        if (h_state == H_ACTIVE) begin
            red <= color_in[7:5];
            green <= color_in[4:2];
            blue <= color_in[1:0];
        end else begin
            red <= 8'b0;
            green <= 8'b0;
            blue <= 8'b0;
        end
        
        if (v_state == V_ACTIVE) begin
            next_x <= h_counter;
            next_y <= v_counter;
        end else {
            next_x <= 0;
            next_y <= 0;
        }
    end
    
    // Sync and blanking logic
    always_ff @(posedge clk) begin
        sync <= 1'b0; // Fixed to LOW as per design
        blank <= hsync | vsync;
    end
    
endmodule

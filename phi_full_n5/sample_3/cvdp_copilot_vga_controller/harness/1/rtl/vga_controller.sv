module vga_controller (
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
    output clk_sync,
    output blank
);

    // State and counter definitions
    typedef enum logic [1:0] {H_ACTIVE, H_FRONT, H_PULSE, H_BACK, V_ACTIVE, V_FRONT, V_PULSE, V_BACK} h_state_t;
    typedef enum logic [1:0] {V_ACTIVE, V_FRONT, V_PULSE, V_BACK} v_state_t;
    logic [9:0] h_counter = 0;
    logic [9:0] v_counter = 0;

    // State machine for horizontal timing
    always_ff @(posedge clk) begin
        case (h_state_t)
            H_ACTIVE: begin
                h_counter <= h_counter + 1'b1;
                if (h_counter == H_ACTIVE) begin
                    h_state_t = H_FRONT;
                end
            end
            H_FRONT: begin
                if (h_counter == H_FRONT) begin
                    h_state_t = H_PULSE;
                end
            end
            H_PULSE: begin
                if (h_counter == H_PULSE) begin
                    h_state_t = H_BACK;
                end
            end
            H_BACK: begin
                if (h_counter == H_BACK) begin
                    h_state_t = H_ACTIVE;
                end
            end
        endcase
    end

    // State machine for vertical timing
    always_ff @(posedge clk) begin
        case (v_state_t)
            V_ACTIVE: begin
                v_counter <= v_counter + 1'b1;
                if (v_counter == V_ACTIVE) begin
                    v_state_t = V_FRONT;
                end
            end
            V_FRONT: begin
                if (v_counter == V_FRONT) begin
                    v_state_t = V_PULSE;
                end
            end
            V_PULSE: begin
                if (v_counter == V_PULSE) begin
                    v_state_t = V_BACK;
                end
            end
            V_BACK: begin
                if (v_counter == V_BACK) begin
                    v_state_t = V_ACTIVE;
                end
            end
        endcase
    end

    // Synchronization signals
    always_ff begin
        sync <= 1'b0;
        hsync <= 1'b0;
        vsync <= 1'b0;
        blank <= 1'b1;
    end

    // Sync pulse generation
    always_ff begin
        if (h_state_t == H_PULSE) begin
            hsync <= 1'b1;
        end else if (h_state_t == H_BACK) begin
            hsync <= 1'b0;
        end
    end

    always_ff begin
        if (v_state_t == V_PULSE) begin
            vsync <= 1'b1;
        end else if (v_state_t == V_BACK) begin
            vsync <= 1'b0;
        end
    end

    // Color output control
    always_ff begin
        if (h_state_t == H_ACTIVE) begin
            next_x <= h_counter;
            red <= color_in[7:5];
            green <= color_in[4:2];
            blue <= color_in[1:0];
        end else begin
            next_x <= 0;
            red <= 8'd0;
            green <= 8'd0;
            blue <= 8'd0;
        end
    end

    // Blanking signal control
    always_ff begin
        if (h_state_t == H_BACK || v_state_t == V_BACK) begin
            blank <= 1'b1;
        end else begin
            blank <= 1'b0;
        end
    end

    // Reset logic
    always_ff begin
        if (reset) begin
            h_counter <= 10'b0;
            v_counter <= 10'b0;
            next_x <= 10'b0;
            next_y <= 10'b0;
            sync <= 1'b0;
            hsync <= 1'b0;
            vsync <= 1'b0;
            blank <= 1'b0;
        end
    end

endmodule

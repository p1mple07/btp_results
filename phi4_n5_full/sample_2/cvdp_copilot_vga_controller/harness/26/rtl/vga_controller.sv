module vga_controller (
    input  logic        clock,
    input  logic        reset,
    input  logic [7:0]  color_in,
    output logic [9:0]  next_x,
    output logic [9:0]  next_y,
    output logic        hsync,
    output logic        vsync,
    output logic [7:0]  red,
    output logic [7:0]  green,
    output logic [7:0]  blue,
    output logic        sync,
    output logic        clk,
    output logic        blank,
    output logic [7:0]  h_state,
    output logic [7:0]  v_state
);

  // Parameters for timing and state encoding
  parameter logic [9:0] H_ACTIVE  = 10'd640;
  parameter logic [9:0] H_FRONT   = 10'd16;
  parameter logic [9:0] H_PULSE   = 10'd96;
  parameter logic [9:0] H_BACK    = 10'd48;
  parameter logic [9:0] V_ACTIVE  = 10'd480;
  parameter logic [9:0] V_FRONT   = 10'd10;
  parameter logic [9:0] V_PULSE   = 10'd2;
  parameter logic [9:0] V_BACK    = 10'd33;
  parameter logic        LOW   = 1'b0;
  parameter logic        HIGH  = 1'b1;
  parameter logic [7:0]  H_ACTIVE_STATE  = 8'd0;
  parameter logic [7:0]  H_FRONT_STATE   = 8'd1;
  parameter logic [7:0]  H_PULSE_STATE   = 8'd2;
  parameter logic [7:0]  H_BACK_STATE    = 8'd3;
  parameter logic [7:0]  V_ACTIVE_STATE  = 8'd0;
  parameter logic [7:0]  V_FRONT_STATE   = 8'd1;
  parameter logic [7:0]  V_PULSE_STATE   = 8'd2;
  parameter logic [7:0]  V_BACK_STATE    = 8'd3;

  // Internal signals for counters and intermediate next values
  logic            line_done;
  logic [9:0]      h_counter;
  logic [9:0]      v_counter;
  logic [9:0]      next_h;
  logic [9:0]      next_v;

  // Combined sequential logic for horizontal and vertical FSMs.
  // Note: hsync and vsync are computed combinational to reduce multiplexing overhead.
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      h_counter   <= 10'd0;
      v_counter   <= 10'd0;
      h_state     <= H_ACTIVE_STATE;
      v_state     <= V_ACTIVE_STATE;
      line_done   <= LOW;
    end
    else begin
      // Horizontal FSM update using an intermediate signal to avoid redundant expressions
      case (h_state)
        H_ACTIVE_STATE: begin
          next_h = (h_counter == H_ACTIVE - 1) ? 10'd0 : h_counter + 10'd1;
          h_state   <= (h_counter == H_ACTIVE - 1) ? H_FRONT_STATE : H_ACTIVE_STATE;
          line_done <= LOW;
        end
        H_FRONT_STATE: begin
          next_h = (h_counter == H_FRONT - 1) ? 10'd0 : h_counter + 10'd1;
          h_state   <= (h_counter == H_FRONT - 1) ? H_PULSE_STATE : H_FRONT_STATE;
        end
        H_PULSE_STATE: begin
          next_h = (h_counter == H_PULSE - 1) ? 10'd0 : h_counter + 10'd1;
          h_state   <= (h_counter == H_PULSE - 1) ? H_BACK_STATE : H_PULSE_STATE;
        end
        H_BACK_STATE: begin
          next_h = (h_counter == H_BACK - 1) ? 10'd0 : h_counter + 10'd1;
          h_state   <= (h_counter == H_BACK - 1) ? H_ACTIVE_STATE : H_BACK_STATE;
          line_done <= (h_counter == H_BACK - 1) ? HIGH : LOW;
        end
      endcase
      h_counter <= next_h;

      // Vertical FSM update is performed only when a horizontal line is complete.
      if (line_done) begin
        case (v_state)
          V_ACTIVE_STATE: begin
            next_v = (v_counter == V_ACTIVE - 1) ? 10'd0 : v_counter + 10'd1;
            v_state   <= (v_counter == V_ACTIVE - 1) ? V_FRONT_STATE : V_ACTIVE_STATE;
          end
          V_FRONT_STATE: begin
            next_v = (v_counter == V_FRONT - 1) ? 10'd0 : v_counter + 10'd1;
            v_state   <= (v_counter == V_FRONT - 1) ? V_PULSE_STATE : V_FRONT_STATE;
          end
          V_PULSE_STATE: begin
            next_v = (v_counter == V_PULSE - 1) ? 10'd0 : v_counter + 10'd1;
            v_state   <= (v_counter == V_PULSE - 1) ? V_BACK_STATE : V_PULSE_STATE;
          end
          V_BACK_STATE: begin
            next_v = (v_counter == V_BACK - 1) ? 10'd0 : v_counter + 10'd1;
            v_state   <= (v_counter == V_BACK - 1) ? V_ACTIVE_STATE : V_BACK_STATE;
          end
        endcase
        v_counter <= next_v;
      end
    end
  end

  // Combinational assignments for sync outputs.
  // Moving these out of the sequential block reduces the number of cells and wires.
  assign hsync = (h_state != H_PULSE_STATE) ? HIGH : LOW;
  assign vsync = (v_state != V_PULSE_STATE) ? HIGH : LOW;

  // Color outputs remain synchronous to preserve 1-cycle latency.
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      red   <= 8'd0;
      green <= 8'd0;
      blue  <= 8'd0;
    end
    else begin
      if (h_state == H_ACTIVE_STATE && v_state == V_ACTIVE_STATE) begin
        red   <= {color_in[7:5], 5'd0};
        green <= {color_in[4:2], 5'd0};
        blue  <= {color_in[1:0], 6'd0};
      end
      else begin
        red   <= 8'd0;
        green <= 8'd0;
        blue  <= 8'd0;
      end
    end
  end

  // Other assignments remain unchanged.
  assign clk    = clock;
  assign sync   = 1'b0;
  assign blank  = hsync & vsync;
  assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
  assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule
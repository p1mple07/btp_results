module tb_vga_controller;

  
  parameter CLOCK_PERIOD_NS = 40;  // 25 MHz clock
  
  // Inputs
  logic clock;
  logic reset;
  logic [7:0] color_in;

  // Outputs
  logic [9:0] next_x;
  logic [9:0] next_y;
  logic hsync;
  logic vsync;
  logic [7:0] red;
  logic [7:0] green;
  logic [7:0] blue;
  logic blank;

  
  int hsync_cycles = 96;
  int h_back_porch_cycles = 48;
  int h_active_pixels = 640;
  int h_front_porch_cycles = 16;
  
  int vsync_lines = 2;
  int v_back_porch_lines = 33;
  int v_active_lines = 480;
  int v_front_porch_lines = 10;

  
  logic h_in_active_region, h_in_front_porch, h_in_sync_pulse, h_in_back_porch;
  logic v_in_active_region, v_in_front_porch, v_in_sync_pulse, v_in_back_porch;

  
  vga_controller dut (
    .clock(clock),
    .reset(reset),
    .color_in(color_in),
    .next_x(next_x),
    .next_y(next_y),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue),
    .blank(blank)
  );

  
  initial begin
    clock = 0;
    forever #(CLOCK_PERIOD_NS / 2) clock = ~clock;
  end

  
  initial begin
    $dumpfile("vga_controller_timing.vcd");
    $dumpvars(0, tb_vga_controller);
  end

  
  integer cycle_count = 0;
  integer line_count = 0;

  
  always_ff @(posedge clock) begin
    
    h_in_active_region <= (cycle_count < h_active_pixels);
    h_in_front_porch   <= (cycle_count >= h_active_pixels) && (cycle_count < h_active_pixels + h_front_porch_cycles);
    h_in_sync_pulse    <= (cycle_count >= h_active_pixels + h_front_porch_cycles) && (cycle_count < h_active_pixels + h_front_porch_cycles + hsync_cycles);
    h_in_back_porch    <= (cycle_count >= h_active_pixels + h_front_porch_cycles + hsync_cycles) && (cycle_count < h_active_pixels + h_front_porch_cycles + hsync_cycles + h_back_porch_cycles);

    
    if (cycle_count == 0)
      $display("[%0t] Horizontal Phase: Active Region started.", $time);
    else if (cycle_count == h_active_pixels)
      $display("[%0t] Horizontal Phase: Front Porch started.", $time);
    else if (cycle_count == h_active_pixels + h_front_porch_cycles)
      $display("[%0t] Horizontal Phase: Sync Pulse started.", $time);
    else if (cycle_count == h_active_pixels + h_front_porch_cycles + hsync_cycles)
      $display("[%0t] Horizontal Phase: Back Porch started.", $time);

    
    if (cycle_count == h_active_pixels + h_front_porch_cycles + hsync_cycles + h_back_porch_cycles - 1) begin
      $display("[%0t] Horizontal Line completed.", $time);
    end

    
    v_in_active_region <= (line_count < v_active_lines);
    v_in_front_porch   <= (line_count >= v_active_lines) && (line_count < v_active_lines + v_front_porch_lines);
    v_in_sync_pulse    <= (line_count >= v_active_lines + v_front_porch_lines) && (line_count < v_active_lines + v_front_porch_lines + vsync_lines);
    v_in_back_porch    <= (line_count >= v_active_lines + v_front_porch_lines + vsync_lines) && (line_count < v_active_lines + v_front_porch_lines + vsync_lines + v_back_porch_lines);

    
    if (cycle_count == 0 && line_count == 0)
      $display("[%0t] Vertical Phase: Active Region started.", $time);
    else if (line_count == v_active_lines && cycle_count == 0)
      $display("[%0t] Vertical Phase: Front Porch started.", $time);
    else if (line_count == v_active_lines + v_front_porch_lines && cycle_count == 0)
      $display("[%0t] Vertical Phase: Sync Pulse started.", $time);
    else if (line_count == v_active_lines + v_front_porch_lines + vsync_lines && cycle_count == 0)
      $display("[%0t] Vertical Phase: Back Porch started.", $time);

    
    cycle_count += 1;
    if (cycle_count == h_active_pixels + h_front_porch_cycles + hsync_cycles + h_back_porch_cycles) begin
      cycle_count = 0;
      line_count += 1;

      
      if (line_count == v_active_lines + v_front_porch_lines + vsync_lines + v_back_porch_lines) begin
        line_count = 0;
        $display("[%0t] One Vertical Frame completed.", $time);
      end
    end
  end

  
  initial begin
    reset = 1;
    #50;
    reset = 0;
    $display("[%0t] Reset released.", $time);
  end

  
  initial begin
    color_in = 8'hAA;  
    repeat (10) @(posedge clock); 
    $display("[%0t] Starting color output tests.", $time);

    
    forever begin
      color_in = color_in + 8'h11;
      @(posedge clock);
    end
  end

  
  initial begin
    #16800000;
    $display("[%0t] Simulation complete.", $time);
    $finish;
  end

endmodule

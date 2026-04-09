module glitch_free_mux
(
    input         clk1,    // asynchronous clock 1
    input         clk2,    // asynchronous clock 2
    input         rst_n,   // asynchronous reset (active low)
    input         sel,     // selection signal: 0 => use clk1, 1 => use clk2
    output        clkout   // glitch‐free output clock
);

  //-------------------------------------------------------------------------
  // Local enable signals (generated in each clock domain)
  //-------------------------------------------------------------------------
  // clk1_enable_local is generated in clk1 domain and used to gate clk1.
  // clk2_enable_local is generated in clk2 domain and used to gate clk2.
  reg clk1_enable_local;
  reg clk2_enable_local;

  //-------------------------------------------------------------------------
  // Synchronizers for cross–domain signals
  //-------------------------------------------------------------------------
  // Synchronizer for clk1_enable (launched on clk1, captured on clk2)
  reg clk1_enable_sync_ff0, clk1_enable_sync_ff1;
  // This signal is driven in clk1 domain and then synchronized in clk2.
  reg clk1_enable_sync_input;

  // Synchronizer for clk2_enable (launched on clk2, captured on clk1)
  reg clk2_enable_sync_ff0, clk2_enable_sync_ff1;
  // This signal is driven in clk2 domain and then synchronized in clk1.
  reg clk2_enable_sync_input;

  // Synchronizer for sel in clk2 domain.
  // (Assume that sel is synchronous to clk1 so that in clk2 it is asynchronous.)
  reg sel_sync_ff0_clk2, sel_sync_ff1_clk2;
  // This signal is driven in clk2 domain.
  reg sel_sync_input_clk2;

  //-------------------------------------------------------------------------
  // Clock domain 1: clk1 domain
  //-------------------------------------------------------------------------
  // Generate clk1_enable_local using the synchronized version of clk2_enable.
  // When sel is 0, clk1_enable_local is high; when sel is 1, it is disabled.
  always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
      clk1_enable_local      <= 1'b0;
      clk1_enable_sync_input <= 1'b0;
    end else begin
      // Use direct sel (assumed synchronous in clk1) and the synchronized version
      // of clk2_enable (from clk2 domain) to generate clk1_enable_local.
      clk1_enable_local      <= ~clk2_enable_sync_ff1 & ~sel;
      clk1_enable_sync_input <= clk1_enable_local;
    end
  end

  //-------------------------------------------------------------------------
  // Clock domain 2: clk2 domain
  //-------------------------------------------------------------------------
  // Generate clk2_enable_local using the synchronized version of clk1_enable
  // and a two–flop synchronizer for sel in clk2.
  always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
      clk2_enable_local      <= 1'b0;
      clk2_enable_sync_input <= 1'b0;
      sel_sync_input_clk2    <= 1'b0;
    end else begin
      // Capture sel in clk2 domain (since sel is asynchronous here).
      sel_sync_input_clk2    <= sel;
      // Use the synchronized version of sel (after two flops) together with
      // the synchronized clk1_enable (from clk1 domain) to generate clk2_enable_local.
      clk2_enable_local      <= ~clk1_enable_sync_ff1 & sel_sync_ff1_clk2;
      clk2_enable_sync_input <= clk2_enable_local;
    end
  end

  //-------------------------------------------------------------------------
  // Synchronizer: clk1_enable from clk1 to clk2 domain
  //-------------------------------------------------------------------------
  always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
      clk1_enable_sync_ff0 <= 1'b0;
      clk1_enable_sync_ff1 <= 1'b0;
    end else begin
      clk1_enable_sync_ff0 <= clk1_enable_sync_input;
      clk1_enable_sync_ff1 <= clk1_enable_sync_ff0;
    end
  end

  //-------------------------------------------------------------------------
  // Synchronizer: clk2_enable from clk2 to clk1 domain
  //-------------------------------------------------------------------------
  always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
      clk2_enable_sync_ff0 <= 1'b0;
      clk2_enable_sync_ff1 <= 1'b0;
    end else begin
      clk2_enable_sync_ff0 <= clk2_enable_sync_input;
      clk2_enable_sync_ff1 <= clk2_enable_sync_ff0;
    end
  end

  //-------------------------------------------------------------------------
  // Synchronizer: sel in clk2 domain
  //-------------------------------------------------------------------------
  always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
      sel_sync_ff0_clk2 <= 1'b0;
      sel_sync_ff1_clk2 <= 1'b0;
    end else begin
      sel_sync_ff0_clk2 <= sel_sync_input_clk2;
      sel_sync_ff1_clk2 <= sel_sync_ff0_clk2;
    end
  end

  //-------------------------------------------------------------------------
  // Output Logic: Glitch-free clock muxing
  //-------------------------------------------------------------------------
  // The output clock is formed by ORing the gated clocks.
  // When sel = 0, clk1_enable_local is high so clk1 drives clkout.
  // When sel = 1, clk2_enable_local is high so clk2 drives clkout.
  // The two–flop synchronizers ensure that the enable signals cross domains
  // without metastability and that switching occurs on the second edge after sel changes.
  assign clkout = (clk1 & clk1_enable_local) | (clk2 & clk2_enable_local);

endmodule
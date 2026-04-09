module glitch_free_mux
(
    input         clk1,    // asynchronous source clock 1
    input         clk2,    // asynchronous source clock 2
    input         rst_n,   // asynchronous reset, active low
    input         sel,     // selection signal: 0 => use clk1; 1 => use clk2
    output        clkout   // glitch‐free clock output
);

  //-------------------------------------------------------------------------
  // Internal enable signals generated in each clock domain with a two‐cycle
  // delay on transitions. These signals implement the original logic:
  //   clk1_enable = (~clk2_enable & ~sel)
  //   clk2_enable = (~clk1_enable & sel)
  // However, because clk1 and clk2 are now asynchronous, we use two‐flop
  // synchronizers for crossing the enable signals between domains.
  //-------------------------------------------------------------------------

  // Registers for the enable signals in each domain
  reg clk1_enable_reg;
  reg clk2_enable_reg;

  //--------------------------------------------------------------------------
  // clk1 domain state machine for generating clk1_enable_reg.
  // The desired value is:
  //   If sel = 0 then desired clk1_enable = 1 if the synchronized version
  //     of clk2_enable (clk2_enable_sync) is 0; otherwise 0.
  //   If sel = 1 then desired clk1_enable = 0.
  //
  // A two-cycle delay is applied on transitions of sel.
  //--------------------------------------------------------------------------
  reg state1;    // state: 0 = IDLE, 1 = DELAY
  reg sel_prev1; // previous value of sel (in clk1 domain; sel is assumed synchronous here)
  reg new_val1;  // computed desired value for clk1_enable

  always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
      clk1_enable_reg <= 1'b0;
      state1          <= 1'b0;
      sel_prev1       <= 1'b0;
    end else begin
      if (state1 == 1'b0) begin
        if (sel != sel_prev1) begin
          // Compute desired value:
          // When sel=1: clk1_enable should be 0.
          // When sel=0: clk1_enable should be 1 only if the synchronized
          // version of clk2_enable (clk2_enable_sync) is 0.
          new_val1 = (sel ? 1'b0 : (~clk2_enable_sync ? 1'b1 : 1'b0));
          state1 <= 1'b1; // move to DELAY state
        end
      end else begin
        clk1_enable_reg <= new_val1;
        state1 <= 1'b0;  // return to IDLE
      end
      sel_prev1 <= sel;
    end
  end

  //--------------------------------------------------------------------------
  // clk2 domain state machine for generating clk2_enable_reg.
  // The desired value is:
  //   If sel (synchronized to clk2 domain) = 1 then desired clk2_enable = 1
  //     if the synchronized version of clk1_enable (clk1_enable_sync) is 0;
  //     otherwise 0.
  //   If sel = 0 then desired clk2_enable = 0.
  //
  // A two-cycle delay is applied on transitions of sel (synchronized version).
  //--------------------------------------------------------------------------
  reg state2;    // state: 0 = IDLE, 1 = DELAY
  reg sel_prev2; // previous value of sel_sync in clk2 domain
  reg new_val2;  // computed desired value for clk2_enable

  always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
      clk2_enable_reg <= 1'b0;
      state2          <= 1'b0;
      sel_prev2       <= 1'b0;
    end else begin
      if (state2 == 1'b0) begin
        if (sel_sync != sel_prev2) begin
          // Compute desired value:
          // When sel_sync=1: clk2_enable should be 1 if clk1_enable_sync is 0.
          // When sel_sync=0: clk2_enable should be 0.
          new_val2 = (sel_sync ? (~clk1_enable_sync ? 1'b1 : 1'b0) : 1'b0);
          state2 <= 1'b1;
        end
      end else begin
        clk2_enable_reg <= new_val2;
        state2 <= 1'b0;
      end
      sel_prev2 <= sel_sync;
    end
  end

  //-------------------------------------------------------------------------
  // Synchronizers for crossing signals between clock domains.
  //-------------------------------------------------------------------------

  // Synchronize sel into the clk2 domain (2‐flop synchronizer)
  reg sel_sync;
  reg sel_sync_d;
  always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
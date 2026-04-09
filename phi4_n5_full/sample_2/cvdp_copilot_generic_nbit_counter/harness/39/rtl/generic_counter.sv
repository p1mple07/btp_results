module generic_counter #(parameter N = 8) (
    input  logic         clk_in,          
    input  logic         rst_in,          
    input  logic [2:0]   mode_in,         
    input  logic         enable_in,       
    input  logic [N-1:0] ref_modulo,      
    output logic [N-1:0] o_count          
);

  // Mode definitions
  parameter BINARY_UP   = 3'b000;
  parameter BINARY_DOWN = 3'b001;
  parameter MODULO_N    = 3'b010;
  parameter JOHNSON     = 3'b011;
  parameter GRAY        = 3'b100;
  parameter RING        = 3'b101;

  // Counters for each mode
  logic [N-1:0] count_bin_up;
  logic [N-1:0] count_bin_down;
  logic [N-1:0] count_modulo;
  logic [N-1:0] count_johnson;
  logic [N-1:0] count_gray;
  logic [N-1:0] count_ring;

  // ---------------------------------------------------------------------
  // Combined always_ff block to update all counters concurrently.
  // This reduces the overhead of multiple clocked blocks while keeping
  // the one-cycle latency and functional equivalence.
  // ---------------------------------------------------------------------
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      count_bin_up     <= {N{1'b0}};
      count_bin_down   <= {N{1'b0}};
      count_modulo     <= {N{1'b0}};
      count_johnson    <= {N{1'b0}};
      count_gray       <= {N{1'b0}};
      count_ring       <= {N{1'b0}};
    end
    else begin
      // BINARY_UP: Increment on enable
      if (enable_in)
        count_bin_up <= count_bin_up + 1;
      
      // BINARY_DOWN: Decrement on enable
      if (enable_in)
        count_bin_down <= count_bin_down - 1;
      
      // MODULO_N: Increment and wrap-around on reaching ref_modulo
      if (enable_in)
        count_modulo <= (count_modulo == ref_modulo) ? {N{1'b0}} : count_modulo + 1;
      
      // JOHNSON: Rotate with bit inversion at bit0
      if (enable_in)
        count_johnson <= {~count_johnson[0], count_johnson[N-1:1]};
      
      // GRAY: Simple binary counter (internal count)
      if (enable_in)
        count_gray <= count_gray + 1;
      
      // RING: Rotate right (circular bit shift)
      if (enable_in)
        count_ring <= (count_ring == {N{1'b0}}) 
                      ? {{(N-1){1'b0}}, 1'b1} 
                      : {count_ring[N-2:0], count_ring[N-1]};
    end
  end

  // ---------------------------------------------------------------------
  // Function-based multiplexer to select the output counter.
  // Using a function helps synthesis tools optimize the combinational
  // logic, reducing both cell and wire overhead.
  // ---------------------------------------------------------------------
  function automatic logic [N-1:0] mux_sel(input logic [2:0] mode);
    case (mode)
      BINARY_UP:   mux_sel = count_bin_up;
      BINARY_DOWN: mux_sel = count_bin_down;
      MODULO_N:    mux_sel = count_modulo;
      JOHNSON:     mux_sel = count_johnson;
      GRAY:        mux_sel = count_gray ^ (count_gray >> 1);
      RING:        mux_sel = count_ring;
      default:     mux_sel = {N{1'b0}};
    endcase
  endfunction

  // Output assignment with one-cycle latency
  assign o_count = mux_sel(mode_in);

endmodule
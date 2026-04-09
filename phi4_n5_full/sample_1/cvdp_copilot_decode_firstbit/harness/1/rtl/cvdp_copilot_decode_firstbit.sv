module cvdp_copilot_decode_firstbit (
  input  logic                  Clk,
  input  logic                  Rst,
  input  logic [InWidth_g-1:0]  In_Data,
  input  logic                  In_Valid,
  output logic [$clog2(InWidth_g)-1:0] Out_FirstBit,
  output logic                  Out_Found,
  output logic                  Out_Valid
);

  // Parameters
  parameter int InWidth_g = 32;
  parameter bit   InReg_g  = 1;
  parameter bit   OutReg_g = 1;
  parameter int   PlRegs_g = 1;

  // Calculate the number of bits required to encode the index of the first set bit.
  localparam int BinBits_c = $clog2(InWidth_g);

  // Determine the padded width: if InWidth_g is not a power of two, pad it to the next power of two.
  localparam int PaddedWidth = (InWidth_g == (1 << BinBits_c)) ? InWidth_g : (1 << (BinBits_c+1));

  //-------------------------------------------------------------------------
  // Input registration (if enabled)
  //-------------------------------------------------------------------------
  reg [InWidth_g-1:0] data_reg;
  reg                  in_valid_reg;

  always_ff @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      data_reg     <= '0;
      in_valid_reg <= 1'b0;
    end
    else if (InReg_g) begin
      data_reg     <= In_Data;
      in_valid_reg <= In_Valid;
    end
  end

  //-------------------------------------------------------------------------
  // Pad the input data to the nearest power-of-two width.
  //-------------------------------------------------------------------------
  wire [PaddedWidth-1:0] padded_data;
  assign padded_data = { data_reg, {PaddedWidth - InWidth_g{1'b0}} };

  //-------------------------------------------------------------------------
  // Combinational logic to decode the first set bit.
  // ffs() returns the index (starting at 0) of the first set bit.
  // If padded_data is zero, then no bit is found.
  //-------------------------------------------------------------------------
  wire [$clog2(InWidth_g)-1:0] comb_firstbit;
  wire                         comb_found;
  assign {comb_found, comb_firstbit} = (padded_data != 0) ?
      { 1'b1, ffs(padded_data) } : { 1'b0, {BinBits_c{1'b0}} };

  //-------------------------------------------------------------------------
  // Pipeline registers for the first-bit decoding logic.
  // Stage 0 is driven by the combinational result.
  // Additional stages (PlRegs_g) introduce latency.
  //-------------------------------------------------------------------------
  reg [$clog2(InWidth_g)-1:0] pipe_firstbit [0:PlRegs_g];
  reg                         pipe_found   [0:PlRegs_g];
  reg                         pipe_valid   [0:PlRegs_g];

  integer i;
  always_ff @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      for (i = 0; i <= PlRegs_g; i = i + 1) begin
        pipe_firstbit[i] <= '0;
        pipe_found[i]    <= 1'b0;
        pipe_valid[i]    <= 1'b0;
      end
    end
    else begin
      // Stage 0: capture combinational result
      pipe_firstbit[0] <= comb_firstbit;
      pipe_found[0]    <= comb_found;
      pipe_valid[0]    <= in_valid_reg;
      // Pipeline stages: register the output of the previous stage
      for (i = 1; i <= PlRegs_g; i = i + 1) begin
        pipe_firstbit[i] <= pipe_firstbit[i-1];
        pipe_found[i]    <= pipe_found[i-1];
        pipe_valid[i]    <= pipe_valid[i-1];
      end
    end
  end

  //-------------------------------------------------------------------------
  // Output registration (if enabled)
  //-------------------------------------------------------------------------
  reg [$clog2(InWidth_g)-1:0] out_firstbit_reg;
  reg                         out_found_reg;
  reg                         out_valid_reg;

  always_ff @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      out_firstbit_reg <= '0;
      out_found_reg    <= 1'b0;
      out_valid_reg    <= 1'b0;
    end
    else if (OutReg_g) begin
      out_firstbit_reg <= pipe_firstbit[PlRegs_g];
      out_found_reg    <= pipe_found[PlRegs_g];
      out_valid_reg    <= pipe_valid[PlRegs_g];
    end
  end

  //-------------------------------------------------------------------------
  // Drive the outputs.
  //-------------------------------------------------------------------------
  assign Out_FirstBit = out_firstbit_reg;
  assign Out_Found    = out_found_reg;
  assign Out_Valid    = out_valid_reg;

endmodule
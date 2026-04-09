module cvdp_copilot_decode_firstbit #(
  parameter int InWidth_g = 32,
  parameter int InReg_g   = 1,
  parameter int OutReg_g  = 1,
  parameter int PlRegs_g  = 1  // Number of pipeline registers for first-bit decoding logic
) (
  input  logic Clk,
  input  logic Rst,
  input  logic [InWidth_g-1:0] In_Data,
  input  logic In_Valid,
  output logic [($clog2(InWidth_g))-1:0] Out_FirstBit,
  output logic Out_Found,
  output logic Out_Valid
);

  //-------------------------------------------------------------------------
  // Local parameters
  //-------------------------------------------------------------------------
  // Number of bits required to encode the index of the first set bit
  localparam int BinBits_c = $clog2(InWidth_g);
  // Compute padded width: if InWidth_g is not a power-of-two, pad to the next power-of-two.
  localparam int Pow2Width = (InWidth_g == (1 << BinBits_c)) ? InWidth_g : (1 << (BinBits_c + 1));

  //-------------------------------------------------------------------------
  // Input Register (if enabled)
  //-------------------------------------------------------------------------
  logic [InWidth_g-1:0] in_reg_data;
  logic in_reg_valid;

  if (InReg_g) begin : reg_input
    always_ff @(posedge Clk or posedge Rst) begin
      if (Rst) begin
        in_reg_data  <= '0;
        in_reg_valid <= 1'b0;
      end else begin
        in_reg_data  <= In_Data;
        in_reg_valid <= In_Valid;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Combinational First-Bit Decoder Logic
  //-------------------------------------------------------------------------
  // This block searches for the lowest set bit in the input vector.
  // If In_Valid is asserted, it iterates from bit 0 to InWidth_g-1.
  // If no set bit is found, Out_Found is de-asserted and Out_FirstBit is zero.
  //
  // Note: The input vector is assumed to be already the correct width.
  // If InWidth_g is not a power-of-two, the design internally considers
  // only the lower InWidth_g bits (i.e. no extra bits are processed).
  //
  // The combinational result is later pipelined through PlRegs_g stages.
  //-------------------------------------------------------------------------
  logic [BinBits_c-1:0] comb_first;
  logic comb_found;
  logic comb_valid;

  always_comb begin
    // Use registered input if enabled; otherwise, use the direct input.
    comb_valid = (InReg_g) ? in_reg_valid : In_Valid;
    if (comb_valid) begin
      comb_found = 1'b0;
      comb_first = '0;
      integer i;
      for (i = 0; i < InWidth_g; i = i + 1) begin
        if ((InReg_g ? in_reg_data[i] : In_Data[i])) begin
          comb_found = 1'b1;
          comb_first = i;
          // Exit the loop once the first set bit is found.
          break;
        end
      end
    end else begin
      comb_found = 1'b0;
      comb_first = '0;
    end
  end

  //-------------------------------------------------------------------------
  // Pipeline Registers for First-Bit Decoder Logic
  //-------------------------------------------------------------------------
  // The combinational result (comb_first, comb_found, comb_valid) is
  // registered through PlRegs_g pipeline stages. When PlRegs_g = 0, the
  // detection occurs in one cycle; for PlRegs_g > 0, the result is
  // registered across multiple stages.
  //
  // We create an array of pipeline registers where index 0 holds the
  // combinational result and indices 1 to PlRegs_g hold the pipelined data.
  //-------------------------------------------------------------------------
  logic [BinBits_c-1:0] pipe_first [0:PlRegs_g];
  logic pipe_found [0:PlRegs_g];
  logic pipe_valid [0:PlRegs_g];

  // Stage 0: Direct combinational result
  assign pipe_first[0] = comb_first;
  assign pipe_found[0] = comb_found;
  assign pipe_valid[0] = comb_valid;

  // Pipeline register stages: Each stage registers the output of the previous stage.
  generate
    genvar i;
    for (i = 1; i <= PlRegs_g; i++) begin : pipeline_stages
      always_ff @(posedge Clk or posedge Rst) begin
        if (Rst) begin
          pipe_valid[i]   <= 1'b0;
          pipe_first[i]   <= '0;
          pipe_found[i]   <= 1'b0;
        end else begin
          pipe_valid[i]   <= pipe_valid[i-1];
          pipe_first[i]   <= pipe_first[i-1];
          pipe_found[i]   <= pipe_found[i-1];
        end
      end
    end
  endgenerate

  // Final pipelined result: use the output of the last pipeline stage if any.
  logic final_valid;
  logic final_found;
  logic [BinBits_c-1:0] final_first;

  assign final_valid = (PlRegs_g > 0) ? pipe_valid[PlRegs_g] : comb_valid;
  assign final_first = (PlRegs_g > 0) ? pipe_first[PlRegs_g] : comb_first;
  assign final_found = (PlRegs_g > 0) ? pipe_found[PlRegs_g] : comb_found;

  //-------------------------------------------------------------------------
  // Output Register (if enabled)
  //-------------------------------------------------------------------------
  // If OutReg_g is enabled, the final pipelined result is registered before
  // being sent out. Otherwise, the result is directly assigned.
  //-------------------------------------------------------------------------
  if (OutReg_g) begin : reg_output
    always_ff @(posedge Clk or posedge Rst) begin
      if (Rst) begin
        Out_Valid     <= 1'b0;
        Out_FirstBit  <= '0;
        Out_Found     <= 1'b0;
      end else begin
        Out_Valid     <= final_valid;
        Out_FirstBit  <= final_first;
        Out_Found     <= final_found;
      end
    end
  end else begin : no_reg_output
    assign Out_Valid     = final_valid;
    assign Out_FirstBit  = final_first;
    assign Out_Found     = final_found;
  end

endmodule
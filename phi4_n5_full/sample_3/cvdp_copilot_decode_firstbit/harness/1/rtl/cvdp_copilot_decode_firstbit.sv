module cvdp_copilot_decode_firstbit #(
  parameter InWidth_g = 32,
  parameter InReg_g   = 1,
  parameter OutReg_g  = 1,
  parameter PlRegs_g  = 1  // Number of pipeline stages (0 or more)
)(
  input  logic                     Clk,
  input  logic                     Rst,  // asynchronous, active-high reset
  input  logic [InWidth_g-1:0]     In_Data,
  input  logic                     In_Valid,
  output logic [$clog2(InWidth_g)-1:0] Out_FirstBit,
  output logic                     Out_Found,
  output logic                     Out_Valid
);

  //-------------------------------------------------------------------------
  // Local Parameters
  //-------------------------------------------------------------------------
  localparam integer BinBits_c = $clog2(InWidth_g);       // Bits needed to index In_Data
  localparam integer PadWidth  = (1 << BinBits_c);          // Nearest power-of-two width

  //-------------------------------------------------------------------------
  // Internal Signals
  //-------------------------------------------------------------------------
  // Registered input (if enabled)
  logic [InWidth_g-1:0] in_data_reg;
  logic                 in_valid_reg;

  // Padded input vector (always width = PadWidth)
  logic [PadWidth-1:0]  data_padded;

  // Combinational logic outputs: first set bit index, found flag, and valid flag
  logic [$clog2(InWidth_g)-1:0] comb_first_bit;
  logic                         comb_found;
  logic                         comb_valid;

  // Pipeline registers arrays (if any pipeline stages are used)
  // Only used when PlRegs_g > 0.
  logic [$clog2(InWidth_g)-1:0] pipe_first [0:PlRegs_g];
  logic                         pipe_found [0:PlRegs_g];
  logic                         pipe_valid [0:PlRegs_g];

  //-------------------------------------------------------------------------
  // Input Register (if enabled)
  //-------------------------------------------------------------------------
  generate
    if (InReg_g == 1) begin : reg_in
      always_ff @(posedge Clk or posedge Rst) begin
        if (Rst) begin
          in_data_reg  <= '0;
          in_valid_reg <= 1'b0;
        end else begin
          in_data_reg  <= In_Data;
          in_valid_reg <= In_Valid;
        end
      end
    end
    else begin : no_reg_in
      assign in_data_reg  = In_Data;
      assign in_valid_reg = In_Valid;
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Pad the input data to the nearest power-of-two width
  //-------------------------------------------------------------------------
  assign data_padded = { {(PadWidth - InWidth_g){1'b0}}, in_data_reg };

  //-------------------------------------------------------------------------
  // Combinational First-Bit Decoder Logic
  //-------------------------------------------------------------------------
  // This always_comb block scans the lower InWidth_g bits of data_padded 
  // to find the index of the lowest set bit.
  always_comb begin
    // Propagate the input valid signal
    comb_valid = (InReg_g ? in_valid_reg : In_Valid);
    comb_found = 1'b0;
    comb_first_bit = '0;
    // Iterate over bits 0 to InWidth_g-1
    for (int i = 0; i < InWidth_g; i++) begin
      if (data_padded[i]) begin
        comb_found   = 1'b1;
        comb_first_bit = i;
        // Exit the loop once the first set bit is found
        break;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Pipeline Stages and Final Output
  //-------------------------------------------------------------------------
  // If PlRegs_g > 0, the combinational result is passed through pipeline stages.
  // Otherwise, the result is directly forwarded (optionally registered at output).
  generate
    if (PlRegs_g > 0) begin : pipeline_reg_block

      //-------------------------------------------------------------------------
      // Stage 0: Capture the combinational result
      //-------------------------------------------------------------------------
      always_ff @(posedge Clk or posedge Rst) begin
        if (Rst) begin
          pipe_valid[0]  <= 1'b0;
          pipe_first[0]  <= '0;
          pipe_found[0]  <= 1'b0;
        end else begin
          pipe_valid[0]  <= comb_valid;
          pipe_first[0]  <= comb_first_bit;
          pipe_found[0]  <= comb_found;
        end
      end

      //-------------------------------------------------------------------------
      // Pipeline Stages 1 to PlRegs_g: Propagate the result through each stage
      //-------------------------------------------------------------------------
      for (genvar i = 1; i <= PlRegs_g; i = i + 1) begin : pipeline_stages
        always_ff @(posedge Clk or posedge Rst) begin
          if (Rst) begin
            pipe_valid[i]  <= 1'b0;
            pipe_first[i]  <= '0;
            pipe_found[i]  <= 1'b0;
          end else begin
            pipe_valid[i]  <= pipe_valid[i-1];
            pipe_first[i]  <= pipe_first[i-1];
            pipe_found[i]  <= pipe_found[i-1];
          end
        end
      end

      //-------------------------------------------------------------------------
      // Final Output Stage: Register or directly drive the outputs
      //-------------------------------------------------------------------------
      if (OutReg_g == 1) begin : out_reg
        always_ff @(posedge Clk or posedge Rst) begin
          if (Rst) begin
            Out_Valid     <= 1'b0;
            Out_FirstBit  <= '0;
            Out_Found     <= 1'b0;
          end else begin
            Out_Valid     <= pipe_valid[PlRegs_g];
            Out_FirstBit  <= pipe_first[PlRegs_g];
            Out_Found     <= pipe_found[PlRegs_g];
          end
        end
      end
      else begin : no_out_reg
        assign Out_Valid     = pipe_valid[PlRegs_g];
        assign Out_FirstBit  = pipe_first[PlRegs_g];
        assign Out_Found     = pipe_found[PlRegs_g];
      end

    end
    else begin : no_pipeline
      // No pipelining: directly use the combinational result
      if (OutReg_g == 1) begin : out_reg
        always_ff @(posedge Clk or posedge Rst) begin
          if (Rst) begin
            Out_Valid     <= 1'b0;
            Out_FirstBit  <= '0;
            Out_Found     <= 1'b0;
          end else begin
            Out_Valid     <= comb_valid;
            Out_FirstBit  <= comb_first_bit;
            Out_Found     <= comb_found;
          end
        end
      end
      else begin : no_out_reg
        assign Out_Valid     = comb_valid;
        assign Out_FirstBit  = comb_first_bit;
        assign Out_Found     = comb_found;
      end
    end
  endgenerate

endmodule
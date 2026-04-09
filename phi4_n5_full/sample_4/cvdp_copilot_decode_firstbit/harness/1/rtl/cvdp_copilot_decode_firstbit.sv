module implements a first‐bit decoder that, given an input data vector (In_Data)
//   of configurable width (InWidth_g), finds the index of the lowest set bit. The design
//   pads the input to the next power‐of‐two width, computes the first set bit in a
//   combinational function, and then passes the result through a configurable number of
//   pipeline stages (PlRegs_g). Input and output registers are optionally added based on
//   InReg_g and OutReg_g. The valid signal (Out_Valid) is generated only when a new valid
//   input is processed and the result passes through all pipeline stages.
//
//   On reset (Rst = 1), all pipeline and output registers are cleared.
//
// Parameters:
//   InWidth_g : Width of the input data vector (default 32)
//   InReg_g   : Enable input register (default 1)
//   OutReg_g  : Enable output register (default 1)
//   PlRegs_g  : Number of pipeline registers for the decoding logic (default 1)
//
// Note:
//   The module pads the input vector to PadWidth = 2^(clog2(InWidth_g)) bits.
//   The output index (Out_FirstBit) is represented using BinBits_c = clog2(InWidth_g) bits.
//   If no bit is set in the input data, then Out_Found is deasserted (0) and Out_FirstBit is 0.
//
module cvdp_copilot_decode_firstbit
  #(parameter InWidth_g = 32,
    parameter InReg_g   = 1,
    parameter OutReg_g  = 1,
    parameter PlRegs_g  = 1)
  (input  logic                    Clk,
   input  logic                    Rst,
   input  logic [InWidth_g-1:0]     In_Data,
   input  logic                    In_Valid,
   output logic [clog2(InWidth_g)-1:0] Out_FirstBit,
   output logic                    Out_Found,
   output logic                    Out_Valid);

   // Compute the number of bits required to encode the index.
   localparam int BinBits_c = $clog2(InWidth_g);
   // Pad the input to the next power-of-two width.
   localparam int PadWidth = (1 << BinBits_c);

   //-------------------------------------------------------------------------
   // Input Register Stage (if enabled)
   //-------------------------------------------------------------------------
   logic [InWidth_g-1:0] in_data_reg;
   logic                 in_valid_reg;
   always_ff @(posedge Clk or posedge Rst) begin
      if (Rst) begin
         in_data_reg  <= '0;
         in_valid_reg <= 1'b0;
      end
      else begin
         in_data_reg  <= In_Data;
         in_valid_reg <= In_Valid;
      end
   end

   //-------------------------------------------------------------------------
   // Compute Padded Data
   //-------------------------------------------------------------------------
   // Pad the input vector with zeros on the MSB side so that its width equals PadWidth.
   logic [PadWidth-1:0] data_padded;
   assign data_padded = { {(PadWidth - InWidth_g){1'b0}}, in_data_reg };

   //-------------------------------------------------------------------------
   // Function: find_first_set
   // Returns the index (0-indexed) of the first '1' bit in the input vector.
   //-------------------------------------------------------------------------
   function automatic [BinBits_c-1:0] find_first_set(input logic [PadWidth-1:0] data);
      integer i;
      begin
         find_first_set = '0;
         for (i = 0; i < PadWidth; i = i + 1) begin
            if (data[i] == 1'b1) begin
               find_first_set = i;
               return;
            end
         end
      end
   endfunction

   //-------------------------------------------------------------------------
   // Combinational Decoding Logic
   //-------------------------------------------------------------------------
   // found_comb is high if any bit in data_padded is set.
   // first_bit_comb holds the index of the first set bit (or 0 if none found).
   // valid_comb asserts only if the input was valid and a set bit was detected.
   logic [BinBits_c-1:0] first_bit_comb;
   logic                  found_comb;
   logic                  valid_comb;
   assign found_comb    = |data_padded;
   assign first_bit_comb = find_first_set(data_padded);
   assign valid_comb    = in_valid_reg & found_comb;

   //-------------------------------------------------------------------------
   // Pipeline Registers for Decoding Logic
   //-------------------------------------------------------------------------
   generate
      if (PlRegs_g > 0) begin : pipeline
         // Declare pipeline register arrays.
         genvar i;
         logic [BinBits_c-1:0] pipe_first [0:PlRegs_g-1];
         logic                 pipe_found [0:PlRegs_g-1];
         logic                 pipe_valid [0:PlRegs_g-1];

         // Pipeline register update: if a valid input is present, update stage 0 with
         // the combinational result and shift the registers; otherwise, flush the registers.
         always_ff @(posedge Clk or posedge Rst) begin
            if (Rst) begin
               for (i = 0; i < PlRegs_g; i = i + 1) begin
                  pipe_first[i]  <= '0;
                  pipe_found[i]  <= 1'b0;
                  pipe_valid[i]  <= 1'b0;
               end
            end
            else begin
               if (in_valid_reg) begin
                  pipe_first[0]  <= first_bit_comb;
                  pipe_found[0]  <= found_comb;
                  pipe_valid[0]  <= valid_comb;
                  // Shift the pipeline registers.
                  for (i = PlRegs_g-1; i > 0; i = i - 1) begin
                     pipe_first[i]  <= pipe_first[i-1];
                     pipe_found[i]  <= pipe_found[i-1];
                     pipe_valid[i]  <= pipe_valid[i-1];
                  end
               end
               else begin
                  // Flush pipeline registers when input is not valid.
                  pipe_first[0]  <= '0;
                  pipe_found[0]  <= 1'b0;
                  pipe_valid[0]  <= 1'b0;
                  for (i = PlRegs_g-1; i > 0; i = i - 1) begin
                     pipe_first[i]  <= pipe_first[i-1];
                     pipe_found[i]  <= pipe_found[i-1];
                     pipe_valid[i]  <= pipe_valid[i-1];
                  end
               end
            end
         end

         //-------------------------------------------------------------------------
         // Output Register Stage (if enabled)
         //-------------------------------------------------------------------------
         logic [BinBits_c-1:0] out_reg_first;
         logic                  out_reg_found;
         logic                  out_reg_valid;
         always_ff @(posedge Clk or posedge Rst) begin
            if (Rst) begin
               out_reg_first  <= '0;
               out_reg_found  <= 1'b0;
               out_reg_valid  <= 1'b0;
            end
            else if (OutReg_g) begin
               out_reg_first  <= pipe_first[PlRegs_g-1];
               out_reg_found  <= pipe_found[PlRegs_g-1];
               out_reg_valid  <= pipe_valid[PlRegs_g-1];
            end
         end

         // Drive module outputs.
         assign Out_FirstBit = OutReg_g ? out_reg_first : pipe_first[PlRegs_g-1];
         assign Out_Found    = OutReg_g ? out_reg_found : pipe_found[PlRegs_g-1];
         assign Out_Valid    = OutReg_g ? out_reg_valid : pipe_valid[PlRegs_g-1];

      end
      else begin : no_pipeline
         // No pipeline registers: use the combinational result directly.
         // Optionally register the output if OutReg_g is enabled.
         logic [BinBits_c-1:0] out_reg_first;
         logic                  out_reg_found;
         logic                  out_reg_valid;
         always_ff @(posedge Clk or posedge Rst) begin
            if (Rst) begin
               out_reg_first  <= '0;
               out_reg_found  <= 1'b0;
               out_reg_valid  <= 1'b0;
            end
            else if (OutReg_g) begin
               out_reg_first  <= first_bit_comb;
               out_reg_found  <= found_comb;
               out_reg_valid  <= valid_comb;
            end
         end

         assign Out_FirstBit = OutReg_g ? out_reg_first : first_bit_comb;
         assign Out_Found    = OutReg_g ? out_reg_found : found_comb;
         assign Out_Valid    = OutReg_g ? out_reg_valid : valid_comb;
      end
   endgenerate

endmodule
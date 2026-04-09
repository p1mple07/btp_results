module cvdp_copilot_decode_firstbit #(
  parameter int unsigned InWidth_g = 32, // Input data width
  parameter bit          InReg_g  = 1,  // Enable input register
  parameter bit          OutReg_g = 1,  // Enable output register
  parameter int unsigned PlRegs_g = 1   // Pipeline register count
) (
  input  logic             Clk_i,         // Clock signal
  input  logic             Rst_ni,        // Reset signal (active high)

  input  logic [InWidth_g-1:0] In_Data_i,     // Input data vector
  input  logic              In_Valid_i,    // Input data validity signal

  output logic [PlRegs_g+1:0] Out_FirstBit_o, // First bit found index
  output logic              Out_Found_o,   // Set to '1' if any bit in In_Data_i was set
  output logic              Out_Valid_o    // Output data validity signal
);

  localparam int unsigned BinBits_c = $clog2(InWidth_g); // Binary logarithm of InWidth_g

  // Declare pipeline registers
  reg  [InWidth_g-1:0] Reg_q;
  wire [InWidth_g-1:0] Reg_d;
  wire                 Reg_we;

  // Register update logic
  assign Reg_d = InReg_g? In_Data_i : Reg_q; // Register data update
  assign Reg_we = InReg_g & In_Valid_i;  // Register write enable

  always @(posedge Clk_i or negedge Rst_ni) begin
    if (!Rst_ni) begin
      Reg_q <= '0; // Asynchronous reset, clear pipeline registers
    end else if (Reg_we) begin
      Reg_q <= Reg_d; // Update pipeline registers with new data
    end
  end

  // Output generation logic
  assign Out_FirstBit_o[PlREGS_g] = Reg_q[BinBits_c-1:0]; // Extract first bit index from pipeline registers
  assign Out_FirstBit_o[PlREGS_g-1:0] = Reg_q[BinBits_c-2:0];
  assign Out_FirstBit_o[PlREGS_g-2:0] = Reg_q[BinBits_c-3:0];
 ... (similar assignments for other pipeline registers)
  assign Out_FirstBit_o[0:0] = Reg_q[BinBits_c-PlREGS_g:0]; // Extract first bit index from pipeline registers

  assign Out_Found_o = Reg_q!= '0; // Check for any set bits in the input data

  assign Out_Valid_o = Reg_Valid_i; // Pass through the input data validity signal

endmodule
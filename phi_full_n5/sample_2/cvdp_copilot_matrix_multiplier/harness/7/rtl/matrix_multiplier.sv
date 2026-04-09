module matrix_multiplier #(
  parameter ROW_A             = 4,                                                  
  parameter COL_A             = 4,                                                  
  parameter ROW_B             = 4,                                                  
  parameter COL_B             = 4,                                                  
  parameter INPUT_DATA_WIDTH  = 8,                                                  
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)               
) (
  input clk,                      // Clock signal
  input srst,                     // Synchronous reset
  input valid_in,                // Valid input signal
  input wire [(ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a, // Input matrix A in 1D form
  input wire [(ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b, // Input matrix B in 1D form
  output reg valid_out,           // Valid output signal
  output reg [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c // Output matrix C in 1D form
);

  // Intermediate registers for multiplication and accumulation
  logic [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] matrix_c_stage_mult,
      matrix_c_stage_acc,
      matrix_c_stage_out;

  // Shift registers for latency matching
  logic [(ROW_A*COL_B*COL_A-1):0] shift_reg_mult[COL_A];
  logic [(ROW_A*COL_B-1):0] shift_reg_acc[COL_A-1];
  logic [(ROW_A-1):0] shift_reg_out[COL_A-1];

  // Sequential logic for computation
  always @(posedge clk) begin
    if (srst) begin
      matrix_c <= {{(COL_A+2)-1{1'b0}}, 0};
      shift_reg_mult <= {{(COL_A+2)-1{1'b0}}, 0};
      shift_reg_acc <= {{(COL_A+2)-1{1'b0}}, 0};
      shift_reg_out <= {{(COL_A+2)-1{1'b0}}, 0};
    end else begin
      if (valid_in) begin
        // Multiplication stage
        shift_reg_mult <= {{(COL_A+2)-1{1'b0}}, matrix_a};
        for (int i = 0; i < COL_A; i++) begin
          matrix_c_stage_mult[i*COL_B*OUTPUT_DATA_WIDTH:(i+1)*COL_B*OUTPUT_DATA_WIDTH] =
              &shift_reg_mult[i*OUTPUT_DATA_WIDTH:(i+1)*OUTPUT_DATA_WIDTH];
          shift_reg_mult <= {{(COL_A+2)-1{1'b0}}, matrix_a};
        end

        // Accumulation stage
        shift_reg_acc <= {{(COL_A+2)-1{1'b0}}, matrix_c_stage_mult};
        for (int i = 1; i < COL_A; i++) begin
          shift_reg_acc <= {{(COL_A+2)-1{1'b0}}, shift_reg_acc[COL_B*OUTPUT_DATA_WIDTH:(COL_B+1)*OUTPUT_DATA_WIDTH] +
                           shift_reg_mult[i*COL_B*OUTPUT_DATA_WIDTH:(i+1)*COL_B*OUTPUT_DATA_WIDTH];
        end

        // Output stage
        shift_reg_out <= {{(COL_A+2)-1{1'b0}}, shift_reg_acc[COL_A-1*OUTPUT_DATA_WIDTH:(COL_A)*OUTPUT_DATA_WIDTH] +
                         shift_reg_mult[COL_A*COL_B*OUTPUT_DATA_WIDTH:(COL_A+1)*COL_B*OUTPUT_DATA_WIDTH];
      end

      // Update outputs
      matrix_c <= shift_reg_out;
      valid_out <= 1;
    end
  end

endmodule

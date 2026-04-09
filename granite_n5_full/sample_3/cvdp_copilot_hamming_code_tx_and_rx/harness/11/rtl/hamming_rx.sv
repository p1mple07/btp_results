module hamming_rx #(parameter DATA_WIDTH = 4, parameter PARITY_BIT = 3, parameter ENCODED_DATA = 8, parameter ENCODED_DATA_BIT = $clog2(ENCODED_DATA)) (
  input [ENCODED_DATA-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out
);

  // Define internal signals and variables
  logic [PARITY_BIT-1:0] parity;
  logic [DATA_WIDTH-1:0] corrected_data;
  logic [DATA_WIDTH-1:0] data_out_internal;
  logic [Encoded_Data-1:0] data_out_encoded;

  // Calculate parity bits
  generate
    if (PARITY_BIT > 0) begin : gen_parity
      genvar i;
      for (i = 0; i < PARITY_BIT; i++) begin : gen_parity_bit
        assign parity[i] = data_in[i*2] ^ data_in[i*2 + 1];
      end
    end
  endgenerate

  // Generate corrected data
  always @(*) begin : gen_corrected_data
    corrected_data = data_in;
    
    // Check for errors and correct them if necessary
    if ({parity[PARITY_BIT-1:0]} == 0) begin : gen_no_errors
      // No errors found, pass data unchanged
      data_out_internal = data_in;
    end
    else begin : gen_errors
      // Find the first parity bit that has an error
      for (int i = 0; i < PARITY_BIT; i++) begin : gen_find_error
        if ({parity[i]} == 1) begin : gen_check_for_error
          // Invert the bit where the error occurred
          corrected_data[i*2]     <= data_in[i*2];
          corrected_data[i*2 + 1] <= ~data_in[i*2 + 1];
          // Stop searching after finding the first error
          break;
        end
      end
    end
  endgenerate

  // Correct the data with parity bits
  assign data_out_encoded = {parity, data_out_internal};

endmodule
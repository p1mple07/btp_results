module image_rotate #(
  parameter IN_ROW     = 4,                                   // Number of rows in input image
  parameter IN_COL     = 4,                                   // Number of columns in input image
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8,                                   // Bit-width of data
  parameter OUTPUT_DATA_WIDTH = DATA_WIDTH
) (
  input  logic                                    clk,                // Clock Signal
  input  logic                                    srst,               // Active-High Synchronous Reset
  input  logic                                    valid_in,           // Indicates valid input image
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,           // Flattened input image
  output logic                                    valid_out,          // Indicates valid output image
  output logic                                    [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out           // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg, padded_image_reg2, padded_image_reg3;     // Padded image stored in registers
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg, transposed_image_reg2, transposed_image_reg3; // Transposed image stored in registers
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg, rotated_image_reg2, rotated_image_reg3;    // Final rotated image (latency buffer)

  logic [DATA_WIDTH-1:0] valid_out_reg;

  always_ff @(posedge clk) begin
    if (srst) begin
      padded_image <= 0;
      transposed_image <= 0;
      rotated_image <= 0;
      valid_out <= 0;
    end else begin
      valid_out <= valid_in;

      // Step 1: Pad the input image into a square image (Sequentially Stored)
      for (int pad_row = 0; pad_row < OUT_ROW; pad_row++) begin
        for (int pad_col = 0; pad_col < OUT_COL; pad_col++) begin
          if ((pad_row < IN_ROW) && (pad_col < IN_COL)) begin
            padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] = image_in[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH];
          end else begin
            padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] = 0;
          end
        end
      end

      // Step 2: Transpose the padded image (Stored in Registers)
      for (int trans_row = 0; trans_row < OUT_ROW; trans_row++) begin
        for (int trans_col = 0; trans_col < OUT_COL; trans_col++) begin
          transposed_image[(trans_col * OUT_ROW + trans_row) * DATA_WIDTH +: DATA_WIDTH] <= padded_image[(trans_row * OUT_COL + trans_col) * DATA_WIDTH +: DATA_WIDTH];
        end
      end

      // Step 3: Apply rotation logic with additional latency buffer
      for (int rot_row = 0; rot_row < OUT_ROW; rot_row++) begin
        for (int rot_col = 0; rot_col < OUT_COL; rot_col++) begin
          case (rotation_angle)
            2'b00: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];
            2'b01: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image[(OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)] * OUTPUT_DATA_WIDTH +: DATA_WIDTH;
            2'b10: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image[(OUT_ROW-1-rot_row) * OUT_COL + rot_col] * OUTPUT_DATA_WIDTH +: DATA_WIDTH;
            2'b11: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image[(OUT_ROW-1-rot_row) * OUT_COL + rot_col] * OUTPUT_DATA_WIDTH +: DATA_WIDTH;
          endcase
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    rotated_image_reg <= rotated_image;
  end

  always_ff @(posedge clk) begin
    image_out <= rotated_image_reg;
  end

endmodule

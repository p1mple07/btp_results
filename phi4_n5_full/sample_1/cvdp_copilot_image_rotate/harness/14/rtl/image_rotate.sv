module image_rotate #(
  parameter IN_ROW     = 4,                                   // Number of rows in input image
  parameter IN_COL     = 4,                                   // Number of columns in input image
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8,                                   // Bit-width of data
  // Removed unused OUTPUT_DATA_WIDTH parameter
) (
  input  logic                                    clk,                // Clock Signal
  input  logic                                    srst,               // Active-High Synchronous Reset
  input  logic                                    valid_in,           // Indicates valid input image
  input  logic                       [       1:0] rotation_angle,     // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,           // Flattened input image
  output logic                                    valid_out,          // Indicates valid output image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out           // Flattened output image
);

  // Removed unused registers: transposed_image_reg2, transposed_image_reg3, rotated_image_reg2, rotated_image_reg3

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg, padded_image_reg2, padded_image_reg3;     // Padded image stored in registers
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg; // Transposed image stored in registers
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg;    // Final rotated image (latency buffer)

  logic [5:0] valid_out_reg;

  // Valid signal pipeline: valid_out is 1-bit; valid_out_reg is 6-bit so that {valid_out, valid_out_reg} forms a 7-bit vector.
  always_ff @(posedge clk) begin
    if (srst)
      {valid_out, valid_out_reg} <= 7'd0;
    else
      {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};
  end

  // Step 1: Pad the input image into a square image (Sequentially Stored)
  always_ff @(posedge clk) begin
    if (srst) begin
      padded_image <= '0;
    end else begin
      for (int pad_row = 0; pad_row < OUT_ROW; pad_row++) begin
        for (int pad_col = 0; pad_col < OUT_COL; pad_col++) begin
          if ((pad_row < IN_ROW) && (pad_col < IN_COL)) begin
            // Copy input data into padded_image using non-blocking assignment
            padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] <= image_in[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH];
          end else begin
            // Fill remaining positions with zeros using non-blocking assignment
            padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] <= '0;
          end
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    padded_image_reg   <= padded_image;
    padded_image_reg2  <= padded_image_reg;
    padded_image_reg3  <= padded_image_reg2;
  end

  // Step 2: Transpose the padded image (Stored in Registers)
  always_ff @(posedge clk) begin
    if (srst) begin
      transposed_image <= '0;
    end else begin
      for (int trans_row = 0; trans_row < OUT_ROW; trans_row++) begin
        for (int trans_col = 0; trans_col < OUT_COL; trans_col++) begin
          // Transpose logic: Swap rows and columns using non-blocking assignment
          transposed_image[(trans_col * OUT_ROW + trans_row) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg[(trans_row * OUT_COL + trans_col) * DATA_WIDTH +: DATA_WIDTH];
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    transposed_image_reg <= transposed_image;
  end

  // Step 3: Apply rotation logic with additional latency buffer
  always_ff @(posedge clk) begin
    if (srst) begin
      rotated_image <= '0;
    end else begin
      for (int rot_row = 0; rot_row < OUT_ROW; rot_row++) begin
        for (int rot_col = 0; rot_col < OUT_COL; rot_col++) begin
          case (rotation_angle)
            // 90° Clockwise: Transpose + Reverse Rows
            2'b00: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

            // 180° Clockwise: Reverse Rows and Columns
            2'b01: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[((OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

            // 270° Clockwise: Transpose + Reverse Columns
            2'b10: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[((OUT_ROW-1-rot_row) * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];

            // No Rotation (Pass-through)
            2'b11: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
          endcase
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    rotated_image_reg <= rotated_image;
  end

  // Step 4: Output Register for Added Latency
  always_ff @(posedge clk) begin
    if (srst)
      image_out <= '0;
    else
      image_out <= rotated_image_reg;
  end

endmodule
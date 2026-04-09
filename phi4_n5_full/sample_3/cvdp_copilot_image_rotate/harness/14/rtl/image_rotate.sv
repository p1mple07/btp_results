module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic                    clk,
  input  logic                    srst,
  input  logic                    valid_in,
  input  logic [1:0]              rotation_angle,
  input  logic [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
  output logic                    valid_out,
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

  // Removed unused parameter: OUTPUT_DATA_WIDTH

  // Removed unused signals: padded_image_reg2, transposed_image_reg2, transposed_image_reg3, rotated_image_reg2, rotated_image_reg3

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image_reg;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image_reg3;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image_reg;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image_reg;

  logic valid_out_reg; // Corrected width for valid_out_reg

  // Pipeline for valid output
  always_ff @(posedge clk) begin
    if (srst) begin
      valid_out      <= 1'b0;
      valid_out_reg  <= 1'b0;
    end else begin
      valid_out      <= valid_out_reg;
      valid_out_reg  <= valid_in;
    end
  end

  // Step 1: Pad the input image into a square image (Sequentially Stored)
  always_ff @(posedge clk) begin
    if (srst)
      padded_image <= '0;
    else begin
      logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] temp_padded;
      temp_padded = '0;
      for (int pad_row = 0; pad_row < OUT_ROW; pad_row++) begin
        for (int pad_col = 0; pad_col < OUT_COL; pad_col++) begin
          if ((pad_row < IN_ROW) && (pad_col < IN_COL))
            temp_padded[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] = image_in[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH];
          else
            temp_padded[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] = '0;
        end
      end
      padded_image <= temp_padded;
    end
  end

  // Pipeline registers for padded image
  always_ff @(posedge clk) begin
    if (srst) begin
      padded_image_reg  <= '0;
      padded_image_reg3 <= '0;
    end else begin
      padded_image_reg  <= padded_image;
      padded_image_reg3 <= padded_image_reg;
    end
  end

  // Step 2: Transpose the padded image (Stored in Registers)
  always_ff @(posedge clk) begin
    if (srst)
      transposed_image <= '0;
    else begin
      logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] temp_transposed;
      temp_transposed = '0;
      for (int trans_row = 0; trans_row < OUT_ROW; trans_row++) begin
        for (int trans_col = 0; trans_col < OUT_COL; trans_col++) begin
          temp_transposed[(trans_col * OUT_ROW + trans_row) * DATA_WIDTH +: DATA_WIDTH] = padded_image_reg[(trans_row * OUT_COL + trans_col) * DATA_WIDTH +: DATA_WIDTH];
        end
      end
      transposed_image <= temp_transposed;
    end
  end

  always_ff @(posedge clk) begin
    if (srst)
      transposed_image_reg <= '0;
    else
      transposed_image_reg <= transposed_image;
  end

  // Step 3: Apply rotation logic with additional latency buffer
  always_ff @(posedge clk) begin
    if (srst)
      rotated_image <= '0;
    else begin
      logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] temp_rotated;
      temp_rotated = '0;
      for (int rot_row = 0; rot_row < OUT_ROW; rot_row++) begin
        for (int rot_col = 0; rot_col < OUT_COL; rot_col++) begin
          case (rotation_angle)
            2'b00: // 90° Clockwise: Transpose + Reverse Rows
              temp_rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];
            2'b01: // 180° Clockwise: Reverse Rows and Columns
              temp_rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[((OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];
            2'b10: // 270° Clockwise: Transpose + Reverse Columns
              temp_rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[((OUT_ROW-1-rot_row) * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
            2'b11: // No Rotation (Pass-through)
              temp_rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
          endcase
        end
      end
      rotated_image <= temp_rotated;
    end
  end

  always_ff @(posedge clk) begin
    if (srst)
      rotated_image_reg <= '0;
    else
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
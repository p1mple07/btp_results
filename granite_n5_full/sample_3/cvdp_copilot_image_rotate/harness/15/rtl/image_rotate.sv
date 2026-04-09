module image_rotate #(
  parameter IN_ROW     = 4,                                   // Number of rows in input image
  parameter IN_COL     = 4,                                   // Number of columns in input image
  parameter OUT_ROW    = (IN_ROW > IN_COL)? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL)? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic                                    clk,                // Clock Signal
  input  logic                                    srst,               // Active-High Synchronous Reset
  input  logic                        [      1:0] rotation_angle,     // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,           // Flattened input image
  output logic                                    valid_out,          // Indicates valid output image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out           // Flattened output image
);

  // Step 1: Pad the input image into a square image (Sequentially Stored)
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg;

  always_ff @(posedge clk) begin
    if (srst)
      padded_image <= '0;
    else
      padded_image <= padded_image_reg; 
  end

  always_ff @(posedge clk) begin
    padded_image_reg <= padded_image;
  end

  // Step 2: Transpose the padded image (Stored in Registers)
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg, transposed_image_reg2;

  always_ff @(posedge clk) begin
    if (srst)
      transposed_image <= '0;
    else
      transposed_image <= transposed_image_reg;
  end

  always_ff @(posedge clk) begin
    transposed_image_reg <= transposed_image;
    transposed_image_reg2 <= transposed_image_reg;
  end

  // Step 3: Apply rotation logic with additional latency buffer
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image_reg2;

  always_ff @(posedge clk) begin
    if (srst)
      rotated_image <= '0;
    else
      case (rotation_angle)
        2'b00: rotated_image <= transposed_image_reg;
        2'b01: rotated_image <= padded_image_reg3;
        2'b10: rotated_image <= transposed_image_reg2;
        2'b11: rotated_image <= padded_image_reg3;
      endcase
  end

  always_ff @(posedge clk) begin
    if (srst)
      rotated_image <= '0;
    else
      rotated_image <= rotated_image_reg;
  end

  // Step 4: Output Register for Added Latency
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out, image_out_reg;

  always_ff @(posedge clk) begin
    if (srst)
      image_out <= '0;
    else
      case (rotation_angle)
        2'b00: image_out <= transposed_image_reg;
        2'b01: image_out <= padded_image_reg3;
        2'b10: image_out <= transposed_image_reg2;
        2'b11: image_out <= padded_image_reg3;
    endcase
  end

  always_ff @(posedge clk) begin
    if (srst)
      image_out <= '0;
    else
      case (rotation_angle)
        2'b00: image_out <= transposed_image_reg;
        2'b01: image_out <= padded_image_reg3;
        2'b10: image_out <= transposed_image_reg2;
        2'b11: image_out <= padded_image_reg3;
    endcase
  endgenerate
  generate
    for (n=0; n<16; n++:
    n = 15:
    n = n:
    begin
      case (n):
      15:
        case (n):
          0: image_out <= '0;

        15: image_out <= padded_image_reg3;

        11: image_out <= transposed_image_reg2:
          case (n):
            15:
              case (n):
                0: image_out <= '0.
              11: image_out <= padded_image_reg3:
                  default:
                    '0.
                  Please add the appropriate comments and the comments of the source file and how it works.
endgenerate
endmodule
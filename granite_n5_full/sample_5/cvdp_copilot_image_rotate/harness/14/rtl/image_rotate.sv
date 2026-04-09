module image_rotate #(
  parameter IN_ROW     = 4,                                   // Number of rows in input image
  parameter IN_COL     = 4,                                   // Number of columns in input image
  parameter OUT_ROW    = (IN_ROW > IN_COL)? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL)? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8,                                   // Bit-width of data
  parameter OUTPUT_DATA_WIDTH = DATA_WIDTH
) (
  input  logic                                    clk,                // Clock Signal
  input  logic                                    srst,               // Active-High Synchronous Reset
  input  logic                                    valid_in,           // Indicates valid input image
  input  logic                       [      1:0] rotation_angle,     // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,           // Flattened input image
  output logic                                    valid_out,          // Indicates valid output image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out           // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg, padded_image_reg2, padded_image_reg3;     // Padded image stored in registers
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg, transposed_image_reg2, transposed_image_reg3; // Transposed image stored in registers
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg, rotated_image_reg2, rotated_image_reg3;    // Final rotated image (latency buffer)

  logic [5:0] valid_out_reg;

  always_ff @(posedge clk)
    if (srst)
      {valid_out, valid_out_reg} <= '0;
    else
      {valid_out, valid_out_reg} <= {valid_out_reg, valid_in}; 

  // Step 1: Pad the input image into a square image (Sequentially Stored)
  always_ff @(posedge clk) begin
    if (srst) begin
      padded_image <= '0;
    end else begin
      for (int pad_row = 0; pad_row < IN_ROW; pad_col = 0; pad_col < IN_COL; pad_row < IN_ROW; pad_col < IN_COL; pad_row >= 0; pad_col >= 0; pad_row = 0; pad_col = 0; begin
        for (int pad_row = 0; pad_row < IN_ROW; pad_col < IN_COL; pad_row = 0; pad_col < IN_COL; begin
          // Copy input data into padded_image
          padded_image[(pad_row * OUT_ROW + pad_col * OUT_COL) * DATA_WIDTH +: DATA_WIDTH] <= image_in[(pad_row * IN_ROW + pad_col * IN_COL) * DATA_WIDTH +: DATA_WIDTH];
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (srst) begin
      transposed_image[(output_data_width = OUTPUT_DATA_WIDTH).
  end else begin
    if (rotation_angle == "00") begin
      transposed_image[(input_data_width = INPUT_DATA_WIDTH).
  } else begin
    case (rotation_angle)
      "01" : begin
        rotated_image[(input_data_width = INPUT_DATA_WIDTH).
  }
}

// Image Rotate
module image_rotate #(parameter int ROTATION_ANGLE = 0) (
  input 90-degree clockwise.
  input  logic                   
  output logic                   
  parameter int ROTATION_ANGLE, it can take 32-bit signed int ROTATION_ANGLE: 00, 11

// Create an empty file.
module create_empty.v

// Create an empty file.

// Create a new file.
module create_new.v

// Create a new file.
module create_new_file.v

// Rotate the image.

module rotate.v

// Rotate the image.

// This module will rotate the image.
// Use the `rotation_angle` parameter.

// from the input image.

// Convert the input image format into a new image format.

//
// The new image format.
// This is done using the `rotation_angle` parameter.

// to convert the input image format to a 2D array.

//
// Use the
// `rotation_angle` parameter to generate the new image format.

// The number of colors.
// Use the `rotation_angle` parameter.
// The width of the generated image is less than 64 pixels.
// Use the `rotation_angle` parameter.
// - `rotation_angle`.
//
// - The number of the generated image is less than 64 pixels.
//
// - The number of the generated image is less than 64 pixels.
// - The width of the generated image is less than 64 pixels.
// - The number of the generated image is less than 64 pixels.
// - The height of the generated image is less than 64 pixels.
// - The width of the generated image is less than 64 pixels.
// - The height of the generated image is less than 64 pixels.
// - The width of the generated image is less than 64 pixels.
// - The number of rows in the generated image is less than 64 rows.
// - The width of the generated image is less than 64 pixels.
// - The number of columns in the generated image is less than 64 columns in the generated image.
// - The number of rows in the generated image is less than 64 rows.
// - The width of the generated image is less than 64 pixels.
// - The number of columns in the generated image is less than 64 columns in the generated image is less than 64 pixels.
// - The number of rows in the generated image is less than 64 rows in the generated image is less than 64 rows in the generated image is less than 64 rows in the generated image is less than 64 rows in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image is less than 64 columns in the generated image.
// - The width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 64 width of the generated image is less than 8 bits of the generated image is 64 width of the generated image is less than 8 bits width of the generated image is 8 bits the generated image is less than 8 bits width of the generated image is 8 bits of the generated image is 8 bits width of the generated image is less than 8 bits width of the generated image is 8 bits width of the generated image is less than 8 bits width of the generated image is 8 bits width of the generated image is 8 bits of the generated image is less than 8 bits width of the generated image is less than 8 bits of the generated image is less than 8 bits of the generated image is 8 bits of the generated image is 8 bits of 8 bits of the generated image is less than 8 bits of the 8 bits of the generated image is 8 bits of the generated image is 8 bits of 8 bits of 8 bits of the 8 bits of the generated 8 bits of the generated image is 8 bits of the generated image is less than 8 bits of 8 bits of the generated 8 bits of the 8 bits of the generated 8 bits of the 8 bits of the generated image is 8 bits of the generated 8 bits of the generated 8 bits of 8 bits of the generated 8 bits of the 8 bits of the generated 8 bits of the generated 8 bits of 8 bits of the generated 8 bits of 8 bits of the generated 8 bits of  bits of the 8 bits of the 8 bits of the generated 8 bits of the generated 8 bits of the 8 bits of  of 8 bits of the 8 bits of the generated 8 bits of the generated 8 bits of the 8 bits of 8 bits of the 8 bits of the 8 bits of the generated 8 bits of the 8 bits of the 8 bits of the 8 bits of the generated 8 bits of the generated 8 bits of the  of 8 bits of the generated 8 bits of the generated 8 bits of the generated  of the 8 bits of the generated 8 bits of the generated 8 bits of the  of  the generated  bits of the 8 bits of the generated  of the generated 8 bits of the generated 8 bits of the generated  the generated 8 bits of the generated 8 bits of the generated 8 bits of the generated  of the generated  of the generated  bits of the generated image is  of the generated  of the generated image of the generated  of the generated  bits of the generated image is the generated image of the generated image is the generated image is the generated image is the generated image is the generated image is the generated image is the generated image.

  TWOD.
  if the generated image is T Wnd image. The generated image.
  if the generated image.png.
  {
  TWD image. TWD image. The TWD_generated image. TWD image.  If TWD image. TWD image. The TWD image TWD.
  if TWD image. TWD image.
    if TWD image. The TWD image.
  for the TWD image.
  The TWD image.
  if TWD image.
    TWD image. TWD image for the TWD image for the TWD image.
  for TWD image.
    TWD image for the TWD image.
  // TWD image.
    if TWD image.
    // The TWD image.
    TWD image for the TWD image.
    if TWD image for the TWD image.
    If TWD image.
    (TWD image. The TWD image.
    (TWD image.
  else the TWD image. The TWD image.
    ( TWD image.
  ( TWD image. For each TWD image.
    {
  (  TWD image. TWD_2Twd_ if TWD.
  ( TWD.
    ( TWD image.
    ( TWD_ 2 TWD_Twd image.
    ( TWD.
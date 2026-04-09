module image_rotate #(
  parameter IN_ROW     = 4,                                   // Number of rows in input image
  parameter IN_COL     = 4,                                   // Number of columns in input image
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic                                    clk,                // Clock Signal
  input  logic                                    srst,               // Active-High Synchronous Reset
  input  logic                                    valid_in,           // Indicates valid input image
  input  logic                       [       1:0] rotation_angle,     // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,           // Flattened input image
  output logic                                    valid_out,          // Indicates valid output image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out           // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image;

  logic [5:0] valid_out_reg;

  always_ff @(posedge clk) begin
    if (srst) begin
      valid_out <= '0;
      valid_out_reg <= '0;
    else
      valid_out <= valid_in & valid_out_reg;
    end
  end

  // Step 1: Pad the input image into a square image
  always_ff @(posedge clk) begin
    padded_image <= (valid_in ? image_in : (OUT_ROW*OUT_COL*DATA_WIDTH - 1) * DATA_WIDTH +: DATA_WIDTH);
  end

  // Step 2: Transpose the padded image
  always_ff @(posedge clk) begin
    transposed_image <= (padded_image[(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] 
      [(OUT_COL*OUT_ROW*DATA_WIDTH)-1:0] 
      & (valid_in ? 1 : 0));
  end

  // Step 3: Apply rotation logic
  always_ff @(posedge clk) begin
    rotated_image <= (rotation_angle == 2'b11 ? padded_image 
      : (rotation_angle == 2'b00 ? transposed_image 
      : (rotation_angle == 2'b01 ? padded_image[(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] 
      : transposed_image[(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0])));
  end

  // Step 4: Output Register for Added Latency
  always_ff @(posedge clk) begin
    image_out <= rotated_image;
  end

endmodule
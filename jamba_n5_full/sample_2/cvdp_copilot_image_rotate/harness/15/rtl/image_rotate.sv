module image_rotate #(
    parameter IN_ROW     = 4,
    parameter IN_COL     = 4,
    parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
    parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
    parameter DATA_WIDTH = 8
) (
    input  logic                                    clk,
    input  logic                                    srst,
    input  logic                                    valid_in,
    input  logic [[1:0]] rotation_angle,
    input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
    output logic [[OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

    logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg, padded_image_reg2, padded_image_reg3;
    logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg;
    logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg;

    logic [5:0] valid_out_reg;

    // 1. Pad the input image into a square
    always_ff @(posedge clk) begin
        if (srst) begin
            padded_image <= '0;
        end else begin
            for (int pad_row = 0; pad_row < OUT_ROW; pad_row++) begin
                for (int pad_col = 0; pad_col < OUT_COL; pad_col++) begin
                    if ((pad_row < IN_ROW) && (pad_col < IN_COL)) begin
                        padded_image[(pad_row*OUT_COL+pad_col)*DATA_WIDTH +: DATA_WIDTH]
                            <= image_in[(pad_row*IN_COL+pad_col)*DATA_WIDTH +: DATA_WIDTH];
                    end else begin
                        padded_image[(pad_row*OUT_COL+pad_col)*DATA_WIDTH +: DATA_WIDTH] <= '0;
                    end
                end
            end
        end
    end

    // 2. Transpose and rotate in a single combinational path
    always_ff @(posedge clk) begin
        if (srst) begin
            rotated_image <= '0;
        end else begin
            for (int rot_row = 0; rot_row < OUT_ROW; rot_row++) begin
                for (int rot_col = 0; rot_col < OUT_COL; rot_col++) begin
                    case (rotation_angle)
                        // 90° CW
                        2'b00: rotated_image[(rot_row*OUT_COL+rot_col)*DATA_WIDTH +: DATA_WIDTH]
                            <= transposed_image_reg[(rot_row*OUT_COL+ (OUT_COL-1-rot_col))*DATA_WIDTH +: DATA_WIDTH];
                        // 180° CW
                        2'b01: rotated_image[(rot_row*OUT_COL+rot_col)*DATA_WIDTH +: DATA_WIDTH]
                            <= padded_image_reg3[((OUT_ROW-1-rot_row)*OUT_COL + (OUT_COL-1-rot_col))*DATA_WIDTH +: DATA_WIDTH];
                        // 270° CW
                        2'b10: rotated_image[(rot_row*OUT_COL+rot_col)*DATA_WIDTH +: DATA_WIDTH]
                            <= transposed_image_reg[((OUT_ROW-1-rot_row)*OUT_COL + rot_col)*DATA_WIDTH +: DATA_WIDTH];
                        // No rotation
                        2'b11: rotated_image[(rot_row*OUT_COL+rot_col)*DATA_WIDTH +: DATA_WIDTH]
                            <= padded_image_reg3[(rot_row*OUT_COL+rot_col)*DATA_WIDTH +: DATA_WIDTH];
                    endcase
                end
            end
        end
    end

    // 3. Output register for latency
    always_ff @(posedge clk) begin
        if (srst) begin
            image_out <= '0;
        end else begin
            image_out <= rotated_image_reg;
        end
    end

endmodule

module matrix_multiplier #(
  parameter ROW_A             = 4,           // Number of rows in matrix A
  parameter COL_A             = 4,           // Number of columns in matrix A
  parameter ROW_B             = 4,           // Number of rows in matrix B
  parameter COL_B             = 4,           // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8,           // Bit-width of input data
  // Output data width is wide enough to hold the sum of COL_A products.
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic                  clk,
  input  logic                  srst,
  input  logic                  valid_in,
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic                  valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

  // Total number of elements in the product array: for each element of C there are COL_A products.
  localparam int PRODUCT_NUM = ROW_A * COL_B * COL_A;
  // Total number of elements in matrix C.
  localparam int C_NUM       = ROW_A * COL_B;

  // Intermediate registers:
  // product_reg: holds the product for each multiplication.
  // Each product is the multiplication of two INPUT_DATA_WIDTH-bit numbers, so width = INPUT_DATA_WIDTH*2.
  logic [INPUT_DATA_WIDTH*2-1:0] product_reg [0:PRODUCT_NUM-1];
  // acc_reg: accumulator for each element of matrix C.
  logic [OUTPUT_DATA_WIDTH-1:0] acc_reg [0:C_NUM-1];
  // out_reg: registered output for each element of matrix C.
  logic [OUTPUT_DATA_WIDTH-1:0] out_reg [0:C_NUM-1];

  // Register to capture and shift the valid signal.
  logic valid_reg;

  // Pipeline stage counter.
  // Stage 0: multiplication stage.
  // Stage 1 to COL_A: accumulation stage (each adds one product).
  // Stage COL_A+1: output stage.
  int stage;

  // Sequential process: pipeline the computation across stages.
  always_ff @(posedge clk or posedge srst) begin
    if (srst) begin
      stage          <= 0;
      valid_reg      <= 1'b0;
      // Clear all product and accumulator registers.
      for (int i = 0; i < PRODUCT_NUM; i++)
        product_reg[i] <= '0;
      for (int i = 0; i < C_NUM; i++) begin
        acc_reg[i]   <= '0;
        out_reg[i]   <= '0;
      end
    end
    else begin
      case (stage)
        0: begin
            // Multiplication stage.
            // Capture valid_in and compute all products.
            if (valid_in)
              valid_reg <= valid_in;
            for (int r = 0; r < ROW_A; r++) begin
              for (int c = 0; c < COL_B; c++) begin
                for (int i = 0; i < COL_A; i++) begin
                  int idx = (r*COL_B + c)*COL_A + i;
                  // Compute product: A[r,i] * B[i,c]
                  product_reg[idx] <= matrix_a[(r*COL_A + i)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH] *
                                        matrix_b[(i*COL_B + c)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH];
                end
              end
            end
            stage <= stage + 1;
          end
        default: begin
            if (stage <= COL_A) begin
              // Accumulation stage: add one product per cycle.
              // For each element of C, add the product corresponding to index (stage - 1).
              for (int r = 0; r < ROW_A; r++) begin
                for (int c = 0; c < COL_B; c++) begin
                  int acc_idx = (r*COL_B + c);
                  int prod_idx = acc_idx * COL_A + (stage - 1);
                  acc_reg[acc_idx] <= acc_reg[acc_idx] + product_reg[prod_idx];
                end
              end
              stage <= stage + 1;
            end
            else begin
              // Output stage: stage == COL_A+1.
              // Register the final accumulated result.
              for (int r = 0; r < ROW_A; r++) begin
                for (int c = 0; c < COL_B; c++) begin
                  int out_idx = (r*COL_B + c);
                  out_reg[out_idx] <= acc_reg[out_idx];
                end
              end
              valid_out <= valid_reg;
              // Ready for a new transaction.
              stage <= 0;
            end
          end
      endcase
    end
  end

  // Combine the registered outputs into the flattened output vector.
  // Each element of matrix C is OUTPUT_DATA_WIDTH bits.
  always_comb begin
    matrix_c = '0;
    for (int i = 0; i < C_NUM; i++) begin
      // Concatenate each out_reg element into the proper slice of matrix_c.
      matrix_c[((i+1)*OUTPUT_DATA_WIDTH)-1 -: OUTPUT_DATA_WIDTH] = out_reg[i];
    end
  end

endmodule
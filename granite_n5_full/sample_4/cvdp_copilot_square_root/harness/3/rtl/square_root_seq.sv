module square_root_seq (
    parameter WIDTH = 16,
    input [WIDTH-1:0] num,
    input clk,
    input rst,
    input start,
    output logic [$clog2(WIDTH)-1:0] final_root,
    output logic done
);

// Define local parameters and variables
localparam ODD_WIDTH = $clog2(WIDTH/2)+1;
localparam NUM_ITERS = WIDTH / 2 - 1;

reg [WIDTH-1:0] remainder;
reg [NUM_ITERS:0][ODD_WIDTH-1:0] odds;
reg [WIDTH-1:0] square_root;

// Initialize signals
assign odds[0] = 1;
assign remainder = num;
assign square_root = 0;
assign final_root = 0;

// Implement sequential square root algorithm
always @(posedge clk or posedge rst) begin
    if (rst) begin
        remainder <= 0;
        odds <= {NUM_ITERS{1'b0}};
        square_root <= 0;
        done <= 0;
    end else begin
        // Perform subtraction and count iterations
        for (int i = 0; i < NUM_ITERS; i++) begin
            odds[i+1] <= {NUM_ITERS{1'b0}}[0:i];
            if (remainder < odds[i+1]) begin
                odds[i+1] <= odds[i+1] + 1;
                remainder <= remainder - odds[i+1];
            end else begin
                odds[i+1] <= odds[i+1] * 2;
                remainder <= remainder - odds[i+1] * 2;
            end

            square_root <= square_root + odds[i+1] * 2;
        end

        // Verify that the square root is calculated correctly
        if (remainder == 0) begin
            done <= 1;
        end
    end

endmodule
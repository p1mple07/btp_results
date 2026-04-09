module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    output reg  [WIDTH/2-1:0] final_root,
    output logic done
);
    localparam NUM_BITS = WIDTH / 2;
    reg [NUM_BITS-1:0] remainder;
    reg [NUM_BITS-1:0] first_odd;
    reg [NUM_BITS-1:0] temp_remainder;
    reg [NUM_BITS-1:0] temp_first_odd;
    reg [WIDTH/2-1:0] square_root;
    logic clk_en;

    always @(posedge clk) begin
        if (~rst) begin
            // Reset
            remainder <= 0;
            first_odd <= 1;
            temp_first_odd <= 1;
            square_root <= 0;
            done <= 0;
        end else begin
            if (clk_en) begin
                if (first_odd <= remainder) begin
                    first_odd <= first_odd + 2;
                    remainder <= remainder - first_odd;
                    square_root++;
                end
            end
        end
    end

    assign final_root = square_root;
    assign done = ~rst;
endmodule

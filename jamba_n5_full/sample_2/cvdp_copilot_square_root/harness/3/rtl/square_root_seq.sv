module square_root_seq #(parameter WIDTH = 16) (
    input  wire [WIDTH-1:0] num,
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg [WIDTH/2-1:0] final_root,
    output logic done
);

reg [WIDTH-1:0] remainder;
reg [WIDTH/2-1:0] odd;
reg [WIDTH/2-1:0] square_root;
wire temp_sub;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        finish_state();
    end else {
        if (!start) begin
            finish_state();
        end else begin
            remainder = num;
            odd = 1;
            square_root = 0;
        end
    }
end

always @(posedge clk) begin
    if (done) begin
        done = 0;
        remainder = num;
        odd = 1;
        square_root = 0;
    end else begin
        if (remainder >= odd) begin
            temp_sub = 1'b1;
            remainder = remainder - odd;
            odd = odd + 2;
            square_root = square_root + 1;
        end else begin
            finish_state();
        end
    end
end

assign final_root = square_root;

endmodule

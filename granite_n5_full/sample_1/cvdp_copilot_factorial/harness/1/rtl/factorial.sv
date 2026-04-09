module factorial(
    input logic clk,
    input logic rst_n,
    input logic [4:0] num_in,
    input logic start,
    output logic busy,
    output logic [63:0] fact,
    output logic done
);

localparam INTEGER MAX_ITERATIONS = 64;
logic [63:0] temp;
integer i;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp <= 1;
        busy <= 1;
    end else begin
        if (start &&!busy) begin
            for (i = 0; i < num_in; i = i + 1) begin
                temp <= temp * (i+1);
            end
            fact <= temp;
            done <= 1;
            busy <= 1;
        end else begin
            busy <= 0;
        end
    end
end

endmodule
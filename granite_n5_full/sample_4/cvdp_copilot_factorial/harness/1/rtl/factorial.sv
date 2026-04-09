module factorial (
    input logic clk,
    input logic arst_n,
    input logic [4:0] num_in,
    input logic start,
    output logic busy,
    output logic [$clog2(65)-1:0] fact,
    output logic done
);

logic [4:0] counter;
logic [63:0] product;

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        counter <= 0;
        product <= 1;
        busy <= 0;
        done <= 0;
    end else begin
        if (start &&!busy) begin
            counter <= num_in;
            product <= 1;
            busy <= 1;
            done <= 0;
        end else if (counter > 0) begin
            counter <= counter - 1;
            product <= product * (counter + 1);
        end else if (busy && counter == 0) begin
            done <= 1;
        end
    end
end

assign fact = product;

endmodule
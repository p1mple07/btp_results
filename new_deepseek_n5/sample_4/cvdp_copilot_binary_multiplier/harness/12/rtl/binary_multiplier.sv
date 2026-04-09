module binary_multiplier #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,
    input  logic               valid_in,
    input  logic               rst_n,
    output logic [2*WIDTH-1:0] Product,
    output logic               valid_out
);

integer i, cycle;
logic [2*WIDTH-1:0] sum = 0;

always @posedge rst_n) begin
    sum = 0;
    Product = 0;
    valid_out = 0;
end

always begin
    if (valid_in) begin
        sum = 0;
        Product = 0;
        valid_out = 0;
        i = 0;
        cycle = 0;
        
        #1;
        while (cycle < WIDTH + 2) begin
            if (A[i]) begin
                sum = sum + (B << i);
            end
            i = i + 1;
            cycle = cycle + 1;
        end
    end
end

always @posedge rst_n) begin
    sum = 0;
    Product = 0;
    valid_out = 0;
end

always @* begin
    if (valid_in) begin
        if (rst_n) begin
            sum = 0;
            Product = 0;
            valid_out = 0;
            i = 0;
            cycle = 0;
        end
        #1;
        while (cycle < WIDTH + 2) begin
            if (A[i]) begin
                sum = sum + (B << i);
            end
            i = i + 1;
            cycle = cycle + 1;
        end
    end
end

module
    #1;
    #1;
    #1;
    #1;
    #1;
    #1;
    #1;
    #1;
    #1;
    #1;
endmodule
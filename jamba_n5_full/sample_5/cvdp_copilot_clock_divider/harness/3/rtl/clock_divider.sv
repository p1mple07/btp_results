module clock_divider(
    input  logic clk,
    input  logic rst_n,
    input [1:0] sel,
    output logic clk_out
);

    // Declare state variables for reset handling
    reg [3:0] counter;
    reg is_valid_sel;

    // Initialize counter and reset status
    initial begin
        counter = 0;
        is_valid_sel = 0;
    end

    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 1'b0;
            is_valid_sel <= 0;
        end else begin
            if (sel == 2'b00) begin
                // divide by 2
                clk_out = clk ^ (posedge_event ? clk : 1'b0);
            end else if (sel == 2'b01) begin
                // divide by 4
                clk_out = clk & !clk_out;
            end else if (sel == 2'b10) begin
                // divide by 8
                clk_out = clk_out ^ clk_out;
            end else begin
                clk_out <= 1'b0;
            end
        end
    end

    assign clk_out = (is_valid_sel && ~rst_n) ? clk_out : 1'b0;

endmodule

module dbi_enc #(
    parameter WIDTH = 40
)(
    input wire [WIDTH-1:0] data_in,
    input wire clk,
    input wire rst_n,
    output reg [WIDTH-1:0] data_out,
    output dbi_cntrl [1:0]
);

    reg [WIDTH-1:0] prev_data;
    reg [WIDTH-1:0] current_data;
    reg [WIDTH-1:0] diff_group1;
    reg [WIDTH-1:0] diff_group0;

    assign data_out = invert_group ? ~current_data : current_data;
    assign dbi_cntrl = (diff_group1 > 10) ? {2'b1, 2'b0} : {2'b0, 2'b0};

    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            data_out <= {WIDTH{3'b0}};
            prev_data <= {WIDTH{3'b0}};
            dbi_cntrl = {2'b00};
        } else begin
            diff_group1 = current_data != data_in;
            diff_group0 = prev_data != data_in;
            dbi_cntrl = (diff_group1 > 10) ? {2'b1, 2'b0} : {2'b0, 2'b0};
            data_out = invert_group1 ? ~current_data : current_data;
        end
    end

endmodule

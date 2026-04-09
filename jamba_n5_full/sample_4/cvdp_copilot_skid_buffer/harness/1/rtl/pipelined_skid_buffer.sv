module pipelined_skid_buffer(
    input wire clock,
    input wire rst,

    input wire [3:0] data_i,
    input wire valid_i,
    output wire ready_o,
    output wire valid_o,
    output wire [3:0] data_o,
    input wire ready_i

    );

    reg [3:0] data_reg;
    reg buffer;
    reg [2:0] counter;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            data_reg <= 4'b0;
            buffer <= 0;
            ready_o <= 1'b0;
            valid_o <= 1'b0;
            data_o[3:0] <= 4'b0;
        end else begin
            if (valid_i) begin
                data_reg <= data_i;
                buffer <= 1;
                ready_o <= 1'b1;
                valid_o <= 1'b1;
            end else if (ready_i) begin
                data_o[3:0] <= data_reg;
                valid_o <= 1'b1;
                ready_o <= 1'b0;
            end else
                // do nothing
            if (~ready_i) begin
                buffer <= 0;
            end
        end
    end

    assign ready_o = ready_i;
    assign valid_o = valid_i;
    assign data_o = data_reg;

endmodule

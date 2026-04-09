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
    reg buffer_flag;
    reg buffer_ack;

    always @(posedge clock or posedge rst) begin
        if (rst) {
            data_reg <= 4'b0;
            buffer_flag <= 1'b0;
            buffer_ack <= 1'b0;
        }
    end

    always @(posedge clock or negedge rst) begin
        if (!rst) begin
            data_reg <= 4'b0;
        end else begin
            if (valid_i) begin
                data_reg <= data_i;
            end
        end
    end

    assign ready_o = ready_i;
    assign valid_o = data_reg[3] ? 1'b1 : 1'b0;
    assign data_o = data_reg[3:0];

    assign buffer_ack = ready_i & ~ready_o;

endmodule

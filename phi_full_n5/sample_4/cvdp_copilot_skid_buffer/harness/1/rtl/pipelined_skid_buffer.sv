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

    wire buffer;
    reg [3:0] data_reg;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            data_reg <= 4'b0;
            buffer <= 0;
            ready_o <= 0;
        end else begin
            if (valid_i && !ready_i) begin
                data_reg <= data_i;
                buffer <= 1;
                ready_o <= 0;
            end else if (buffer) begin
                ready_o <= ready_i;
                data_o <= data_reg;
                buffer <= 0;
            end
        end
    end

endmodule

module register(
    input clk,
    input rst,

    input [3:0] data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,
    input  ready_in    
    );

    reg [3:0] data_reg;
    reg valid_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_reg <= 4'b0;
            valid_reg <= 0;
        end else begin
            if (valid_in && !ready_in) begin
                data_reg <= data_in;
                valid_reg <= 1;
            end else if (valid_reg) begin
                ready_out <= ready_in;
                data_out <= data_reg;
                valid_out <= valid_reg;
                valid_reg <= 0;
            end
        end
    end

endmodule

module skid_buffer(

    input  clk,
    input  reset ,

    input  [3:0]i_data,
    input  i_valid,
    output o_ready,

    output [3:0]o_data,
    output o_valid,
    input  i_ready

    );

    wire buffer;
    reg [3:0] data_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_reg <= 4'b0;
            buffer <= 0;
        end else begin
            if (i_valid && !i_ready) begin
                data_reg <= i_data;
                buffer <= 1;
            end else if (buffer) begin
                o_ready <= i_ready;
                o_data <= data_reg;
                o_valid <= 1;
                buffer <= 0;
            end
        end
    end

endmodule

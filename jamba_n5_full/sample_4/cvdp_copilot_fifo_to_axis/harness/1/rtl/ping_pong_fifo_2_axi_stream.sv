module ping_pong_fifo_2_axi_stream #(
    parameter DATA_WIDTH = 24,
    parameter STROBE_WIDTH  = DATA_WIDTH / 8,
    parameter USE_KEEP     = 0,
    parameter USER_IN_DATA  = 1
) (
    input  logic rst,
    input  logic i_block_fifo_rdy,
    output logic o_block_fifo_act,
    input  logic [23:0] i_block_fifo_size,
    input  logic [(DATA_WIDTH + 1) - 1:0] i_block_fifo_data,
    output logic o_block_fifo_stb,
    input  logic [3:0] i_axi_user,
    output logic i_axi_clk,
    output logic [3:0] o_axi_user,
    input  logic i_axi_ready,
    output logic o_axi_data,
    output logic o_axi_last,
    output logic o_axi_valid
);

    // Internal signals
    logic [DATA_WIDTH-1:0] fifo_data_buffer;
    logic fifo_valid_buffer;
    logic fifo_last_buffer;

    always_ff @(posedge i_axi_clk) begin
        if (i_axi_ready) begin
            if (i_block_fifo_rdy) begin
                // FIFO is ready
                fifo_valid_buffer <= 1'b1;
                fifo_last_buffer <= i_block_fifo_data[DATA_WIDTH-1];
                fifo_data_buffer <= i_block_fifo_data;
                o_axi_data <= fifo_data_buffer[DATA_WIDTH-1 : 0];
                o_axi_last <= fifo_last_buffer;
                o_axi_valid <= 1'b1;
            end
        end else begin
            // FIFO not ready, stall
            o_axi_valid <= 1'b0;
            o_axi_last <= 1'b0;
            o_axi_data <= 32'b0;
        end
    end

endmodule

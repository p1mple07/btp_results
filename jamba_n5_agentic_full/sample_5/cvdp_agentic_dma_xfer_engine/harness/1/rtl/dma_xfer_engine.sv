module dma_xfer_engine;

    parameter TRANSFER_SIZE_ENCODING = {2'b00, 2'b01, 2'b10};
    parameter CONTROL_REGISTER_WIDTH = 10;
    parameter ADDRESS_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    input wire clk,
    input wire rstn,
    input wire dma_req,
    input wire bus_grant,
    input wire rd_m,
    input wire wd_m,
    input wire size_m,
    input wire inc_src,
    input wire inc_dst,
    input wire inc_src_en,
    input wire inc_dst_en,
    output reg [31:0] bus_req,
    output reg bus_lock,
    output reg [3:0] cnt,
    output reg [3:0] size_m,
    output reg [3:0] inc_src,
    output reg [3:0] inc_dst,
    output reg [3:0] inc_src_en,
    output reg [3:0] inc_dst_en,
    output reg [31:0] addr_m,
    output reg [31:0] wd_m,
    output reg [31:0] rd_m;

    // internal state
    enum [2:0] state_type = {IDLE, WAIT, TRANSMIT, COMPLETE};
    reg [2:0] state;
    reg [3:0] cnt;
    reg [3:0] size_m;
    reg [3:0] inc_src, inc_dst, inc_src_en, inc_dst_en;
    reg [31:0] addr_m, wd_m, rd_m;

    initial begin
        state = IDLE;
        cnt = 0;
    end

    always @(posedge clk) begin
        if (state == IDLE) begin
            if (dma_req) begin
                state = WAIT;
            end
        end else if (state == WAIT) begin
            if (dma_req) begin
                state = TRANSMIT;
            end
        end else if (state == TRANSMIT) begin
            // Wait for bus grant
            if (bus_grant) begin
                state = COMPLETE;
            end
        end else begin
            // IDLE: wait for dma_req
        end
    end

    assign bus_req = (state == TRANSMIT) ? (rd_m[31:0]) : 4'b0;

    assign wd_m = (state == TRANSMIT) ? (size_m[3:1] && inc_src_en ? size_m[3:1] : 0) : 0;

    // etc... but this is too long.

endmodule

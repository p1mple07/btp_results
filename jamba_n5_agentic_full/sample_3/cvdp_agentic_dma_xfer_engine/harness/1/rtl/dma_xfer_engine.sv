module dma_xfer_engine #(
    parameter DL = 1,
    parameter WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter CONTROL_WIDTH = 10,
    parameter TRANSFER_SIZES = 3,
    parameter INC_ENABLES = 2,
) (
    input CLK,
    input RSTN,
    input DMA_REQ,
    output BUS_GRANT,
    output RD_M,
    input WR_M,
    input ADDR_M,
    input WE_M,
    input WORD_EN,
    input HALF_EN,
    input BYTE_EN,
    input INC_SRCE,
    input INC_DSTE,
    input INCREMENT_SRCE,
    input INCREMENT_DSTE,
    input DATA_IN,
    output DATA_OUT
);

// internal state
localparam STATE_IDLE = 2'b00;
localparam STATE_WB = 2'b01;
localparam STATE_TR = 2'b10;

reg [3:0] state;
reg [2:0] source_size;
reg [2:0] dest_size;
reg [1:0] inc_src;
reg [1:0] inc_dst;

// internal registers
reg [ADDR_WIDTH-1:0] source_adr;
reg [ADDR_WIDTH-1:0] dest_adr;
reg [31:0] source_data;
reg [31:0] dest_data;
reg [CONTROL_WIDTH-1:0] control_reg;

always @(posedge CLK or negedge RSTN) begin
    if (RSTN) begin
        state <= STATE_IDLE;
        source_adr <= 0;
        dest_adr <= 0;
        source_data <= 32'h0;
        dest_data <= 32'h0;
        control_reg <= 32'h0;
    end else begin
        case (state)
            STATE_IDLE: begin
                if (dma_req) begin
                    state <= STATE_WB;
                end
            end

            STATE_WB: begin
                // process read/write
                // ...

                // go to TR
                state <= STATE_TR;
            end

            STATE_TR: begin
                // transfer logic
                state <= STATE_IDLE;
            end
        endcase
    end
end

// slave interface
assign BUS_GRANT = WE_M && bus_lock;
assign RD_M = !WE_M && rd_m;

endmodule

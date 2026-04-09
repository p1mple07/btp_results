module axi_register(
    input clock,
    input rst_n,
    input [ADDR_WIDTH-1:0] awaddr,
    input [DATA_WIDTH-1:0] wdata,
    input [DATA_WIDTH/8-1:0] wstrb,
    input wvalid,
    input bready,
    input [ADDR_WIDTH-1:0] araddr,
    input arvalid,
    input rvalid,
    input done,
    output [1:0] bresp,
    output [1:0] rresp,
    output start,
    output writeback,
    output [20-1:0] beat,
    output [1:0] rvalid_o,
    output [1:0] bvalid_o,
    output [1:0] rvalid_o,
    output [1:0] bvalid_o
);

    // Address decoding logic
    reg [ADDR_WIDTH-1:0] address;
    always @posedge clock or @(!rst_n &posedge clock) begin
        if (rst_n) 
            beat = 0;
            start = 0;
            done = 0;
            ID = 0x00010001;
            beat_o = 0;
            start_o = 0;
            writeback_o = 0;
            $valid = 0;
        else
            address = awaddr;
            if (arvalid) begin
                address = araddr;
                rvalid_o = 1;
            end
            if (wvalid) begin
                beat_o = beat;
                start_o = (wdata & 1);
                writeback_o = (wdata & 1);
                $valid = 1;
            end
        end
    end

    // Beat counter update
    reg [20-1:0] beat_reg;
    always @posedge clock or @(!rst_n &posedge clock) begin
        if ($valid) beat_reg = beat_reg + 1;
    end

    // ID register
    reg [32-1:0] ID;
    always @posedge clock or @(!rst_n &posedge clock) begin
        if ($valid) ID = 0x00010001;
    end

    // Response handling
    case (bresp)
        2'b00: bvalid_o = 0;
        2'b10: bvalid_o = 1;
        default: bvalid_o = 0;
    endcase

    case (rresp)
        2'b00: rvalid_o = 1;
        2'b10: rvalid_o = 0;
        default: rvalid_o = 1;
    endcase
endmodule
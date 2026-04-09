// Write Request
// AXI: Write
// AXI: Write
reg [3:0] write_port_q;
reg [3:0] write_port_r;
reg [`ADDR_SEL_W-1:0] write_cmd_q;
reg [`ADDR_SEL_W-1:0] write_cmd_r;

always @ (posedge clk_i)
begin
    case (write_cmd_r)
        `ADDR_SEL_W'd1:
        begin
            write_cmd_q <= write_cmd_r;
        end
    default:
        begin
            write_cmd_q <= 4'hf;
        end
    endcase
end

always @ (posedge clk_i)
begin
    case (write_cmd_q)
        `ADDR_SEL_W'd1:
        begin
            write_cmd_r <= write_cmd_q;
        end
    default:
        begin
            write_cmd_r <= 4'hf;
        end
    endcase
end

wire write_cmd_accepted_w      = (write_cmd_q == write_cmd_r && write_pending_q != 4'hF) || (write_pending_q == 4'h0);

reg [3:0] write_pending_q;
reg [3:0] write_pending_r;

always @ (posedge clk_i )
if (rst_i)
begin
    write_pending_q <= 4'h0;
    write_cmd_q    <= `ADDR_SEL_W'b0;
end
else 
begin
    write_pending_q <= write_pending_r;

    // Write command accepted
    if (inport_awvalid_i && inport_awready_o && (!write_cmd_accepted_w))
    begin
        write_cmd_q <= 1'b1;
    end
end

wire wr_cmd_accepted_w  = (inport_awvalid_i && inport_awready_o) || write_cmd_accepted_w;

always @ (posedge clk_i )
if (rst_i)
    write_cmd_q <= 1'b0;
else if (inport_awvalid_i && inport_awready_o && !wr_cmd_accepted_w)
    write_cmd_q <= 1'b1;
else if (wr_cmd_accepted_w)
    write_cmd_q <= 1'b0;

// FIFO buffer for out-of-order write commands
reg [ADDR_WIDTH-1:0] write_fifo_addr;
reg [DATA_WIDTH-1:0] write_fifo_data;
reg [3:0] write_fifo_ptr;

always @ (posedge clk_i)
begin
    case (write_cmd_r)
        `ADDR_SEL_W'd1:
        begin
            write_fifo_ptr <= 0;
            write_fifo_addr <= inport_awaddr_i;
            write_fifo_data <= inport_awdata_i;
        end
        default:
            write_fifo_ptr <= write_fifo_ptr + 1;
            write_fifo_addr <= write_fifo_data;
            write_fifo_data <= inport_awdata_i;
    endcase
end

// Backpressure logic
wire write_accept_w      = (write_cmd accepted_w && write_pending_q != 4'hF) || (write_pending_q == 4'h0);

assign outport_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_SEL_W'd0);
assign outport_awaddr_o  = inport_awaddr_i;
assign outport_wvalid_o  = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i || awvalid_q) & (write_port_r == `ADDR_SEL_W'd0);
assign outport_wdata_o   = inport_wdata_i;
assign outport_wstrb_o   = inport_wstrb_i;
assign outport_bready_o  = inport_bready_i;

assign outport_peripheral0_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_SEL_W'd1);
assign outport_peripheral0_awaddr_o  = inport_awaddr_i;
assign outport_peripheral0_wvalid_o  = inport_wvalid_i & ~wvalid_q & ((inport_awvalid_i && write_accept_w) || awvalid_q) & (write_port_r == `ADDR_SEL_W'd1);
assign outport_peripheral0_wdata_o   = inport_wdata_i;
assign outport_peripheral0_wstrb_o   = inport_wstrb_i;
assign outport_peripheral0_bready_o  = inport_bready_i;

reg outport_bvalid_r;
reg [1:0] outport_bresp_r;

always @ *
begin
    case (write_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_bvalid_r = outport_peripheral0_bvalid_i;
        outport_bresp_r  = outport_peripheral0_bresp_i;
    end
    default:
    begin
        outport_bvalid_r = outport_bvalid_i;
        outport_bresp_r  = outport_bresp_i;
    end
    endcase
end

assign inport_bvalid_o  = outport_bvalid_r;
assign inport_bresp_o   = outport_bresp_r;

reg inport_awready_r;
reg inport_wready_r;

always @ *
begin
    case (write_port_r)
    `ADDR_SEL_W'd1:
    begin
        inport_awready_r = outport_peripheral0_awready_i;
        inport_wready_r  = outport_peripheral0_wready_i;
    end
    default:
    begin
        inport_awready_r = outport_awready_i;
        inport_wready_r  = outport_wready_i;
    end
    endcase
end

assign inport_awready_o = write_accept_w & ~awvalid_q & inport_awready_r;
assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;
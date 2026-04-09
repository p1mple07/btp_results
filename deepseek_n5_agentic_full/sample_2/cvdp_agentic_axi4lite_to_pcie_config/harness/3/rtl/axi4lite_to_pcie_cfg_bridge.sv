// Read-related ports
input  logic [ADDR_WIDTH-1:0] araddr;
input  logic        arvalid;
input  logic        arready;
output logic [DATA_WIDTH-1:0] rdata;
output logic        rvalid;
output logic        rready;

typedef enum logic [3:0] {
    IDLE,
    ADDR_CAPTURE,
    PCIE_READ,
    SEND_RESPONSE
} state_t;

always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE: begin
            if (arvalid && !bready) begin
                next_state = ADDR_CAPTURE;
            end
        end

        ADDR_CAPTURE: begin
            next_state = PCIE_READ;
        end

        PCIE_READ: begin
            next_state = SEND_RESPONSE;
        end

        SEND_RESPONSE: begin
            if (rready) begin
                next_state = IDLE;
            end
        end
default: begin
    next_state = IDLE;
endcase
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        awready <= 1'b0;
        wready <= 1'b0;
        bready <= 1'b0;
        pcie_cfg_wr_en <= 1'b0;
        pcie_cfg_wdata <= 32'h0;
        pcie_cfg_addr <= 8'h0;
        awaddr_reg <= 32'h0;
        wdata_reg <= 32'h0;
        wstrb_reg <= 4'h0;
        araddr <= 8'h0;
        arvalid <= 1'b0;
        arready <= 1'b0;
        rdata <= 32'h0;
        rvalid <= 1'b0;
        rready <= 1'b0;
    end else begin
        case (current_state)
            IDLE: begin
                awready <= 1'b0;
                wready <= 1'b0;
                bready <= 1'b0;
                pcie_cfg_wr_en <= 1'b0;
                pcie_cfg_wdata <= 32'h0;
                pcie_cfg_addr <= 8'h0;
                awaddr_reg <= 32'h0;
                wdata_reg <= 32'h0;
                wstrb_reg <= 4'h0;
            end

            ADDR_CAPTURE: begin
                awready <= 1'b1;
                awaddr_reg <= awaddr;
            end

            PCIE_READ: begin
                rdata <= wdata_reg;
                rvalid <= 1'b1;
            end

            SEND_RESPONSE: begin
                pcie_cfg_wr_en <= 1'b0;
                bvalid <= 1'b1;
            end
default: begin
    // Default outputs
end
endcase
end
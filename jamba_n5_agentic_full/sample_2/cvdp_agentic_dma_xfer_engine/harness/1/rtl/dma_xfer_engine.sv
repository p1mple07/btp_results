module dma_xfer_engine;

    parameter WORD_WIDTH = 32,
                          CONTROL_REGISTER_WIDTH = 10;

    typedef struct {
        int cnt;
        int src_size;
        int dst_size;
        int inc_src;
        int inc_dst;
    } ControlRegisters;

    ControlRegisters cr;

    output reg [31:0] wd;
    output reg [31:0] rd;
    output reg [31:0] addr_m;
    output reg [31:0] we_m;
    output reg [31:0] wd_m;
    output reg [31:0] size_m;

    input clk, rstn, dma_req, bus_grant, rd_m;

    always @(posedge clk) begin
        if (rstn) begin
            st <= IDLE;
        end else begin
            st <= WB;
        end
    end

    task wait_for_grant;
        while (!bus_grant) begin
            #1;
        end
    endtask

    task transfer;
        repeat (transfer_count) begin
            // Read phase
            if (addr == 0) begin
                wd = rd;
            end
            else if (addr == 1) begin
                rd = wd;
            end
            else if (addr == 2) begin
                // read next address
            end
            // Write phase
            else if (addr == 0) begin
                rd = wd;
            end
            else if (addr == 1) begin
                wd = rd;
            end
            else if (addr == 2) begin
                // write next address
            end
            // Increment address
            if (inc_src) src_addr += 1;
            if (inc_dst) dest_addr += 1;
        endrepeat
    endtask

endmodule

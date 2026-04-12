`timescale 1ns/1ps

module axi_tap_tb;

    // Parameters
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // Clock and Reset
    logic clk_i;
    logic rst_i;

    // AXI Master Interface (Inputs)
    logic                        inport_awvalid_i;
    logic [ADDR_WIDTH-1:0]       inport_awaddr_i;
    logic                        inport_wvalid_i;
    logic [DATA_WIDTH-1:0]       inport_wdata_i;
    logic [3:0]                  inport_wstrb_i;
    logic                        inport_bready_i;
    logic                        inport_arvalid_i;
    logic [ADDR_WIDTH-1:0]       inport_araddr_i;
    logic                        inport_rready_i;

    // AXI Master Interface (Outputs)
    logic                        inport_awready_o;
    logic                        inport_wready_o;
    logic                        inport_bvalid_o;
    logic [1:0]                  inport_bresp_o;
    logic                        inport_arready_o;
    logic                        inport_rvalid_o;
    logic [DATA_WIDTH-1:0]       inport_rdata_o;
    logic [1:0]                  inport_rresp_o;

    // AXI Default Outport Interface (Defined Missing Wires)
    logic                        outport_awvalid_o;
    logic [ADDR_WIDTH-1:0]       outport_awaddr_o;
    logic                        outport_wvalid_o;
    logic [DATA_WIDTH-1:0]       outport_wdata_o;
    logic [3:0]                  outport_wstrb_o;
    logic                        outport_bready_o;
    logic                        outport_arvalid_o;
    logic [ADDR_WIDTH-1:0]       outport_araddr_o;
    logic                        outport_rready_o;

    // AXI Peripheral 0 Interface (Defined Missing Wires)
    logic                        outport_peripheral0_awvalid_o;
    logic [ADDR_WIDTH-1:0]       outport_peripheral0_awaddr_o;
    logic                        outport_peripheral0_wvalid_o;
    logic [DATA_WIDTH-1:0]       outport_peripheral0_wdata_o;
    logic [3:0]                  outport_peripheral0_wstrb_o;
    logic                        outport_peripheral0_bready_o;
    logic                        outport_peripheral0_arvalid_o;
    logic [ADDR_WIDTH-1:0]       outport_peripheral0_araddr_o;
    logic                        outport_peripheral0_rready_o;

    // AXI Default Outport Interface (Inputs)
    logic                        outport_awready_i;
    logic                        outport_wready_i;
    logic                        outport_bvalid_i;
    logic [1:0]                  outport_bresp_i;
    logic                        outport_arready_i;
    logic                        outport_rvalid_i;
    logic [DATA_WIDTH-1:0]       outport_rdata_i;
    logic [1:0]                  outport_rresp_i;

    // AXI Peripheral 0 Interface (Inputs)
    logic                        outport_peripheral0_awready_i;
    logic                        outport_peripheral0_wready_i;
    logic                        outport_peripheral0_bvalid_i;
    logic [1:0]                  outport_peripheral0_bresp_i;
    logic                        outport_peripheral0_arready_i;
    logic                        outport_peripheral0_rvalid_i;
    logic [DATA_WIDTH-1:0]       outport_peripheral0_rdata_i;
    logic [1:0]                  outport_peripheral0_rresp_i;

    // Internal variables
    logic [1:0]                  expected_response,expected_response_default;
    logic [31:0]                 expected_data;
    logic [31:0] base_address;

    
    // DUT Instance
    axi_tap #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .inport_awvalid_i(inport_awvalid_i),
        .inport_awaddr_i(inport_awaddr_i),
        .inport_awready_o(inport_awready_o),
        .inport_wvalid_i(inport_wvalid_i),
        .inport_wdata_i(inport_wdata_i),
        .inport_wstrb_i(inport_wstrb_i),
        .inport_wready_o(inport_wready_o),
        .inport_bready_i(1'b1),
        .inport_bvalid_o(inport_bvalid_o),
        .inport_bresp_o(inport_bresp_o),
        .inport_arvalid_i(inport_arvalid_i),
        .inport_araddr_i(inport_araddr_i),
        .inport_arready_o(inport_arready_o),
        .inport_rready_i(inport_rready_i),
        .inport_rvalid_o(inport_rvalid_o),
        .inport_rdata_o(inport_rdata_o),
        .inport_rresp_o(inport_rresp_o),
        .outport_awready_i(1'b1),
        .outport_awvalid_o(outport_awvalid_o),
        .outport_awaddr_o(outport_awaddr_o),
        .outport_wready_i(1'b1),
        .outport_wvalid_o(outport_wvalid_o),
        .outport_wdata_o(outport_wdata_o),
        .outport_wstrb_o(outport_wstrb_o),
        .outport_bvalid_i(outport_bvalid_i),
        .outport_bresp_i(outport_bresp_i),
        .outport_bready_o(outport_bready_o),
        .outport_arready_i(1'b1),
        .outport_arvalid_o(outport_arvalid_o),
        .outport_araddr_o(outport_araddr_o),
        .outport_rvalid_i(outport_rvalid_i),
        .outport_rdata_i(outport_rdata_i),
        .outport_rresp_i(outport_rresp_i),
        .outport_rready_o(outport_rready_o),
        .outport_peripheral0_awready_i(1'b1),
        .outport_peripheral0_awvalid_o(outport_peripheral0_awvalid_o),
        .outport_peripheral0_awaddr_o(outport_peripheral0_awaddr_o),
        .outport_peripheral0_wready_i(1'b1),
        .outport_peripheral0_wvalid_o(outport_peripheral0_wvalid_o),
        .outport_peripheral0_wdata_o(outport_peripheral0_wdata_o),
        .outport_peripheral0_wstrb_o(outport_peripheral0_wstrb_o),
        .outport_peripheral0_bresp_i(outport_peripheral0_bresp_i),
        .outport_peripheral0_bvalid_i(outport_peripheral0_bvalid_i),
        .outport_peripheral0_bready_o(outport_peripheral0_bready_o),
        .outport_peripheral0_arready_i(1'b1),
        .outport_peripheral0_arvalid_o(outport_peripheral0_arvalid_o),
        .outport_peripheral0_araddr_o(outport_peripheral0_araddr_o),
        .outport_peripheral0_rresp_i(outport_peripheral0_rresp_i),
        .outport_peripheral0_rvalid_i(outport_peripheral0_rvalid_i),
        .outport_peripheral0_rdata_i(outport_peripheral0_rdata_i),
        .outport_peripheral0_rready_o(outport_peripheral0_rready_o)
    );

    always #5 clk_i = ~clk_i;

    initial begin
        clk_i = 0;
        rst_i = 1;
        inport_awvalid_i = 0;
        inport_awaddr_i = 0;
        inport_wvalid_i = 0;
        inport_wdata_i = 0;
        inport_wstrb_i = 0;
        inport_arvalid_i = 0;
        inport_araddr_i = 0;
        inport_rready_i = 1;
        outport_peripheral0_bvalid_i = 0;

        #20;
        rst_i = 0;
        $display("[%0t] Reset deasserted.", $time);
        #125;
        inport_awvalid_i = 1;
        inport_awaddr_i = 32'h9000_0000;
        inport_wvalid_i = 1;
        inport_wdata_i = 32'hDEAD_BEEF;
        inport_wstrb_i = 4'hF;
        expected_response = 2'b11;

        #20;
        $display("[%0t] inport_awvalid_i: %b, inport_awaddr_i: %h, inport_awready_o: %b", $time, inport_awvalid_i, inport_awaddr_i, inport_awready_o);
        $display("[%0t] outport_peripheral0_awvalid_o: %b, outport_peripheral0_awaddr_o: %h", $time, outport_peripheral0_awvalid_o, outport_peripheral0_awaddr_o );
        $display("[%0t] inport_wvalid_i: %b, inport_wdata_i: %h", $time, inport_wvalid_i, inport_wdata_i );
        assert(outport_peripheral0_awaddr_o == inport_awaddr_i) else $error("Wrong awaddr");
        assert(outport_peripheral0_awvalid_o == 1) else $error("Wrong awvalid");
        assert(outport_peripheral0_wdata_o == inport_wdata_i) else $error("Wrong wdata");
        assert(outport_peripheral0_wvalid_o == 1) else $error("Wrong wvalid");
        assert(outport_peripheral0_wstrb_o == inport_wstrb_i) else $error("Wrong wstrb");

        #10
        outport_peripheral0_bresp_i = expected_response;
        outport_peripheral0_bvalid_i = 1;
        #10
        assert(inport_bvalid_o == 1) else $error("Wrong bvalid");
        assert(inport_bresp_o == expected_response) else $error("Wrong bresp");
        $display("[%0t] inport_bvalid_o: %b,", $time, inport_bvalid_o);
        $display("[%0t] inport_bresp_o: %b,  expected_response: %b", $time, inport_bresp_o,expected_response);

        inport_wvalid_i = 1;
        inport_wdata_i = 32'hDEAD_BEEF;
        inport_wstrb_i = 4'hF;
        #10
        $display("[%0t] inport_wvalid_i: %b,  inport_wdata_i: %h,  inport_wstrb_i: %h", $time, inport_wvalid_i,inport_wdata_i, inport_wstrb_i);
        assert(inport_wdata_i == outport_peripheral0_wdata_o) else $error("Wrong wdata");
        assert(inport_wvalid_i == outport_peripheral0_wvalid_o) else $error("Wrong wvalid");
        assert(inport_wstrb_i == outport_peripheral0_wstrb_o) else $error("Wrong wstrb");

        inport_awvalid_i = 1;
        inport_awaddr_i = 32'h4000_0000;
        inport_wvalid_i = 1;
        inport_wdata_i = 32'hBEEF_FEED;
        inport_wstrb_i = 4'hF;
        expected_response_default = 2'b10;

        #20;
        $display("[%0t] inport_awvalid_i: %b, inport_awaddr_i: %h, inport_awready_o: %b", $time, inport_awvalid_i, inport_awaddr_i, inport_awready_o);
        $display("[%0t] outport_awvalid_o: %b, outport_awaddr_o: %h", $time, outport_awvalid_o, outport_awaddr_o );
        assert(outport_awaddr_o == inport_awaddr_i) else $error("Wrong awaddr");
        assert(outport_awvalid_o == 1) else $error("Wrong awvalid");
        assert(outport_wdata_o == inport_wdata_i) else $error("Wrong wdata");
        assert(outport_wvalid_o == 1) else $error("Wrong wvalid");
        assert(outport_wstrb_o == inport_wstrb_i) else $error("Wrong wstrb");

        #10
        outport_bresp_i = expected_response_default;
        outport_bvalid_i = 1;
        #10
        assert(inport_bvalid_o == 1) else $error("Wrong bvalid");
        assert(inport_bresp_o == expected_response_default) else $error("Wrong bresp");
        $display("[%0t] inport_bvalid_o: %b,", $time, inport_bvalid_o);
        $display("[%0t] inport_bresp_o: %b,  expected_response_default: %b", $time, inport_bresp_o,expected_response_default);

        inport_wvalid_i = 1;
        inport_wdata_i = 32'hBEEF_FEED;
        inport_wstrb_i = 4'hE;
        #10
        $display("[%0t] inport_wvalid_i: %b,  inport_wdata_i: %h,  inport_wstrb_i: %h", $time, inport_wvalid_i,inport_wdata_i, inport_wstrb_i);
        assert(inport_wdata_i == outport_wdata_o) else $error("Wrong wdata");
        assert(inport_wvalid_i == outport_wvalid_o) else $error("Wrong wvalid");
        assert(inport_wstrb_i == outport_wstrb_o) else $error("Wrong wstrb");

        #30
        outport_peripheral0_rvalid_i = 1'b1;
        outport_peripheral0_rdata_i = 32'h12345678;
        outport_peripheral0_rresp_i = 2'b11;

        outport_rvalid_i = 1'b1;
        outport_rdata_i = 32'h87654321;
        outport_rresp_i = 2'b10;
        #20

        inport_arvalid_i = 1;
        inport_araddr_i = 32'h4000_0000;
        #10
        $display("[%0t] inport_rdata_o: %h, inport_rvalid_o: %h, inport_rresp_o: %b", $time, inport_rdata_o, inport_rvalid_o, inport_rresp_o);
        assert(inport_rdata_o == outport_rdata_i) else $error("Wrong rdata");
        assert(inport_rvalid_o == 1) else $error("Wrong rvalid");

        $display("[%0t] inport_araddr_i: %h", $time, inport_araddr_i);

        if (inport_araddr_i >= 32'h8000_0000 ) begin
            assert(inport_arvalid_i == outport_peripheral0_arvalid_o) else $error("Wrong arvalid");
            assert(inport_araddr_i == outport_peripheral0_araddr_o) else $error("Wrong araddr");
        end
        if (inport_araddr_i < 32'h8000_0000 ) begin
            assert(inport_arvalid_i == outport_arvalid_o) else $error("Wrong arvalid");
            assert(inport_araddr_i == outport_araddr_o) else $error("Wrong araddr");
        end

        inport_arvalid_i = 1;
        inport_araddr_i = 32'h9000_0000;
        #20
 
        $display("[%0t] outport_peripheral0_rdata_i: %h", $time, outport_peripheral0_rdata_i);
        $display("[%0t] inport_rdata_o: %h, inport_rvalid_o: %h, inport_rresp_o: %b", $time, inport_rdata_o, inport_rvalid_o, inport_rresp_o);
        assert(inport_rdata_o == outport_peripheral0_rdata_i) else $error("Wrong rdata");

        if (inport_araddr_i >= 32'h8000_0000 ) begin
            assert(inport_arvalid_i == outport_peripheral0_arvalid_o) else $error("Wrong arvalid");
            assert(inport_araddr_i == outport_peripheral0_araddr_o) else $error("Wrong araddr");
        end
        else begin
            assert(inport_arvalid_i == outport_arvalid_o) else $error("Wrong arvalid");
            assert(inport_araddr_i == outport_araddr_o) else $error("Wrong araddr");
        end

        base_address = 32'h8000_0000;

        for (int i = 0; i < 10; i++) begin

            outport_rvalid_i = 1'b1;
            outport_rdata_i = 32'hFFFF_0000 + (i * 32'h0000_000F);
            outport_rresp_i = 2'b11;
            outport_peripheral0_rvalid_i = 1'b1;
            outport_peripheral0_rdata_i = 32'h1111_0000 + (i * 32'h0000_000F);
            outport_peripheral0_rresp_i = 2'b10;

            inport_araddr_i = base_address + (i - 5) * 32'h00000010;
            inport_arvalid_i = 1;

            #10;
            if (inport_araddr_i >= 32'h8000_0000 ) begin
                assert(inport_arvalid_i == outport_peripheral0_arvalid_o) else $error("Wrong arvalid");
                assert(inport_araddr_i == outport_peripheral0_araddr_o) else $error("Wrong araddr");
            end
            else begin
                assert(inport_arvalid_i == outport_arvalid_o) else $error("Wrong arvalid");
                assert(inport_araddr_i == outport_araddr_o) else $error("Wrong araddr");
            end
            $display("[%0t] Iteration: %0d, inport_rvalid_o: %h, inport_rdata_o: %h, inport_rresp_o: %b", $time, i, inport_rvalid_o, inport_rdata_o, inport_rresp_o);
        end

        for (int i = 0; i < 20; i++) begin
            inport_awaddr_i = $random;
            inport_araddr_i = $random;
            inport_wdata_i = $random;
            inport_wstrb_i = $random;
            if ($urandom_range(0, 1)) begin
                write_transaction(inport_awaddr_i, inport_wdata_i, inport_wstrb_i, 2'b00);
            end else begin
                read_transaction(inport_araddr_i);
            end
        end

    repeat (100) begin
        fork
            write_transaction(32'h8000_1000, 32'hA5A5A5A5, 4'hF, 2'b00);
            read_transaction(32'h4000_2000);
        join
    end

        #100;
        $display("[%0t] Simulation complete.", $time);
        $finish;
    end

    task automatic write_transaction(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data, input [3:0] wstrb, input [1:0] expected_resp);
    inport_awvalid_i = 1;
    inport_awaddr_i = addr;
    inport_wvalid_i = 1;
    inport_wdata_i = data;
    inport_wstrb_i = wstrb;
    expected_resp = 2'b11;

    outport_peripheral0_bvalid_i = 1;
    outport_peripheral0_bresp_i = expected_resp;
    outport_bvalid_i = 1;
    outport_bresp_i = expected_resp;

    #10
    $display("[%0t] inport_bresp_o", $time, inport_bresp_o);

    assert(inport_bresp_o == expected_resp) else $error("Write Response Mismatch!");

    outport_peripheral0_bvalid_i = 0;
    endtask

    task automatic read_transaction(input [ADDR_WIDTH-1:0] addr);
        logic [1:0] expected_resp;
        logic [31:0] expected_data;

        outport_peripheral0_rvalid_i = 1'b1;
        outport_peripheral0_rdata_i = 32'h12345678;
        outport_peripheral0_rresp_i = 2'b11;
        outport_rvalid_i = 1'b1;
        outport_rdata_i = 32'h87654321;
        outport_rresp_i = 2'b10;
        #20
        inport_arvalid_i = 1;
        inport_araddr_i = addr;

        if (addr >= 32'h8000_0000 ) begin
            expected_data = outport_peripheral0_rdata_i;
            expected_resp = outport_peripheral0_rresp_i;
        end
        else begin
            expected_data = outport_rdata_i;
            expected_resp = outport_rresp_i;
        end

        #10
        $display("[%0t] addr %h  ", $time, inport_araddr_i);
        $display("[%0t] inport_rdata_o %h,inport_rresp_o %h,inport_rvalid_o %h ", $time, inport_rdata_o, inport_rresp_o ,inport_rvalid_o);
        $display("[%0t] expected_data %h,expected_resp %h ", $time, expected_data,expected_resp);
        assert(inport_rdata_o == expected_data) else $error("Read Data Mismatch!");
        assert(inport_rresp_o == expected_resp) else $error("Read Response Mismatch!");

        outport_rvalid_i = 0;
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, axi_tap_tb);
    end

endmodule
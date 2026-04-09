module axi_register #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (
    input clk_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    input awvalid_i,
    input [DATA_WIDTH-1:0] wdata_i,
    input wvalid_i,
    input [DATA_WIDTH-1:0] wstrb_i,
    input bready_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    input arvalid_i,
    output reg rready_o,
    output reg [DATA_WIDTH-1:0] rdata_o,
    output reg rvalid_o,
    output [1:0] bresp_o,
    output reg bvalid_o,
    output reg arready_o,
    output reg [ADDR_WIDTH-1:0] beat_o,
    output reg start_o,
    output reg writeback_o
);

    // Local variables
    logic [20:0] beat;
    logic done;
    logic writeback;
    logic [31:0] id;

    // Behavioral description
    always @(posedge clk_i or posedge rst_n_i) begin
        if (rst_n_i) begin
            beat <= 0;
            done <= 1'b0;
            writeback <= 1'b0;
            id <= 32'h00000001; // Default ID value
        end else begin
            if (arready_o) begin
                // Read address phase
                if (arvalid_i) begin
                    // Read data phase
                    if (wvalid_i) begin
                        // Write data phase
                        if (awvalid_i) begin
                            // Address decoding
                            case (awaddr_i)
                                // Write to Beat Counter
                                [ADDR_WIDTH-1:0] addr_beat = awaddr_i;
                                beat = (wdata_i >> addr_beat) & ((1 << 20) - 1);

                                // Set Start Signal
                                if (wdata_i[0] && wstrb_i) begin
                                    start_o = 1;
                                end

                                // Set Done Signal
                                if (wdata_i[0]) begin
                                    done = 1'b0;
                                end

                                // Set Writeback Signal
                                if (wdata_i[0] && wstrb_i) begin
                                    writeback = 1;
                                end

                                // Write to ID Register (should generate error)
                                if (awdata_i == 32'h00000001) begin
                                    bresp_o = 2'b10;
                                end
                            end
                        end
                    end
                end
                arready_o = 1'b0;
            end
        end
    end

    // Output logic
    assign beat_o = beat;
    assign done = done;
    assign writeback_o = writeback;
    assign id = id;

    // Write response
    always @(posedge bready_i) begin
        if (bready_i) begin
            bresp_o = (bvalid_o && (bresp_o == 2'b00));
        end
    end

    // Read response
    always @(posedge rready_o) begin
        if (rready_o) begin
            rdata_o = (rvalid_o && (rdata_o == id));
            rvalid_o = 1'b0;
        end
    end

endmodule

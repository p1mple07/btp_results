module axi_register (
    input wire clk,
    input wire rst_n,
    input wire [31:0] awaddr,
    input wire awvalid,
    input wire [31:0] wdata,
    input wire wvalid,
    input wire [7:0] wstrb,
    input wire bready,
    input wire [31:0] araddr,
    input wire arvalid,
    output reg rready,
    output reg [31:0] beat,
    output reg start,
    output reg done,
    output reg writeback,
    output reg [31:0] id
);

    // Internal signals
    reg [20:0] beat_counter;

    // Handshaking signals
    reg awready, wready;
    reg bresp, rresp;
    reg bvalid;

    // Register map
    reg [20:0] beat_reg;
    reg [31:0] id_reg;

    // State machine
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            beat_counter <= 0;
            start <= 0;
            done <= 0;
            writeback <= 0;
            beat <= 0;
            id_reg <= 0;
        end else begin
            case (awvalid)
               1'b1: begin
                    if (awready) begin
                        // Address phase
                        awaddr_i = awaddr;
                        awready <= 0;

                        // Data phase
                        wdata_i = wdata;
                        wvalid_i = wvalid;
                        wready <= 0;

                        if (wvalid && wstrb) begin
                            // Full write
                            if (wdata[0] == 1'b1) begin
                                beat_counter <= wdata;
                                start <= 1'b1;
                                writeback <= 1'b1;
                                done <= 0;
                            end else begin
                                done <= 1'b1;
                                writeback <= 1'b0;
                            end
                        end else if (wvalid) begin
                            // Partial write
                            done <= 1'b0;
                        end
                    end
                end

               1'b1: begin
                    if (arready) begin
                        // Address phase
                        araddr_i = araddr;
                        arready <= 0;

                        // Data phase
                        if (arvalid) begin
                            // Read operation
                            rdata_o <= beat_counter;
                            rvalid_o <= 1'b1;
                            rready <= 1'b1;
                        end else begin
                            // Invalid address
                            rresp_o <= 1'b1;
                            rready <= 1'b0;
                        end
                    end
                end
            endcase
        end

        // Completion phase
        case ({awvalid, wvalid, arvalid})
           1'b11: begin
                bresp_o <= 2'b00;
                bvalid_o <= 1'b1;
            end
            1'b10: begin
                bresp_o <= 2'b10;
                bvalid_o <= 1'b1;
            end
            1'b01: begin
                bresp_o <= 2'b10;
                bvalid_o <= 1'b1;
            end
            1'b00: begin
                bresp_o <= 2'b00;
                bvalid_o <= 1'b1;
            end
        endcase
    end

    // ID register read-only
    always @(*) begin
        if (id_reg) begin
            id_reg <= 32'h0001_0001; // Fixed ID value
        end else begin
            id_reg <= 32'hzzzz_zzzz; // Default value for read-only registers
        end
    end

    // Reset functionality
    always @(rst_n) begin
        beat_counter <= 0;
        start <= 0;
        done <= 0;
        writeback <= 0;
        beat <= 0;
        id <= 32'hzzzz_zzzz; // Default value for registers
    end

endmodule

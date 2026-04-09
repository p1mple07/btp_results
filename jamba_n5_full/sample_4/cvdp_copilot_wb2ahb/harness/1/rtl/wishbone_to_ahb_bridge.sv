module wishbone_to_ahb_bridge (
    input wire clk_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire [3:0] sel_i[3:0],
    input wire we_i,
    input wire addr_i[31:0],
    input wire data_i[31:0],
    output reg data_o[31:0],
    output reg ack_o,
    output htrans[1:0],
    output hsize[2:0],
    output hburst[2:0],
    output hwrite,
    output haddr[31:0],
    output hwdata[31:0]
);

// Internal state machine
localparam HIDLE = 2'b00;
localparam NON_SEQUENTIAL = 2'b01;
localparam BUSY = 2'b10;

reg [2:0] state;
always @(posedge clk_i) begin
    if (rst_i) begin
        state <= HIDLE;
        data_o <= 0;
        ack_o <= 0;
        htrans[1:0] <= 2'b00;
        hsize[2:0] <= 2'b00;
        hburst[2:0] <= 2'b00;
        hwrite <= 0;
        haddr[31:0] <= 32'h0;
        hwdata[31:0] <= 0;
    end else begin
        case (state)
            HIDLE: begin
                if (hready) begin
                    state <= NON_SEQUENTIAL;
                end
            end
            NON_SEQUENTIAL: begin
                if (we_i && stb_i) begin
                    // Start transaction
                    state <= BUSY;
                end
            end
            BUSY: begin
                if (cyc_i) begin
                    // Process cycle
                    // ...
                end
            end
        endcase
    end
end

// Inside BUSY state, handle the Wishbone transaction
always @(*) begin
    if (state == BUSY) begin
        // Get Wishbone transaction data
        // sel_i[3:0] selects 4 bytes
        // We need to output data_o as AHB data, and ack_o after completion
        // But how to handle the conversion.

        // Since this is a skeleton, we can just output dummy values for demonstration.
        // In real code, we would need to map sel_i to the correct address and data.

        // For simplicity, we can set data_o to 0 and ack_o to 0.
        data_o <= 0;
        ack_o <= 1;
    end
end

// End of module
endmodule

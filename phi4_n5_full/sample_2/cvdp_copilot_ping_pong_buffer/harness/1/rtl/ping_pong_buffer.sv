module ping_pong_buffer (
    input logic clk,
    input logic rst_n,
    input logic write_enable,
    input logic read_enable,
    input logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic buffer_full,
    output logic buffer_empty,
    output reg buffer_select
);

    localparam DEPTH = 256;
    localparam ADDR_WIDTH = 8;

    // Dual buffer pointer registers
    reg [ADDR_WIDTH-1:0] wp0, rp0;
    reg [ADDR_WIDTH-1:0] wp1, rp1;

    // Memory output wires
    wire [7:0] data_out0;
    wire [7:0] data_out1;

    // Write enable signals for the dual_port_memory instances
    wire we0, we1;

    // Dual port memory instantiations
    dual_port_memory memory0 (
        .clk(clk),
        .we(we0),
        .write_addr(wp0),
        .din(data_in),
        .read_addr(rp0),
        .dout(data_out0)
    );

    dual_port_memory memory1 (
        .clk(clk),
        .we(we1),
        .write_addr(wp1),
        .din(data_in),
        .read_addr(rp1),
        .dout(data_out1)
    );

    // Compute write enable for the active memory
    assign we0 = (buffer_select == 0) ? (write_enable && !(((wp0 == DEPTH-1) ? (rp0 == 0) : (wp0 + 1 == rp0)))) : 0;
    assign we1 = (buffer_select == 1) ? (write_enable && !(((wp1 == DEPTH-1) ? (rp1 == 0) : (wp1 + 1 == rp1)))) : 0;

    // Full and empty conditions for each buffer
    wire full0 = ((wp0 == DEPTH-1) ? (rp0 == 0) : (wp0 + 1 == rp0));
    wire empty0 = (wp0 == rp0);
    wire full1 = ((wp1 == DEPTH-1) ? (rp1 == 0) : (wp1 + 1 == rp1));
    wire empty1 = (wp1 == rp1);

    // Active buffer conditions
    wire active_full = (buffer_select == 0) ? full0 : full1;
    wire active_empty = (buffer_select == 0) ? empty0 : empty1;

    // Output assignments
    assign buffer_full = active_full;
    assign buffer_empty = active_empty;
    assign data_out = (buffer_select == 0) ? data_out0 : data_out1;

    // Control logic and pointer management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wp0 <= 0;
            rp0 <= 0;
            wp1 <= 0;
            rp1 <= 0;
            buffer_select <= 0;
        end else begin
            // Check for buffer switching conditions
            if (write_enable && active_full) begin
                buffer_select <= ~buffer_select;
            end else if (read_enable && active_empty) begin
                buffer_select <= ~buffer_select;
            end else begin
                // Update pointers for the active buffer only when no switching occurs
                if (buffer_select == 0) begin
                    if (write_enable && !full0) begin
                        wp0 <= wp0 + 1;
                    end
                    if (read_enable && !empty0) begin
                        rp0 <= rp0 + 1;
                    end
                end else begin
                    if (write_enable && !full1) begin
                        wp1 <= wp1 + 1;
                    end
                    if (read_enable && !empty1) begin
                        rp1 <= rp1 + 1;
                    end
                end
            end
        end
    end

endmodule

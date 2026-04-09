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

    // Pointers for the two buffers
    logic [ADDR_WIDTH-1:0] wr_ptr0, rd_ptr0;
    logic [ADDR_WIDTH-1:0] wr_ptr1, rd_ptr1;

    // Outputs from the dual port memories
    logic [7:0] data_out0, data_out1;

    // Full and empty flags for each buffer
    assign full0 = ((wr_ptr0 + 1) % DEPTH == rd_ptr0);
    assign empty0 = (wr_ptr0 == rd_ptr0);
    assign full1 = ((wr_ptr1 + 1) % DEPTH == rd_ptr1);
    assign empty1 = (wr_ptr1 == rd_ptr1);

    // Dual port memories instantiation
    dual_port_memory memory0 (
        .clk(clk),
        .we((buffer_select == 1) ? write_enable : 1'b0),
        .write_addr((buffer_select == 1) ? wr_ptr0 : 8'd0),
        .din((buffer_select == 1) ? data_in : 8'd0),
        .read_addr(rd_ptr0),
        .dout(data_out0)
    );

    dual_port_memory memory1 (
        .clk(clk),
        .we((buffer_select == 0) ? write_enable : 1'b0),
        .write_addr((buffer_select == 0) ? wr_ptr1 : 8'd0),
        .din((buffer_select == 0) ? data_in : 8'd0),
        .read_addr(rd_ptr1),
        .dout(data_out1)
    );

    // Output assignment
    assign data_out = (buffer_select == 0) ? data_out0 : data_out1;
    assign buffer_full = (buffer_select == 0) ? full1 : full0;
    assign buffer_empty = (buffer_select == 0) ? empty0 : empty1;

    // Sequential logic for pointer management and buffer switching
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr0 <= 0;
            rd_ptr0 <= 0;
            wr_ptr1 <= 0;
            rd_ptr1 <= 0;
            buffer_select <= 0;
        end else begin
            // Write operation: update write pointer for the active write memory
            if (write_enable) begin
                if (buffer_select == 0) begin
                    // In mode 0, memory1 is active for writing
                    if (!full1) begin
                        wr_ptr1 <= (wr_ptr1 + 1) % DEPTH;
                    end
                end else begin
                    // In mode 1, memory0 is active for writing
                    if (!full0) begin
                        wr_ptr0 <= (wr_ptr0 + 1) % DEPTH;
                    end
                end
            end

            // Read operation: update read pointer for the active read memory
            if (read_enable) begin
                if (buffer_select == 0) begin
                    // In mode 0, memory0 is active for reading
                    if (!empty0) begin
                        rd_ptr0 <= (rd_ptr0 + 1) % DEPTH;
                    end
                end else begin
                    // In mode 1, memory1 is active for reading
                    if (!empty1) begin
                        rd_ptr1 <= (rd_ptr1 + 1) % DEPTH;
                    end
                end
            end

            // Buffer switching logic:
            // Toggle buffer_select if the active write buffer becomes full
            if ((buffer_select == 0 && full1) || (buffer_select == 1 && full0)) begin
                buffer_select <= ~buffer_select;
            end
            // Also, toggle if the active read buffer is empty and a read was requested
            if ((buffer_select == 0 && empty0 && read_enable) || (buffer_select == 1 && empty1 && read_enable)) begin
                buffer_select <= ~buffer_select;
            end
        end
    end

endmodule
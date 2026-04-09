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

    // Pointer registers for each memory bank
    logic [ADDR_WIDTH-1:0] wr_ptr0, rd_ptr0;
    logic [ADDR_WIDTH-1:0] wr_ptr1, rd_ptr1;

    // Memory interface signals
    logic we0, we1;
    logic [ADDR_WIDTH-1:0] write_addr0, write_addr1;
    logic [7:0] din0, din1;
    logic [ADDR_WIDTH-1:0] read_addr0, read_addr1;
    logic [7:0] mem0_dout, mem1_dout;

    // Instantiate dual_port_memory modules
    dual_port_memory memory0 (
        .clk(clk),
        .we(we0),
        .write_addr(write_addr0),
        .din(din0),
        .read_addr(read_addr0),
        .dout(mem0_dout)
    );

    dual_port_memory memory1 (
        .clk(clk),
        .we(we1),
        .write_addr(write_addr1),
        .din(din1),
        .read_addr(read_addr1),
        .dout(mem1_dout)
    );

    // Output assignment: data_out comes from the inactive bank (the one not currently being written)
    assign data_out = (buffer_select == 0) ? mem1_dout : mem0_dout;

    // Main sequential block for pointer management and control logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr0 <= 0;
            rd_ptr0 <= 0;
            wr_ptr1 <= 0;
            rd_ptr1 <= 0;
            buffer_select <= 0;
            buffer_full <= 0;
            buffer_empty <= 1;
        end else begin
            if (buffer_select == 0) begin
                // Active bank is 0 (writing), inactive bank is 1 (reading)
                // Write operation: only write if active bank is not full
                if (write_enable && (wr_ptr0 != (rd_ptr0 + 1) % DEPTH)) begin
                    wr_ptr0 <= wr_ptr0 + 1;
                end

                // Read operation from inactive bank if not empty
                if (read_enable && (rd_ptr1 != wr_ptr1)) begin
                    rd_ptr1 <= rd_ptr1 + 1;
                end

                // Update buffer status for active bank 0
                buffer_full <= (wr_ptr0 == (rd_ptr0 + 1) % DEPTH);
                buffer_empty <= (rd_ptr1 == wr_ptr1);

                // Toggle bank selection when either bank reaches end of buffer
                if (wr_ptr0 == DEPTH - 1 || rd_ptr1 == DEPTH - 1) begin
                    buffer_select <= 1;
                end
            end else begin
                // Active bank is 1 (writing), inactive bank is 0 (reading)
                if (write_enable && (wr_ptr1 != (rd_ptr1 + 1) % DEPTH)) begin
                    wr_ptr1 <= wr_ptr1 + 1;
                end

                if (read_enable && (rd_ptr0 != wr_ptr0)) begin
                    rd_ptr0 <= rd_ptr0 + 1;
                end

                buffer_full <= (wr_ptr1 == (rd_ptr1 + 1) % DEPTH);
                buffer_empty <= (rd_ptr0 == wr_ptr0);

                if (wr_ptr1 == DEPTH - 1 || rd_ptr0 == DEPTH - 1) begin
                    buffer_select <= 0;
                end
            end
        end
    end

    // Drive memory interface signals based on current bank selection
    always_comb begin
        if (buffer_select == 0) begin
            // Active bank: memory0 for writing, memory1 for reading
            we0 = write_enable && (wr_ptr0 != (rd_ptr0 + 1) % DEPTH);
            write_addr0 = wr_ptr0;
            din0 = data_in;
            read_addr1 = rd_ptr1;
            we1 = 1'b0;
        end else begin
            // Active bank: memory1 for writing, memory0 for reading
            we1 = write_enable && (wr_ptr1 != (rd_ptr1 + 1) % DEPTH);
            write_addr1 = wr_ptr1;
            din1 = data_in;
            read_addr0 = rd_ptr0;
            we0 = 1'b0;
        end
    end

endmodule
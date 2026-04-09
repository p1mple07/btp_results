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

    // Pointers for the two memory banks
    logic [ADDR_WIDTH-1:0] write_ptr0, read_ptr0;
    logic [ADDR_WIDTH-1:0] write_ptr1, read_ptr1;

    // Intermediate read data from each memory
    logic [7:0] data_out0, data_out1;

    // Control signals for dual port memories
    wire we0, we1;
    wire [7:0] din0, din1;
    assign we0 = (buffer_select == 1) ? write_enable : 1'b0;
    assign we1 = (buffer_select == 0) ? write_enable : 1'b0;
    assign din0 = (buffer_select == 1) ? data_in : 8'd0;
    assign din1 = (buffer_select == 0) ? data_in : 8'd0;

    // Instantiate dual port memories
    dual_port_memory memory0 (
        .clk(clk),
        .we(we0),
        .write_addr(write_ptr0),
        .din(din0),
        .read_addr(read_ptr0),
        .dout(data_out0)
    );

    dual_port_memory memory1 (
        .clk(clk),
        .we(we1),
        .write_addr(write_ptr1),
        .din(din1),
        .read_addr(read_ptr1),
        .dout(data_out1)
    );

    // Data output: select based on active read buffer
    assign data_out = (buffer_select == 1) ? data_out0 : data_out1;

    // Buffer status signals based on the active read buffer
    assign buffer_empty = (buffer_select == 1) ? (read_ptr0 == write_ptr0) : (read_ptr1 == write_ptr1);
    assign buffer_full  = (buffer_select == 1) ? ((((write_ptr0 + 1) % DEPTH) == read_ptr0)) : ((((write_ptr1 + 1) % DEPTH) == read_ptr1));

    // Next pointer calculations
    logic [ADDR_WIDTH-1:0] next_write_ptr0, next_read_ptr0;
    logic [ADDR_WIDTH-1:0] next_write_ptr1, next_read_ptr1;
    assign next_write_ptr0 = (write_ptr0 + 1) % DEPTH;
    assign next_read_ptr0  = (read_ptr0 + 1) % DEPTH;
    assign next_write_ptr1 = (write_ptr1 + 1) % DEPTH;
    assign next_read_ptr1  = (read_ptr1 + 1) % DEPTH;

    // State machine for managing the ping-pong buffer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr0 <= 0;
            read_ptr0  <= 0;
            write_ptr1 <= 0;
            read_ptr1  <= 0;
            buffer_select <= 0; // Initially, active read buffer is memory0; write buffer is memory1
        end else begin
            case (buffer_select)
                1: begin // Active read buffer: memory0; active write buffer: memory1
                    // Write operation on memory1
                    if (write_enable && !((((write_ptr1 + 1) % DEPTH) == read_ptr1))) begin
                        write_ptr1 <= next_write_ptr1;
                    end
                    // Read operation on memory0
                    if (read_enable && (read_ptr0 != write_ptr0)) begin
                        read_ptr0 <= next_read_ptr0;
                    end

                    // Toggle buffer_select if active write buffer (memory1) is full
                    // or active read buffer (memory0) is empty
                    if ((((write_ptr1 + 1) % DEPTH) == read_ptr1) || (read_ptr0 == write_ptr0))
                        buffer_select <= ~buffer_select;
                end
                0: begin // Active read buffer: memory1; active write buffer: memory0
                    // Write operation on memory0
                    if (write_enable && !((((write_ptr0 + 1) % DEPTH) == read_ptr0))) begin
                        write_ptr0 <= next_write_ptr0;
                    end
                    // Read operation on memory1
                    if (read_enable && (read_ptr1 != write_ptr1)) begin
                        read_ptr1 <= next_read_ptr1;
                    end

                    // Toggle buffer_select if active write buffer (memory0) is full
                    // or active read buffer (memory1) is empty
                    if ((((write_ptr0 + 1) % DEPTH) == read_ptr0) || (read_ptr1 == write_ptr1))
                        buffer_select <= ~buffer_select;
                end
            endcase
        end
    end

endmodule

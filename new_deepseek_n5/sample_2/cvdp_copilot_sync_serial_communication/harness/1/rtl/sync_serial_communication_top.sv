module sync_serial_communication_top (
    input clock,
    input reset_n,
    input data_in,
    input sel
);

    // Transmitter block
    tx_block tx(
        clock = clock,
        reset_n = reset_n,
        data_in = data_in,
        sel = sel
    );

    // Receiver block
    rx_block rx(
        clock = clock,
        reset_n = reset_n,
        data_in = serial_out,
        sel = sel
    );

    // Connect outputs
    data_out = data_out;
    done = done;

endmodule

module tx_block (
    input clock,
    input reset_n,
    input data_in,
    input sel,
    output serial_out,
    output done,
    output serial_clk
);

    reg [63:0] data_reg;
    reg [63:0] serial_data;
    reg [63:0] tx_buffer;
    reg [63:0] tx_buffer_sel;
    reg [63:0] tx_buffer_data;
    reg [63:0] tx_buffer_ptr;
    reg [63:0] tx_buffer_valid;
    reg [63:0] tx_buffer_done;

    case (sel)
        3'b000: begin
            serial_out = 64'h0;
            done = 1'b0;
            serial_clk = 1'b0;
        end
        3'b001: begin
            tx_buffer_valid = 1'b1;
            tx_buffer_ptr = 0;
            tx_buffer_done = 1'b0;
            tx_buffer = data_in;
            tx_buffer_sel = 7'h7f;
            tx_buffer_data = data_in;
        end
        3'h010: begin
            tx_buffer_valid = 1'b1;
            tx_buffer_ptr = 0;
            tx_buffer_done = 1'b0;
            tx_buffer = data_in;
            tx_buffer_sel = 15'hff;
            tx_buffer_data = data_in;
        end
        3'h011: begin
            tx_buffer_valid = 1'b1;
            tx_buffer_ptr = 0;
            tx_buffer_done = 1'b0;
            tx_buffer = data_in;
            tx_buffer_sel = 31'hff;
            tx_buffer_data = data_in;
        end
        3'h012: begin
            tx_buffer_valid = 1'b1;
            tx_buffer_ptr = 0;
            tx_buffer_done = 1'b0;
            tx_buffer = data_in;
            tx_buffer_sel = 63'hff;
            tx_buffer_data = data_in;
        end
        default: begin
            serial_out = 64'h0;
            done = 1'b0;
            serial_clk = 1'b0;
        end

    // Tx logic
    always clockposededge #1 (posedge clock) begin
        if (reset_n) begin
            data_reg = 64'h0;
            serial_data = 64'h0;
            tx_buffer = 64'h0;
            tx_buffer_ptr = 0;
            tx_buffer_valid = 1'b0;
            tx_buffer_done = 1'b0;
        end
        else if (tx_buffer_valid) begin
            serial_data = data_reg;
            tx_buffer_valid = 1'b0;
            tx_buffer_ptr = (tx_buffer_ptr + 1) % 64;
        end
        else if (tx_buffer_ptr >= 64) begin
            tx_buffer_valid = 1'b1;
            tx_buffer_ptr = 0;
            tx_buffer_done = 1'b1;
            data_reg = tx_buffer_data;
        end

        if (tx_buffer_done) begin
            serial_out = data_reg;
            done = 1'b1;
            serial_clk = 1'b1;
        end
    end

    // Rx logic
    reg [63:0] rx_buffer;
    reg [63:0] rx_buffer_ptr;
    reg [63:0] rx_buffer_valid;
    reg [63:0] rx_buffer_done;

    case (sel)
        3'b000: begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end
        3'b001: begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end
        3'h010: begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end
        3'h011: begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end
        3'h012: begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end
        default: begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end

    // Rx logic
    always clockposededge #1 (posedge clock) begin
        if (reset_n) begin
            rx_buffer = 64'h0;
            rx_buffer_ptr = 0;
            rx_buffer_valid = 1'b0;
            rx_buffer_done = 1'b0;
        end
        else if (rx_buffer_valid) begin
            rx_buffer_valid = 1'b0;
            rx_buffer_ptr = (rx_buffer_ptr + 1) % 64;
            rx_buffer[rx_buffer_ptr] = serial_data;
        end
        else if (rx_buffer_ptr >= 64) begin
            rx_buffer_valid = 1'b1;
            rx_buffer_ptr = 0;
            rx_buffer_done = 1'b1;
            data_reg = rx_buffer;
        end

        if (rx_buffer_done) begin
            data_out = data_reg;
            done = 1'b1;
        end
    end

endmodule
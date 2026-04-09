module sync_serial_communication_top(
    input clock,
    input reset_n,
    input data_in,
    input sel,
    output serial_out,
    output done,
    output data_out
);

    include "tx_block"
    include "rx_block"

endmodule

module tx_block(
    input clock,
    input reset_n,
    input data_in,
    input sel,
    output serial_out,
    output done,
    output serial_clk
);

    reg [MAX_WIDTH-1:0] data_out;
    reg [MAX_WIDTH-1:0] data_in_reg;
    reg [MAX_WIDTH-1:0] serial_out_reg;
    reg serial_clk_reg;
    reg [15:0] tx_reg;
    reg [15:0] sel_reg;

    always clocked begin
        if (reset_n)
            tx_reg = 0;
            sel_reg = 0;
        else
            sel_reg = sel;
            tx_reg = data_in;
            
            if (sel_reg[2:0] == 3'h0)
                serial_out_reg = 0;
            else
                integer width = sel_reg[2:0] + 3;
                if (width > MAX_WIDTH)
                    serial_out_reg = 0;
                else
                    serial_out_reg = data_in_reg[(MAX_WIDTH-1):width];
            
            serial_clk_reg = 1;
        end
    end

    assign serial_out = serial_out_reg;
    assign done = 0;
    assign serial_clk = serial_clk_reg;
endmodule

module rx_block(
    input clock,
    input reset_n,
    input serial_clk,
    input data_in,
    input sel,
    output data_out,
    output done
);

    reg [MAX_WIDTH-1:0] data_out_reg;
    reg [MAX_WIDTH-1:0] data_in_reg;
    reg [15:0] rx_reg;
    reg [15:0] sel_reg;
    reg done_reg;

    always clocked begin
        if (reset_n)
            rx_reg = 0;
            done_reg = 0;
        else
            sel_reg = sel;
            data_in_reg = data_in;
            
            if (sel_reg[2:0] == 3'h0)
                data_out_reg = 0;
            else
                integer width = sel_reg[2:0] + 3;
                if (width > MAX_WIDTH)
                    data_out_reg = 0;
                else
                    data_out_reg = data_in_reg[(MAX_WIDTH-1):width];
            
            if (serial_clk)
                rx_reg = data_out_reg;
                done_reg = 1;
            else
                rx_reg = 0;
        end
    end

    assign data_out = data_out_reg;
    assign done = done_reg;
endmodule
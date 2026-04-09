module rtl/sync_serial_communication_top(
    input clock,
    input reset_n,
    input data_in,
    input sel
);
    interface tx_block
        input clock,
        input reset_n,
        input data_in,
        input sel,
        output serial_out,
        output done,
        output serial_clk
    endinterface

    interface rx_block
        input clock,
        input reset_n,
        input data_in,
        input sel,
        output data_out,
        output done
    endinterface

    // Implementation of tx_block
    tx_block tx = tx_block#64(
        clock = clock,
        reset_n = reset_n,
        data_in = data_in,
        sel = sel
    );

    // Implementation of rx_block
    rx_block rx = rx_block#64(
        clock = clock,
        reset_n = reset_n,
        data_in = serial_out,
        sel = sel
    );

    // Tie data_out to rx_block's data_out
    data_out = data_out;
endmodule

module tx_block#64(
    input clock,
    input reset_n,
    input data_in,
    input sel,
    output serial_out,
    output done,
    output serial_clk
);
    reg data_reg[63:0];
    reg done_reg;
    reg serial_out_reg;
    reg serial_clk_reg;
    reg [63:0] data_out_reg;

    case(sel)
        3'b000:
            // 0 bits
            data_reg = 64'h0;
            serial_out_reg = 1'b0;
            serial_clk_reg = 1'b0;
            done_reg = 1'b0;
            break;
        3'b001:
            // 8 bits
            data_reg = data_in[7:0];
            serial_out_reg = 1'b0;
            serial_clk_reg = 1'b0;
            done_reg = 1'b0;
            break;
        3'b010:
            // 16 bits
            data_reg = data_in[15:0];
            serial_out_reg = 1'b0;
            serial_clk_reg = 1'b0;
            done_reg = 1'b0;
            break;
        3'b011:
            // 32 bits
            data_reg = data_in[31:0];
            serial_out_reg = 1'b0;
            serial_clk_reg = 1'b0;
            done_reg = 1'b0;
            break;
        3'b100:
            // 64 bits
            data_reg = data_in[63:0];
            serial_out_reg = 1'b0;
            serial_clk_reg = 1'b0;
            done_reg = 1'b0;
            break;
        default:
            data_reg = 64'h0;
            serial_out_reg = 1'b0;
            serial_clk_reg = 1'b0;
            done_reg = 1'b0;
            break;
    endcase

    // Generate serial_clk
    if(reset_n == 1'b0) begin
        serial_clk_reg = 1'b1;
    end

    // Transmit data
    alwaysposededge clock begin
        if(reset_n == 1'b0) begin
            if(sel == 3'h1) begin
                serial_out_reg = 1'b0;
                serial_clk_reg = 1'b0;
                done_reg = 1'b0;
            end
        end
    end

    // When done_reg is 1, set serial_out to data_reg and set done_reg to 1
    alwaysposededge serial_clk begin
        if(data_reg != 64'h0) begin
            serial_out_reg = data_reg;
            done_reg = 1'b1;
        end
    end
    endmodule

module rx_block#64(
    input clock,
    input reset_n,
    input data_in,
    input sel,
    output data_out,
    output done
);
    reg data_reg[63:0];
    reg done_reg;
    reg data_out_reg[63:0];

    case(sel)
        3'b000:
            // 0 bits
            data_out_reg = 64'h0;
            done_reg = 1'b0;
            break;
        3'b001:
            // 8 bits
            data_out_reg = data_in[7:0];
            done_reg = 1'b0;
            break;
        3'b010:
            // 16 bits
            data_out_reg = data_in[15:0];
            done_reg = 1'b0;
            break;
        3'b011:
            // 32 bits
            data_out_reg = data_in[31:0];
            done_reg = 1'b0;
            break;
        3'b100:
            // 64 bits
            data_out_reg = data_in[63:0];
            done_reg = 1'b0;
            break;
        default:
            data_out_reg = 64'h0;
            done_reg = 1'b0;
            break;
    endcase

    // Initialize data_reg
    data_reg = 64'h0;

    // Receive data
    alwaysposededge clock begin
        if(reset_n == 1'b0) begin
            if(sel == 3'b001 || sel == 3'b010 || sel == 3'b011 || sel == 3'b100) begin
                data_reg = data_out;
                done_reg = 1'b0;
            end
        end
    end
    endmodule
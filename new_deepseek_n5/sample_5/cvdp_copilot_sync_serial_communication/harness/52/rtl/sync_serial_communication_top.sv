module sync_serial_communication_top (
    input clk, 
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    output [63:0] data_out,
    output done
);

// Internal signals
wire tx_out;
wire tx_done;
wire serial_clk_in;

// Instantiate blocks
tx_block uut_tx_block (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .sel(sel),
    .serial_out(tx_out),
    .done(tx_done),
    .serial_clk(serial_clk_in)
);

rx_block uut_rx_block (
    .clk(clk),
    .serial_clk(serial_clk_in),
    .reset_n(reset_n),
    .sel(sel),
    .data_in(tx_out),
    .data_out(data_out),
    .done(done)
);

endmodule

///// tx_block
module tx_block (
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output serial_clk
);

// Internal registers
reg [63:0] data_reg;
reg [6:0] bit_count;
reg [6:0] reg_count;

// Sequential block
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg     <= 64'h0;
        bit_count    <= 7'h0;
        reg_count    <= 7'h0;
    else begin
        if (done == 1'b1) begin
            case (sel)
                3'b000: begin
                    data_reg  <= 64'h0;
                    bit_count <= 7'd0;
                end
                3'b001: begin
                    data_reg  <= {56'h0, data_in[7:0]};
                    bit_count <= 7'd7;
                end
                3'b010: begin
                    data_reg  <= {48'h0, data_in[15:0]};
                    bit_count <= 7'd15;
                end
                3'b011: begin
                    data_reg  <= {32'h0, data_in[31:0]};
                    bit_count <= 7'd31;
                end
                3'b100: begin
                    data_reg  <= data_in[63:0];
                    bit_count <= 7'd63;
                end
                default: begin
                    data_reg  <= 64'h0;
                    bit_count <= 7'h0;
                end
            endcase
        end else if (bit_count > 7'h0) begin
            data_reg   <= data_reg >> 1;
            bit_count  <= bit_count - 1'b1;
        end
        reg_count <= bit_count;
    end
end

// Generate serial clock
always@(posedge clk) begin
    if (reg_count > 7'h0) begin
        wire {64'h0, serial_clk} = (posedge clock after 3 cycles);
    end
end

endmodule

///// rx_block
module rx_block (
    input clk,
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    input [7:0] bit_count,
    input [7:0] count,
    output reg done,
    output [63:0] data_out
);

// Internal registers
reg [63:0] data_reg;
reg [7:0] bit_count;

// Sequential block
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg <= 64'h0;
        bit_count <= 8'd0;
    else begin
        if (done == 1'b1) begin
            bit_count <= 8'd0;
            data_reg <= 64'h0;
        else begin
            bit_count <= bit_count + 1'b1;
            data_reg[bit_count] <= data_in;
        end
    end
end

// Sequential logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        count <= 8'd0;
        done <= 1'b0;
        data_out <= 64'h0;
    else if (count >= bit_count && count != 8'd0) begin
        done <= 1'b1;
        case (sel)
            3'b000: data_out <= 64'h0;
            3'b001: data_out <= {56'h0, data_reg};
            3'b010: data_out <= {48'h0, data_reg};
            3'b011: data_out <= {32'h0, data_reg};
            3'b100: data_out <= data_reg;
            default: data_out <= 64'h0;
        endcase
    else if (bit_count > 8'd0) begin
        count <= count + 1'b1;
        done <= 1'b0;
    else begin
        count <= 8'd0;
        done <= 1'b0;
    end
end

endmodule
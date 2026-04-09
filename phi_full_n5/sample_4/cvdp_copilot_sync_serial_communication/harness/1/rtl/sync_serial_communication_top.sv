module sync_serial_communication_top (
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output reg serial_clk
);

    wire [63:0] data_out;
    wire [1:0] sel_sel;

    tx_block tx_inst(.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel_sel), .serial_out(serial_out), .serial_clk(serial_clk));
    rx_block rx_inst(.clk(clk), .reset_n(reset_n), .data_in(serial_out), .sel(sel_sel), .serial_clk(serial_clk), .data_out(data_out), .done(done));

    always @ (posedge clk) begin
        if (reset_n) begin
            serial_out <= 1'b0;
            done <= 1'b0;
            serial_clk <= 1'b0;
        end else begin
            sel_sel = {sel[2:0], sel};
            case (sel_sel)
                3'b0: begin
                    serial_out <= 1'b0;
                    done <= 1'b0;
                    serial_clk <= 1'b0;
                end
                3'b1: begin
                    serial_out <= data_in[7:0];
                    done <= 1'b0;
                    serial_clk <= 1'b0;
                end
                3'b2: begin
                    serial_out <= data_in[15:0];
                    done <= 1'b0;
                    serial_clk <= 1'b0;
                end
                3'b3: begin
                    serial_out <= data_in[31:0];
                    done <= 1'b0;
                    serial_clk <= 1'b0;
                end
                3'b4: begin
                    serial_out <= data_in;
                    done <= 1'b0;
                    serial_clk <= 1'b0;
                end
                default: begin
                    serial_out <= 1'b0;
                    done <= 1'b0;
                    serial_clk <= 1'b0;
                end
            endcase
        end
    end

endmodule

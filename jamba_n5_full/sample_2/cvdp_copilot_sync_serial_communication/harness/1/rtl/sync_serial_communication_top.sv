module sync_serial_communication_top (
    input wire clk,
    input wire reset_n,
    input wire [63:0] data_in,
    input wire [2:0] sel
);

    tx_block uut1 (.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel));
    rx_block uut2 (.clk(clk), .reset_n(reset_n), .data_in(uut1.serial_out), .sel(sel));

    assign output_data = uut2.data_out;
    assign done = uut2.done;

endmodule

module tx_block (.clk, .reset_n, .data_in, .sel);
    reg [63:0] serial_out;
    reg done;

    always @(posedge clk or posedge reset_n) begin
        if (!reset_n) begin
            serial_out <= 0;
            done <= 1'b0;
        end else begin
            serial_out <= {
                case (sel) {
                    3'h0: data_in[7:0];
                    3'h1: data_in[15:0];
                    3'h2: data_in[31:0];
                    3'h3: data_in[63:0];
                    default: 0;
                }
            };
            done <= 1'b1;
        end
    end
endmodule

module rx_block (.clk, .reset_n, .data_in, .sel);
    reg [63:0] data_out;
    reg done;

    always @(posedge clk or posedge reset_n) begin
        if (!reset_n) begin
            data_out <= 64'h0;
            done <= 1'b0;
        end else begin
            case (sel) {
                3'h0: data_out <= data_in[0];
                3'h1: data_out <= data_in[8];
                3'h2: data_out <= data_in[30];
                3'h3: data_out <= data_in[31];
                default: data_out <= 64'h0;
            }
            done <= 1'b1;
        end
    end
endmodule

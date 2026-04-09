module sync_serial_communication_top (
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_clk,
    output reg done
);

    tx_block tx_inst(.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel), .serial_out(serial_out), .done(done_tx));
    rx_block rx_inst(.clk(serial_clk), .reset_n(reset_n), .data_in(serial_in), .sel(sel), .data_out(data_out), .done(done_rx));

    assign serial_clk = tx_inst.serial_clk;
    assign serial_in = tx_inst.serial_out;

    assign done = done_rx;

    // Initialization and reset logic
    initial begin
        serial_clk = 1'b0;
        done = 1'b0;
        serial_in = 1'b0;
    end

    // Reset logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            serial_out <= 1'b0;
            done <= 1'b0;
            serial_clk <= 1'b0;
            serial_in <= 1'b0;
        end else begin
            // Reset logic for data_out based on sel and data_in
            // Implement the conditional logic for setting initial state of data_out here
        end
    end

endmodule

module tx_block (
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done
)
{
    reg [63:0] temp_data;
    reg [63:0] serial_bit;
    reg done_flag;

    initial begin
        done_flag = 1'b0;
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            temp_data <= 64'h0;
            serial_bit <= 1'b0;
            done_flag <= 1'b0;
        end else begin
            case (sel)
                3'h0: temp_data <= 64'h0;
                3'h1: temp_data <= data_in;
                3'h2: temp_data <= {temp_data[63:48], data_in[15:8]};
                3'h3: temp_data <= {temp_data[31:24], data_in[8:1]};
                3'h4: temp_data <= data_in;
                default: temp_data <= 64'h0;
            endcase
            serial_bit <= temp_data[7];
            done <= 1'b0;
        end
    end

    // Serial output logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            done_flag <= 1'b0;
        end else begin
            if (serial_bit != temp_data[7]) begin
                serial_bit <= temp_data[7];
                done_flag <= 1'b1;
            end else begin
                done_flag <= 1'b0;
            end
        end
    end
endmodule

module rx_block (
    input clk,
    input reset_n,
    input serial_in,
    input [2:0] sel,
    output reg [63:0] data_out,
    output reg done
)
{
    reg [63:0] temp_data;
    reg done_flag;

    initial begin
        done_flag = 1'b0;
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            data_out <= 64'h0;
            done_flag <= 1'b0;
        end else begin
            case (sel)
                3'h0: data_out <= 64'h0;
                3'h1: data_out <= {serial_in, serial_in, serial_in, serial_in, serial_in, serial_in, serial_in, serial_in, serial_in};
                3'h2: data_out <= {serial_in, serial_in, serial_in, serial_in, serial_in, serial_in, serial_in, data_in[15], data_in[16]};
                3'h3: data_out <= {serial_in, serial_in, serial_in, serial_in, serial_in, data_in[31], data_in[32]};
                3'h4: data_out <= serial_in;
                default: data_out <= 64'h0;
            endcase
            done <= 1'b0;
        end
    end

    // Deserial input logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            done_flag <= 1'b0;
        end else begin
            if (serial_in != temp_data) begin
                temp_data <= serial_in;
                done_flag <= 1'b1;
            end else begin
                done_flag <= 1'b0;
            end
        end
    end
endmodule

module decoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [65:0] decoder_data_in,
    output logic [63:0] decoder_data_out,
    output logic         sync_error
);

    logic [1:0] sync_header;
    logic [63:0] data_in;

    assign sync_header = decoder_data_in[65:64];
    assign data_in = decoder_data_in[63:0];

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            decoder_data_out <= 64'b0;
            sync_error <= 1'b0;
        else
            if (sync_header == 2'b01) begin
                // valid data encoding
                decoder_data_out = data_in;
                sync_error = 0;
            end
            else if (sync_header == 2'b10) begin
                // unsupported control
                decoder_data_out = 64'b0;
                sync_error = 1'b1;
            end
            else begin
                // other sync headers
                decoder_data_out = 64'b0;
                sync_error = 1'b1;
            end
    end

endmodule

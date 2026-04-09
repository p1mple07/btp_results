module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0]  encoder_data_in,
    input  logic [7:0]   encoder_control_in,
    output logic [65:0]  encoder_data_out
);

    reg [1:0] sync_word;
    logic [63:0] encoded_data;

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            sync_word <= 2'b01;
        elseif (encoder_control_in == 8'b00000000)
            sync_word <= 2'b01;
        elsif (encoder_control_in == 8'b11111111)
            sync_word <= 2'b10;
        else
            sync_word <= 2'b00; // Default to data‑only

        if (encoder_control_in == 8'b00000000)
            encoded_data <= encoder_data_in;
        else if (encoder_control_in == 8'b11111111)
            encoded_data <= encode_control(encoder_control_in);
        else
            encoded_data <= encoder_data_in;
    end

    always_comb begin
        if (sync_word == 2'b01)
            encoder_data_out = {2'b10, encoder_data};
        elseif (sync_word == 2'b10)
            encoder_data_out = {2'b10, encoded_data};
        else
            encoder_data_out = {sync_word, encoded_data};
    end

endmodule

function integer encode_control(logic [7:0] c);
    integer val;
    val = 8'h1E;
    if (c == 8'b11111111) val = 8'h1E;
    else if (c == 8'b11111100) val = 8'hAA;
    else if (c == 8'b11110001) val = 8'h4B;
    else if (c == 8'b11100000) val = 8'hDC;
    else if (c == 8'b11000000) val = 8'hEE;
    else if (c == 8'b10000000) val = 8'hEE;
    else if (c == 8'b00011111) val = 8'h2D;
    else if (c == 8'b00000001) val = 8'h55;
    else if (c == 8'b00000001) val = 8'h55;
    else if (c == 8'b00000001) val = 8'h55;
    else if (c == 8'b00000001) val = 8'h55;
    else
        val = 8'h00;
    return val;
endfunction

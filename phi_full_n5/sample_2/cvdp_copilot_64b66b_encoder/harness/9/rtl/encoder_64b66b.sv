module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    logic [1:0] sync_word;     
    logic [63:0] encoded_data; 

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;            
        end 
        else begin
            sync_word <= encoder_control_in ? 2'b10 : 2'b01;

            if (encoder_control_in[7]) begin
                // Control character encoding
                case (encoder_control_in)
                    8'h07: encoded_data <= {encoded_data, 7'h00};
                    8'hfb: encoded_data <= {encoded_data, 7'h0000};
                    8'hfd: encoded_data <= {encoded_data, 7'h1e};
                    8'hfe: encoded_data <= {encoded_data, 7'h1e};
                    8'h9c: encoded_data <= {encoded_data, 7'h1111};
                    default: encoded_data <= encoded_data;
                endcase
            end
            else begin
                // Data byte encoding
                encoded_data <= encoder_data_in;
            end
        end
    end

    assign encoder_data_out = {sync_word, encoded_data};

endmodule

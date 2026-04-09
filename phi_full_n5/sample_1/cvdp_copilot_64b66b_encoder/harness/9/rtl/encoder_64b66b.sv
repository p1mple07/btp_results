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
            case (encoder_control_in)
                8'h00: begin
                    sync_word <= 2'b01;
                    encoded_data <= encoder_data_in;
                end
                8'hFF: begin
                    sync_word <= 2'b10;
                    encoded_data <= {7'b0000000, encoder_control_in[7], encoder_control_in[6], encoder_control_in[5], encoder_control_in[4], encoder_control_in[3], encoder_control_in[2], encoder_control_in[1]};
                end
                default: begin
                    sync_word <= 2'b10;
                    encoded_data <= {7'b0000000, encoder_control_in[7], encoder_control_in[6], encoder_control_in[5], encoder_control_in[4], encoder_control_in[3], encoder_control_in[2], encoder_control_in[1]};
                end
            end
        end
    end
endmodule

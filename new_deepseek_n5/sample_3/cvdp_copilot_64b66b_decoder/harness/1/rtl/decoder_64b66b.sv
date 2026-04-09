module decoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [65:0]  decoder_data_in,     // 66-bit encoded input
    output logic [63:0]  decoder_data_out,    // Decoded 64-bit data output
    output logic         sync_error           // Sync error flag
);

    logic [1:0] sync_header; 
    logic [63:0] data_in;    

    
    assign sync_header = decoder_data_in[65:64];
    assign data_in = decoder_data_in[63:0];

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            decoder_data_out <= 64'b0; 
            sync_error <= 1'b0;        
        end 
        else begin
            case (sync_header)
                2'b00 | 2'b01:
                    decoder_data_out <= data_in;
                    sync_error <= 0;
                2'b10:
                    decoder_data_out <= 64'b0;
                    sync_error <= 1;
                default:
                    decoder_data_out <= 64'b0;
                    sync_error <= 1;
            endcase
        end
    endmodule
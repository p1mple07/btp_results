module hamming_code_receiver #(parameter PARITY_BITS=3, parameter DATA_BITS=4);

    // Define inputs and outputs
    input  wire logic [DATA_BITS+PARITY_BITS-1:0] data_in;
    output      logic [DATA_BITS-1:0]         data_out;
    
    // Define internal signals
    logic [DATA_BITS-1:0]            syndrome;
    logic [PARITY_BITS-1:0]        error_detector;
    logic [DATA_BITS-1:0]            corrected_data;
    
    // Even parity error detection
    always_comb begin
        error_detector = ^(data_in & {{DATA_BITS-PARITY_BITS{1'b0}}, 1'b1});
        
        // Calculate syndrome bits
        syndrome = data_in & {~{error_detector}, ~{error_detector}};
    end
    
    // Error indication by syndrome
    always_comb begin
        if(syndrome == 3'b000) begin
            data_out = data_in;
        end else begin
            data_out = data_in ^ ((syndrome >> 1) & {{DATA_BITS-PARITY_BITS{1'b0}}, 1'b1});
        end
    end
    
endmodule
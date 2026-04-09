module sipo_top#(parameter DATA_WIDTH = 16, parameter SHIFT_DIRECTION = 1, parameter CRC_WIDTH = DATA_WIDTH / 2) (
    input clk, 
    input reset_n, 
    input sin, 
    input shift_en, 
    output done, 
    output [DATA_WIDTH-1:0] parallel_out, 
    input [CRC_WIDTH-1:0] received_crc
    );
    
    wire [DATA_WIDTH-1:0] parallel_out;
    wire [CRC_WIDTH-1:0] crc_out;
    
    localparam COUNT_WIDTH = $clog2(WIDTH);
    reg [COUNT_WIDTH:0] shift_count;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin                                   
            parallel_out     <= {WIDTH{1'b0}};                
            done             <= 1'b0;                         
            shift_count      <= {COUNT_WIDTH{1'b0}};          
        end else begin
            if (shift_en) begin
                if (SHIFT_DIRECTION) begin
                    parallel_out    <= {parallel_out[WIDTH-2:0], sin}; 
                end else begin
                    parallel_out    <= {sin, parallel_out[WIDTH-1:1]}; 
                end
                shift_count   <= shift_count + 1;                      
            end
            
            if (shift_count == (WIDTH - 1)) begin
                done         <= 1'b1;                                 
                shift_count  <= {COUNT_WIDTH{1'b0}};                  
            end else begin
                done         <= 1'b0;                                  
            end
        end
    end 
endmodule


module crc_generator#(
    parameter DATA_WIDTH = 16, 
    parameter CRC_WIDTH = 8, 
    parameter POLY = 8'b10101010
)(
    input [DATA_WIDTH-1:0] data_in, 
    input [CRC_WIDTH-1:0] received_crc,
    output [CRC_WIDTH-1:0] crc_out,
    input clock,
    input rst
    );

    localparam PARITY_BITS = CRC_WIDTH - DATA_WIDTH;
    reg [PARITY_BITS-1:0] syndrome;
    reg [CRC_WIDTH-1:0] corrected_data;

    always @(*) begin
        corrected_data = received_crc;
        if (rst) begin
            syndrome = 0;
            for (i = 0; i < PARITY_BITS; i = i + 1) begin
                syndrome[i] = 0;
            end
        end else begin
            for (i = 0; i < PARITY_BITS; i = i + 1) begin
                syndrome[i] = syndrome[i] ^ corrected_data[i];
            end
        end
    end

    always @(*) begin
        crc_out = corrected_data;
    end
endmodule
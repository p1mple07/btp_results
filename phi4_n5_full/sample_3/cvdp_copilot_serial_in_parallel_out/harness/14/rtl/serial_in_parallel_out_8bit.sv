module sipo_top#(
    parameter DATA_WIDTH = 16,
    parameter SHIFT_DIRECTION = 1,
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1),
    parameter CRC_WIDTH = DATA_WIDTH / 2,
    parameter POLY = 8'b10101010
)(
    input clk,
    input reset_n,
    input serial_in,
    input shift_en,
    input [CODE_WIDTH-1:0] received,
    input [CRC_WIDTH-1:0] received_crc,
    output done,
    output [DATA_WIDTH-1:0] data_out,
    output [CODE_WIDTH-1:0] encoded,
    output error_detected,
    output error_corrected,
    output [CRC_WIDTH-1:0] crc_out,
    output crc_error
);

    // Wires connecting sub-modules
    wire [DATA_WIDTH-1:0] parallel_out;
    wire [DATA_WIDTH-1:0] sipo_out_ecc_in;

    // Instantiate serial_in_parallel_out_8bit
    serial_in_parallel_out_8bit  #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION)) uut_sipo (
        .clk           (clk),
        .reset_n       (reset_n),
        .sin           (serial_in),
        .shift_en      (shift_en),
        .done          (done),
        .parallel_out  (parallel_out)
    );
 
    // Instantiate onebit_ecc for Hamming encoding and single-bit error correction
    onebit_ecc #(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(CODE_WIDTH)) uut_onebit_ecc1 (
        .data_in       (parallel_out),
        .encoded       (encoded),
        .received      (received),
        .data_out      (data_out),
        .error_detected(error_detected),
        .error_corrected(error_corrected)
    );
    
    // Instantiate crc_generator to compute CRC from the SIPO output data
    crc_generator #(.DATA_WIDTH(DATA_WIDTH), .CRC_WIDTH(CRC_WIDTH), .POLY(POLY)) uut_crc (
        .clk          (clk),
        .rst          (reset_n),
        .data_in      (parallel_out),
        .crc_out      (crc_out)
    );

    // Compare generated CRC with received CRC and assert error if mismatch
    assign crc_error = (crc_out != received_crc);

endmodule

// ------------------------------------------------------------------
// Module: serial_in_parallel_out_8bit
// Description: Converts serial input into parallel output using a configurable shift direction.
// ------------------------------------------------------------------
module serial_in_parallel_out_8bit  #(
    parameter WIDTH = 64,
    parameter SHIFT_DIRECTION = 1
)(
    input clk,
    input reset_n,
    input sin,
    input shift_en,
    output reg done,
    output reg [WIDTH-1:0] parallel_out
);
    
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

// ------------------------------------------------------------------
// Module: onebit_ecc
// Description: Generates Hamming code from input data and performs single-bit error detection and correction.
// ------------------------------------------------------------------
module onebit_ecc #(
    parameter DATA_WIDTH = 4,
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)
)(
    input [DATA_WIDTH-1:0] data_in,
    output reg [CODE_WIDTH-1:0] encoded,
    input [CODE_WIDTH-1:0] received,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg error_detected,
    output reg error_corrected
);

    localparam PARITY_BITS = CODE_WIDTH - DATA_WIDTH;
    reg [PARITY_BITS-1:0] syndrome;
    reg [CODE_WIDTH-1:0] corrected_data;
    integer idx_i, idx_j, idx_k;
    integer idx_m, idx_n;
    integer idx_p, idx_q;

    // Generate encoded data by interleaving data and parity bits
    always @(*) begin
        encoded = 0;
        idx_k = 0;
        for (idx_i = 0; idx_i < CODE_WIDTH; idx_i = idx_i + 1) begin
            if ((idx_i + 1) & (idx_i)) begin
                encoded[idx_i] = data_in[idx_k];
                idx_k = idx_k + 1;
            end
        end

        // Calculate parity bits
        for (idx_i = 0; idx_i < PARITY_BITS; idx_i = idx_i + 1) begin
            encoded[(1 << idx_i) - 1] = 0; 
            for (idx_j = 0; idx_j < CODE_WIDTH; idx_j = idx_j + 1) begin
                if (((idx_j + 1) & (1 << idx_i)) && ((idx_j + 1) != (1 << idx_i))) begin
                    encoded[(1 << idx_i) - 1] = encoded[(1 << idx_i) - 1] ^ encoded[idx_j];
                end
            end
        end
    end

    // Compute syndrome for error detection
    always @(*) begin
        syndrome = 0; 
        for (idx_m = 0; idx_m < PARITY_BITS; idx_m = idx_m + 1) begin
            for (idx_n = 0; idx_n < CODE_WIDTH; idx_n = idx_n + 1) begin
                if ((idx_n + 1) & (1 << idx_m)) begin
                    syndrome[idx_m] = syndrome[idx_m] ^ received[idx_n];
                end
            end
        end
    end

    // Assert error_detected if any syndrome bit is high
    always @(*) begin
        error_detected = |syndrome; 
    end

    // Correct single-bit error if detected
    always @(*) begin
        corrected_data = received;
        if (error_detected) begin
            corrected_data[syndrome - 1] = ~corrected_data[syndrome - 1]; 
        end
    end

    // Extract original data from corrected data
    always @(*) begin
        idx_q = 0;
        for (idx_p = 0; idx_p < CODE_WIDTH; idx_p = idx_p + 1) begin
            if ((idx_p + 1) & (idx_p)) begin
                data_out[idx_q] = corrected_data[idx_p];
                idx_q = idx_q + 1;
            end
        end
    end

    // Pass through the error_detected flag as error_corrected
    always @(*) begin
        error_corrected = error_detected; 
    end

endmodule

// ------------------------------------------------------------------
// Module: crc_generator
// Description: Computes the CRC for the input data using a given polynomial.
// Inputs:
//   - data_in: DATA_WIDTH-bit data (MSB first)
//   - clk: Clock signal (50:50 duty cycle)
//   - rst: Active low synchronous reset (when asserted, crc_out is zero)
// Outputs:
//   - crc_out: CRC result (CRC_WIDTH bits)
// ------------------------------------------------------------------
module crc_generator #(
    parameter DATA_WIDTH = 16,
    parameter CRC_WIDTH = DATA_WIDTH / 2,
    parameter POLY = 8'b10101010
)(
    input clk,
    input rst, // Active low reset: when rst is low, crc_out is reset to 0
    input [DATA_WIDTH-1:0] data_in,
    output reg [CRC_WIDTH-1:0] crc_out
);
    integer i;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            crc_out <= 0;
        end else begin
            // Local register to hold the shifting CRC value
            reg [CRC_WIDTH-1:0] crc_reg;
            crc_reg = 0;
            // Process each bit of data_in (MSB first)
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                // If MSB of crc_reg XOR current data bit is 1, apply XOR with POLY
                if (crc_reg[CRC_WIDTH-1] ^ data_in[i])
                    crc_reg = (crc_reg << 1) ^ POLY;
                else
                    crc_reg = crc_reg << 1;
            end
            crc_out <= crc_reg;
        end
    end
endmodule
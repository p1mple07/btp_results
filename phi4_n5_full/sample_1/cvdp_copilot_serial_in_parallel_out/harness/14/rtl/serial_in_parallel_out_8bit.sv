module sipo_top#(
    parameter DATA_WIDTH = 16,                                   // Width of the shift register
    parameter SHIFT_DIRECTION = 1,                               // Determines Left or right shift
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1),   // Encoded width
    parameter CRC_WIDTH  = DATA_WIDTH/2,                         // CRC width is half of DATA_WIDTH
    parameter POLY       = 8'b10101010                           // Default CRC polynomial
) (
    input         clk,
    input         reset_n,
    input         serial_in,
    input         shift_en,
    input [CODE_WIDTH-1:0] received,
    input [CRC_WIDTH-1:0] received_crc,  // Received CRC value for comparison
    output        done,
    output [DATA_WIDTH-1:0] data_out,    // Corrected output from ECC
    output [CODE_WIDTH-1:0] encoded,     // Hamming encoded output
    output        error_detected,        // ECC error detected flag
    output        error_corrected,       // ECC error corrected flag
    output [CRC_WIDTH-1:0] crc_out,       // Output of CRC generator
    output        crc_error              // Flag indicating CRC mismatch (1 if crc_out != received_crc)
);

    // Internal signal from SIPO block
    wire [DATA_WIDTH-1:0] parallel_out;

    // Instantiate SIPO block: converts serial input to parallel output.
    serial_in_parallel_out_8bit #(
        .WIDTH(DATA_WIDTH),
        .SHIFT_DIRECTION(SHIFT_DIRECTION)
    ) uut_sipo (
        .clk           (clk),
        .reset_n       (reset_n),
        .sin           (serial_in),
        .shift_en      (shift_en),
        .done          (done),
        .parallel_out  (parallel_out)
    );

    // Instantiate onebit_ecc: Generates Hamming code and performs single-bit error correction.
    onebit_ecc #(
        .DATA_WIDTH(DATA_WIDTH),
        .CODE_WIDTH(CODE_WIDTH)
    ) uut_onebit_ecc1 (
        .data_in       (parallel_out),
        .encoded       (encoded),
        .received      (received),
        .data_out      (data_out),
        .error_detected(error_detected),
        .error_corrected(error_corrected)
    );

    // Instantiate crc_generator: Computes CRC over the SIPO output.
    crc_generator #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH),
        .POLY(POLY)
    ) uut_crc (
        .clk           (clk),
        .reset_n       (reset_n),
        .data_in       (parallel_out),
        .crc_out       (crc_out)
    );

    // Compare generated CRC with received CRC.
    assign crc_error = (crc_out !== received_crc);

endmodule

//---------------------------------------------------------
// Module: serial_in_parallel_out_8bit
// Description: Converts serial input to parallel output.
//---------------------------------------------------------
module serial_in_parallel_out_8bit  #(
    parameter WIDTH = 64,               // Width of the shift register
    parameter SHIFT_DIRECTION = 1       // Determines shifting direction
)(
    input         clk,                   // Clock signal
    input         reset_n,               // Active-low reset
    input         sin,                   // Serial input
    input         shift_en,              // Shift enable signal
    output reg    done,                  // Indicates completion of shift operation
    output reg [WIDTH-1:0] parallel_out  // Parallel output
);
    
    localparam COUNT_WIDTH = $clog2(WIDTH); // Width for the shift counter
    
    reg [COUNT_WIDTH:0] shift_count;        // Counter to track shifts

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

//---------------------------------------------------------
// Module: onebit_ecc
// Description: Generates Hamming code and performs single-bit error correction.
//---------------------------------------------------------
module onebit_ecc #(
    parameter DATA_WIDTH = 4,                                  // Width of the data input
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)  // Encoded width
)(
    input  [DATA_WIDTH-1:0] data_in,                     // Input data
    output reg [CODE_WIDTH-1:0] encoded,                // Encoded output
    input  [CODE_WIDTH-1:0] received,                    // Received encoded data
    output reg [DATA_WIDTH-1:0] data_out,               // Corrected output
    output reg error_detected,                          // Error detected flag
    output reg error_corrected                         // Error corrected flag
);

    localparam PARITY_BITS = CODE_WIDTH - DATA_WIDTH;   // Number of parity bits

    reg [PARITY_BITS-1:0] syndrome;                     // Syndrome for error detection
    reg [CODE_WIDTH-1:0] corrected_data;                // Corrected received data

    integer idx_i, idx_j, idx_k;
    integer idx_m, idx_n;
    integer idx_p, idx_q;

    always @(*) begin
        encoded = 0;
        idx_k = 0;

        // Interleave data bits with parity positions.
        for (idx_i = 0; idx_i < CODE_WIDTH; idx_i = idx_i + 1) begin
            if ((idx_i + 1) & (idx_i)) begin
                encoded[idx_i] = data_in[idx_k];
                idx_k = idx_k + 1;
            end
        end

        // Calculate parity bits.
        for (idx_i = 0; idx_i < PARITY_BITS; idx_i = idx_i + 1) begin
            encoded[(1 << idx_i) - 1] = 0; 
            for (idx_j = 0; idx_j < CODE_WIDTH; idx_j = idx_j + 1) begin
                if (((idx_j + 1) & (1 << idx_i)) && ((idx_j + 1) != (1 << idx_i))) begin
                    encoded[(1 << idx_i) - 1] = encoded[(1 << idx_i) - 1] ^ encoded[idx_j];
                end
            end
        end
    end

    // Compute syndrome for error detection.
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

    always @(*) begin
        error_detected = |syndrome; 
    end

    // Correct single-bit error if detected.
    always @(*) begin
        corrected_data = received;
        if (error_detected) begin
            corrected_data[syndrome - 1] = ~corrected_data[syndrome - 1]; 
        end
    end

    // Extract corrected data bits.
    always @(*) begin
        idx_q = 0;
        for (idx_p = 0; idx_p < CODE_WIDTH; idx_p = idx_p + 1) begin
            if ((idx_p + 1) & (idx_p)) begin
                data_out[idx_q] = corrected_data[idx_p];
                idx_q = idx_q + 1;
            end
        end
    end

    always @(*) begin
        error_corrected = error_detected; 
    end

endmodule
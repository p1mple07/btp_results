module sipo_top#(parameter DATA_WIDTH = 16,                                   // Width of the shift register
                 parameter SHIFT_DIRECTION = 1,                               // Determines Left or right shift
                 parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1)   // Encoded width
                 ) (
   
   input clk,                                   // Clock input
   input reset_n,                               // Reset input
   input serial_in,                             // Serial input to SIPO
   input shift_en,                              // Shift enable signal
   output reg done,                             // Done signal indicating completion of shift
   output reg [DATA_WIDTH-1:0] data_out,        // corrected output of ecc block
   output [CODE_WIDTH-1:0] encoded,             // Encoded output
   output error_detected,                       // Error detected flag
   output error_corrected                       // Error corrected flag
   
   );

wire [DATA_WIDTH-1:0] parallel_out;
wire [DATA_WIDTH-1:0] sipo_out_ecc_in;

serial_in_parallel_out_8bit #(.WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION)) uut_sipo (
        .clk           (clk),               // Clock input
        .reset_n       (reset_n),           // Reset input
        .sin           (serial_in),         // Serial input to SIPO
        .shift_en      (shift_en),          // Shift enable for SIPO
        .done          (done),              // Done signal from SIPO
        .parallel_out  (parallel_out)       // Parallel output from SIPO
    );

// crc_generator module
module crc_generator #(
    parameter DATA_WIDTH = 8,
    parameter POLY = 8'b10101010
) (
    input [DATA_WIDTH-1:0] data_in,
    output reg [CODE_WIDTH-1:0] crc_out
);

localparam COUNT_WIDTH = $clog2(DATA_WIDTH);

reg [COUNT_WIDTH:0] shift_count;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        parallel_out <= {DATA_WIDTH{1'b0}};
        done <= 1'b0;
        shift_count <= {COUNT_WIDTH{1'b0}};
    end else begin
        if (shift_en) begin
            if (SHIFT_DIRECTION) begin
                parallel_out <= {parallel_out[WIDTH-2:0], data_in[0]}; 
            end else begin
                parallel_out <= {sin, parallel_out[WIDTH-1:1]}; 
            end
            shift_count   <= shift_count + 1;                      
        end
        
        if (shift_count == (DATA_WIDTH - 1)) begin
            done <= 1'b1;
            shift_count  <= {COUNT_WIDTH{1'b0}};
        end else begin
            done <= 1'b0;                                  
        end
    end
end

onebit_ecc#(.DATA_WIDTH(DATA_WIDTH),.CODE_WIDTH(CODE_WIDTH)) uut_onebit_ecc1 (

    .data_in(parallel_out),
    .encoded(encoded),
    .received(received),
    .data_out(data_out),
    .error_detected(error_detected),
    .error_corrected(error_corrected)
    );

endmodule

module serial_in_parallel_out_8bit #(
    parameter WIDTH = 64,               // Width of the shift register
    parameter SHIFT_DIRECTION = 1       // Determines if shifting
)(
    input clk,                          // Clock signal
    input reset_n,                      // Active low reset
    input sin,                          // Serial input to SIPO
    input shift_en,                     // Shift enable signal
    output reg done,                    // Done signal indicating completion of shift
    output reg [WIDTH-1:0] parallel_out // Parallel output
);

localparam COUNT_WIDTH = $clog2(WIDTH); // Calculate width for shift_count

reg [COUNT_WIDTH:0] shift_count;        // Parameterized counter to track number of shifts

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

module onebit_ecc #(
    parameter DATA_WIDTH = 4,                                  // Width of the data input
    parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1) // Encoded width
)(
    input [DATA_WIDTH-1:0] data_in,                     // Input data
    output reg [CODE_WIDTH-1:0] encoded,                // Encoded output
    input [CODE_WIDTH-1:0] received,                    // Received encoded data
    output reg [DATA_WIDTH-1:0] data_out,               // Corrected output
    output reg error_detected,                          // Error detected flag
    output reg error_corrected                          // Error corrected flag
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


        for (idx_i = 0; idx_i < CODE_WIDTH; idx_i = idx_i + 1) begin
            if ((idx_i + 1) & (idx_i)) begin
                encoded[idx_i] = data_in[idx_k];
                idx_k = idx_k + 1;
            end
        end


        for (idx_i = 0; idx_i < PARITY_BITS; idx_i = idx_i + 1) begin
            encoded[(1 << idx_i) - 1] = 0; 
            for (idx_j = 0; idx_j < CODE_WIDTH; idx_j = idx_j + 1) begin
                if (((idx_j + 1) & (1 << idx_i)) && ((idx_j + 1) != (1 << idx_i))) begin
                    encoded[(1 << idx_i) - 1] = encoded[(1 << idx_i) - 1] ^ encoded[idx_j];
                end
            end
        end
    end


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

    
    always @(*) begin
        corrected_data = received;
        if (error_detected) begin
            corrected_data[syndrome - 1] = ~corrected_data[syndrome - 1]; 
        end
    end

 
    always @(*) begin
        idx_q = 0;
        for (idx_p = 0; idx_p < CODE_WIDTH; idx_p = idx_p + 1) begin
            if ((idx_p + 1) & (idx_p)) begin
                data_out[idx_q] = corrected_data[idx_p];
                idx_q = idx_q + 1;
            end
        end
    }


    always @(*) begin
        error_corrected = error_detected; 
    end

endmodule

module serial_in_parallel_out_8bit #(
    parameter WIDTH = 64,               // Width of the shift register
    parameter SHIFT_DIRECTION = 1       // Determines if shifting
)(
    input clk,                          // Clock signal
    input reset_n,                      // Active LOW synchronous reset
    input sin,                          // Serial input
    input shift_en,                     // Shift enable signal
    output reg done,                    // Done signal indicating completion of shift
    output reg [WIDTH-1:0] parallel_out // Parallel output
);
    
    localparam COUNT_WIDTH = $clog2(WIDTH); // Calculate width for shift_count
    
    reg [COUNT_WIDTH:0] shift_count;        // Parameterized counter to track number of shifts
    
    wire received_crc;
    wire crc_error;

    // CRC generator module instantiation
    crc_generator #(.CRC_WIDTH(WIDTH/2), .POLY(8'b10101010)) crc_gen(
        .data_in(parallel_out),
        .clk(clk),
        .rst(reset_n),
        .crc_out(crc_out),
        .received_crc(received_crc),
        .crc_error(crc_error)
    );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parallel_out <= {WIDTH{1'b0}};
            done <= 1'b0;
            shift_count <= {COUNT_WIDTH{1'b0}};
        end else begin
            if (shift_en) begin
                if (SHIFT_DIRECTION) begin
                    parallel_out <= {parallel_out[WIDTH-2:0], sin};
                end else begin
                    parallel_out <= {sin, parallel_out[WIDTH-1:1]};
                end
                shift_count <= shift_count + 1;
            end

            if (shift_count == (WIDTH - 1)) begin
                done <= 1'b1;
                shift_count <= {COUNT_WIDTH{1'b0}};
            end else begin
                done <= 1'b0;
            end
        end
    end
endmodule

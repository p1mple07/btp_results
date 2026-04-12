module nbit_swizzling_tb;
    // Parameter to define the data width
parameter DATA_WIDTH = 40;

reg [DATA_WIDTH-1:0] data_in;		    // Input data
reg [1:0] sel;				            // Selection signal for different swizzling modes			
wire [DATA_WIDTH-1:0] data_out;		    // Output data after swizzling
reg [DATA_WIDTH-1:0] expected_data_out; // Expected output for verification

integer i;				                // Loop variable

// Instantiate the DUT (Device Under Test)
nbit_swizzling#(.DATA_WIDTH(DATA_WIDTH)) uut_nbit_sizling (
    .data_in(data_in),
    .sel(sel),
    .data_out(data_out)
);

// Task to calculate expected data_out based on sel and data_in
task automatic calculate_expected_data_out(input [1:0] sel_val, input [DATA_WIDTH-1:0] data_in, output reg [DATA_WIDTH-1:0] expected_data_out);
begin
    case(sel_val)
        2'b00: begin
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            expected_data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
               end
        2'b01: begin
        expected_data_out = {DATA_WIDTH{1'b0}};
        
        // Reverse the lower half and place it in the upper half of data_out
        for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
            expected_data_out[DATA_WIDTH-1-i] = data_in[(DATA_WIDTH/2) + i];
        end

        // Reverse the lower half
        for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
            expected_data_out[(DATA_WIDTH/2)-1-i] = data_in[i];
        end
        end
        2'b10: begin
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[(DATA_WIDTH/4)-1-i] = data_in[i];
        end

        // Reverse the second quarter
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[2*(DATA_WIDTH/4)-1-i] = data_in[(DATA_WIDTH/4) + i];
        end

        // Reverse the third quarter
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[3*(DATA_WIDTH/4)-1-i] = data_in[2*(DATA_WIDTH/4) + i];
        end

        // Reverse the fourth quarter
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[4*(DATA_WIDTH/4)-1-i] = data_in[3*(DATA_WIDTH/4) + i];
        end
               end
        2'b11: begin
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[(DATA_WIDTH/8)-1-i] = data_in[i];
        end

        // Reverse the second segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[2*(DATA_WIDTH/8)-1-i] = data_in[(DATA_WIDTH/8) + i];
        end

        // Reverse the third segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[3*(DATA_WIDTH/8)-1-i] = data_in[2*(DATA_WIDTH/8) + i];
        end

        // Reverse the fourth segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[4*(DATA_WIDTH/8)-1-i] = data_in[3*(DATA_WIDTH/8) + i];
        end

        // Reverse the fifth segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[5*(DATA_WIDTH/8)-1-i] = data_in[4*(DATA_WIDTH/8) + i];
        end

        // Reverse the sixth segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[6*(DATA_WIDTH/8)-1-i] = data_in[5*(DATA_WIDTH/8) + i];
        end

        // Reverse the seventh segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[7*(DATA_WIDTH/8)-1-i] = data_in[6*(DATA_WIDTH/8) + i];
        end

        // Reverse the eighth segment
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[8*(DATA_WIDTH/8)-1-i] = data_in[7*(DATA_WIDTH/8) + i];
        end
    end
        default: expected_data_out = data_in;
    endcase
end
endtask

// Instantiate the DUT (Device Under Test)
initial begin
        repeat(10) begin
         sel = 2'b00;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; // Allow data_out to stabilize
            if (data_out !== expected_data_out) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h, expected_data_out = %h", $time, sel, data_in, data_out,expected_data_out);
            end
        end
        repeat(10) begin
         sel = 2'b01;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; // Allow data_out to stabilize
            if (data_out !== expected_data_out) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h, expected_data_out = %h", $time, sel, data_in, data_out,expected_data_out);
            end
        end
        repeat(10) begin
         sel = 2'b10;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; // Allow data_out to stabilize
            if (data_out !== expected_data_out) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h, expected_data_out = %h", $time, sel, data_in, data_out,expected_data_out);
            end
        end
        repeat(10) begin
         sel = 2'b11;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; // Allow data_out to stabilize
            if (data_out !== expected_data_out) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h, expected_data_out = %h", $time, sel, data_in, data_out,expected_data_out);
            end
        end
    end

initial begin
$dumpfile("dump.vcd");
$dumpvars(0,nbit_swizzling_tb);
end
    
endmodule
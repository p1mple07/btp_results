module nbit_swizzling_tb;
    // Parameter to define the data width
parameter DATA_WIDTH = 40;

reg [DATA_WIDTH-1:0] data_in;		    // Input data
reg [1:0] sel;				            // Selection signal for different swizzling modes			
wire [DATA_WIDTH:0] data_out;		    // Output data after swizzling
reg [DATA_WIDTH-1:0] expected_data_out; // Expected output for verification

integer i;				                // Loop variable
reg parity;                             



nbit_swizzling#(.DATA_WIDTH(DATA_WIDTH)) uut_nbit_sizling (
    .data_in(data_in),
    .sel(sel),
    .data_out(data_out)
);


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
        for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
            expected_data_out[DATA_WIDTH-1-i] = data_in[(DATA_WIDTH/2) + i];
        end
        for (i = 0; i < DATA_WIDTH/2; i = i + 1) begin
            expected_data_out[(DATA_WIDTH/2)-1-i] = data_in[i];
        end
        end
        2'b10: begin
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[(DATA_WIDTH/4)-1-i] = data_in[i];
        end
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[2*(DATA_WIDTH/4)-1-i] = data_in[(DATA_WIDTH/4) + i];
        end
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[3*(DATA_WIDTH/4)-1-i] = data_in[2*(DATA_WIDTH/4) + i];
        end
        for (i = 0; i < DATA_WIDTH/4; i = i + 1) begin
            expected_data_out[4*(DATA_WIDTH/4)-1-i] = data_in[3*(DATA_WIDTH/4) + i];
        end
               end
        2'b11: begin
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[(DATA_WIDTH/8)-1-i] = data_in[i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[2*(DATA_WIDTH/8)-1-i] = data_in[(DATA_WIDTH/8) + i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[3*(DATA_WIDTH/8)-1-i] = data_in[2*(DATA_WIDTH/8) + i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[4*(DATA_WIDTH/8)-1-i] = data_in[3*(DATA_WIDTH/8) + i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[5*(DATA_WIDTH/8)-1-i] = data_in[4*(DATA_WIDTH/8) + i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[6*(DATA_WIDTH/8)-1-i] = data_in[5*(DATA_WIDTH/8) + i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[7*(DATA_WIDTH/8)-1-i] = data_in[6*(DATA_WIDTH/8) + i];
        end
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            expected_data_out[8*(DATA_WIDTH/8)-1-i] = data_in[7*(DATA_WIDTH/8) + i];
        end
    end
        default: expected_data_out = data_in;
    endcase
end
endtask

initial begin
        repeat(10) begin
         sel = 2'b00;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            parity = ^data_in;
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; 
            if (data_out !== {parity,expected_data_out}) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h,parity = %b, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in,parity, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h,parity = %b, expected_data_out = %h", $time, sel, data_in, data_out,parity,expected_data_out);
            end
        end
        repeat(10) begin
         sel = 2'b01;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            parity = ^data_in;
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; 
            if (data_out !== {parity,expected_data_out}) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h,parity = %b, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in,parity, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h,parity =%b, expected_data_out = %h", $time, sel, data_in, data_out,parity,expected_data_out);
            end
        end
        repeat(10) begin
         sel = 2'b10;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            parity = ^data_in;
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; 
            if (data_out !== {parity,expected_data_out}) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h,parity = %b, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in,parity, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h,parity = %b, expected_data_out = %h", $time, sel, data_in, data_out,parity,expected_data_out);
            end
        end
        repeat(10) begin
         sel = 2'b11;
            data_in = $urandom_range(DATA_WIDTH,(2**DATA_WIDTH)-1);
            parity = ^data_in;
            calculate_expected_data_out(sel, data_in, expected_data_out);
            #10; 
            if (data_out !== {parity,expected_data_out}) begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("Error at %t: sel = %h, data_in = %h,parity = %b, expected data_out = %h, actual data_out = %h", 
                         $time, sel, data_in,parity, expected_data_out, data_out);
            end else begin
                $display("-----------------------------------------------------------------------------------------------------------");
                $display("%t sel = %h, data_in = %h, data_out = %h,parity = %b, expected_data_out = %h", $time, sel, data_in, data_out,parity,expected_data_out);
            end
        end
    end

initial begin
$dumpfile("dump.vcd");
$dumpvars(0,nbit_swizzling_tb);
end
    
endmodule
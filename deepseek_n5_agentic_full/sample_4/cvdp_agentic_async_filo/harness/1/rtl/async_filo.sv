Module header
module async_filo (
    // Parameters
    parameter LOCALDATA_WIDTH = 8,
    parameter LOCDEPTH = 8
);

// Input ports
input [LOCALDATA_WIDTH-1:0] w_data;
input w_clk, r_clk;
input w_rst, r_rst;
input push, pop;

// Output ports
output [LOCALDATA_WIDTH-1:0] r_data;
output r_empty, w_full;

// Internal state variables
reg [LOCALDATA_WIDTH-1:0] w_data;
reg [LOCALDATA_WIDTH-1:0] w_ptr, r_ptr;
reg [LOCDEPTH-1:0] w_count_bin, r_count_bin;

// State variables
localinteger counter;

// Conversion functions
function bin2gray, gray2bin {
    /* Binary to Gray */
    input [inwidth-1:0] in;
    output [outwidth-1:0] out;
    
    out = in ^ (in >> 1);
}

function gray2bin, bin2gray {
    /* Gray to Binary */
    input [inwidth-1:0] in;
    output [outwidth-1:0] out;
    
    out = in ^ (in >> 1) ^ (in >> 2) ^ (in >> 4) ^ (in >> 8) ^ (in >> 16) ^ (in >> 32);
}

always_ff @*begin
    case (w_rst || r_rst)
        w_rst ? (
            w_ptr = 0;
            w_count_bin = 0;
            r_count_bin = 0;
            r_ptr = 0;
        );
        r_rst ? (
            w_rst = 0;
            r_rst = 0;
            w_ptr = 0;
            w_count_bin = 0;
            r_count_bin = 0;
            r_ptr = 0;
        );
    endcase

    // Write operation
    @posedge w_clk begin
        if (push && ~w_full) begin
            w_data = $data;
            w_ptr = bin2gray(w_ptr + 1);
            w_count_bin = w_count_bin + 1;
            
            // Check if write pointer caught up to read pointer
            if (w_count_bin >= r_count_bin) begin
                w_full = 1;
                $display("Buffer is full");
            end
        end
    end

    // Read operation
    @posedge r_clk begin
        if (pop && ~r_empty) begin
            r_data = w_data;
            r_ptr = gray2bin(r_ptr + 1);
            r_count_bin = r_count_bin + 1;
            
            // Check if read pointer caught up to write pointer
            if (r_count_bin <= w_count_bin) begin
                r_empty = 1;
                $display("Buffer is empty");
            end
        end
    end
endmodule
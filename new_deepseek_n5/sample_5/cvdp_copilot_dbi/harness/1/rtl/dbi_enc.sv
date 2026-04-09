module dbi_enc(
    input wire [39:0] data_in,
    input clock,
    input rst_n,
    output wire [39:0] data_out,
    output [1:0] dbi_cntrl
);
    reg [39:0] prev_data1, prev_data0;
    reg [1:0] cnt1, cnt0;
    
    always @edge clock begin
        if (rst_n) begin
            prev_data1 = 0;
            prev_data0 = 0;
            data_out = 0;
            dbi_cntrl = 0b00;
            cnt1 = 0;
            cnt0 = 0;
            return;
        end
        
        // Split data into groups
        reg group1, group0;
        group1 = data_in[39:20];
        group0 = data_in[19:0];
        
        // Compare with previous data
        cnt1 = 0;
        for (int i = 0; i < 20; i++) {
            if ((group1 >> i & 1) != (prev_data1 >> i & 1)) cnt1++;
        }
        cnt0 = 0;
        for (int i = 0; i < 20; i++) {
            if ((group0 >> i & 1) != (prev_data0 >> i & 1)) cnt0++;
        }
        
        // Determine control bits
        dbi_cntrl[1] = cnt1 > 10;
        dbi_cntrl[0] = cnt0 > 10;
        
        // Update previous data
        prev_data1 = group1;
        prev_data0 = group0;
        
        // Generate output
        if (dbi_cntrl[1]) {
            data_out[39:20] = ~group1;
        } else if (dbi_cntrl[0]) {
            data_out[19:0] = ~group0;
        } else {
            data_out = data_in;
        }
    end
endmodule
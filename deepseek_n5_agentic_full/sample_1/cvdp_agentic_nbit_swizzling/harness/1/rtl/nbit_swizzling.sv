module rtl/nbit_swizzling.sv
    (
        parameter [ISINGNAL?]
        parameter DATA_WIDTH
    );

    localparam SelReverseTab = {
        {2'b00, "entire data reversed"},
        {2'b01, "split into two halves, each reversed"},
        {2'b10, "split into four quarters, each reversed"},
        {2'b11, "split into eight segments, each reversed"}
    };

    reg [DATA_WIDTH-1:0] data_in, data_out, gray_out;
    reg sel;

    case (sel)
        // Case 00: Reverse entire data
        2'b00: 
            for (i = 0; i < DATA_WIDTH; i++) begin
                data_out[i] = data_in[DATA_WIDTH - 1 - i];
            end
            // Compute Gray code
            for (j = DATA_WIDTH-2; j >=0; j--) begin
                gray_out[j] = data_out[j] ^ data_out[j+1];
            end
            break;
        // Case 01: Split into two halves
        2'b01: 
            for (i = 0; i < (DATA_WIDTH/2); i++) begin
                data_out[i] = data_in(DATA_WIDTH - 1 - i);  // Reverse lower half
                data_out[data_width - 1 - i] = data_in[i];  // Reverse upper half
            end
            // Compute Gray code
            for (j = DATA_WIDTH-2; j >=0; j--) begin
                gray_out[j] = data_out[j] ^ data_out[j+1];
            end
            break;
        // Case 10: Split into four quarters
        2'b10: 
            for (i = 0; i < (DATA_WIDTH/4); i++) begin
                data_out[i*2 + 0] = data_in(DATA_WIDTH - 1 - (i*2));  // Reverse first quarter
                data_out[DATA_WIDTH - 1 - (i*2)] = data_in(i*2);
                
                data_out[i*2 + 1] = data_in(DATA_WIDTH - 2 - (i*2));  // Reverse second quarter
                data_out[DATA_WIDTH - 2 - (i*2)] = data_in(i*2 + 1);
                
                data_out[i*2 + 2] = data_in(DATA_WIDTH - 3 - (i*2));  // Reverse third quarter
                data_out[DATA_WIDTH - 3 - (i*2)] = data_in(i*2 + 2);
                
                data_out[i*2 + 3] = data_in(DATA_WIDTH - 4 - (i*2));  // Reverse fourth quarter
                data_out[DATA_WIDTH - 4 - (i*2)] = data_in(i*2 + 3);
            end
            // Compute Gray code
            for (j = DATA_WIDTH-2; j >=0; j--) begin
                gray_out[j] = data_out[j] ^ data_out[j+1];
            end
            break;
        // Case 11: Split into eight segments
        2'b11: 
            for (i = 0; i < (DATA_WIDTH/8); i++) begin
                data_out[i*4 + 0] = data_in(DATA_WIDTH - 1 - (i*4));  // Reverse first segment
                data_out[DATA_WIDTH - 1 - (i*4)] = data_in(i*4);
                
                data_out[i*4 + 1] = data_in(DATA_WIDTH - 2 - (i*4));  // Reverse second segment
                data_out[DATA_WIDTH - 2 - (i*4)] = data_in(i*4 +1);
                
                data_out[i*4 + 2] = data_in(DATA_WIDTH -3 - (i*4));   // Reverse third segment
                data_out[DATA_WIDTH -3 - (i*4)] = data_in(i*4 +2);
                
                data_out[i*4 +3] = data_in(DATA_WIDTH -4 - (i*4));   // Reverse fourth segment
                data_out[DATA_WIDTH -4 - (i*4)] = data_in(i*4 +3);
            end
            // Compute Gray code
            for (j = DATA_WIDTH-2; j >=0; j--) begin
                gray_out[j] = data_out[j] ^ data_out[j+1];
            end
            break;
        default:
            // Invalid sel: default pass-through
            for (i =0; i < DATA_WIDTH; i++) begin
                data_out[i] = data_in[i];
            end
            // Compute Gray code
            for (j = DATA_WIDTH-2; j >=0; j--) begin
                gray_out[j] = data_out[j] ^ data_out[j+1];
            end
            break;
    endcase

    // Module initialization
    initial begin
        display("Reversed Data: " + format_data(data_out));
        display("Gray Code: " + format_data(gray_out));
        delay #10;
    end
endmodule
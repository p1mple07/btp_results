module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic [63:0] encoder_data_in,     // 64-bit data input
    input  logic [7:0] encoder_control_in,  // 8-bit control input
    output logic [65:0] encoder_data_out     // 66-bit encoded output
) {

    // Define the control codes for each bit position
    vector[8] control_code = {0x00, 0x00, 0x00, 0x1e, 0x1f, 0x80, 0x80, 0x80};
    
    // Determine if any control bits are set
    wire any_control = (encoder_control_in & 0xAA) != 0;
    
    // Determine the sync word
    wire sync_word = any_control ? 2'b10 : 2'b01;
    
    // Encode the data based on control input
    wire [63:0] encoded_data_mixed = 0;
    
    // Encode each byte
    // Bit 7: /I/
    wire bit7 = (encoder_control_in >> 7) & 1;
    wire data7 = (encoder_data_in >> 63) & 0xFF;
    wire code7 = (bit7 ? control_code[0] : data7);
    encoded_data_mixed |= (code7 << 56);
    
    // Bit 6: /S/
    wire bit6 = (encoder_control_in >> 6) & 1;
    wire data6 = (encoder_data_in >> 55) & 0xFF;
    wire code6 = (bit6 ? control_code[1] : data6);
    encoded_data_mixed |= (code6 << 48);
    
    // Bit 5: /T/
    wire bit5 = (encoder_control_in >> 5) & 1;
    wire data5 = (encoder_data_in >> 47) & 0xFF;
    wire code5 = (bit5 ? control_code[2] : data5);
    encoded_data_mixed |= (code5 << 40);
    
    // Bit 4: /E/
    wire bit4 = (encoder_control_in >> 4) & 1;
    wire data4 = (encoder_data_in >> 39) & 0xFF;
    wire code4 = (bit4 ? control_code[3] : data4);
    encoded_data_mixed |= (code4 << 32);
    
    // Bit 3: /Q/
    wire bit3 = (encoder_control_in >> 3) & 1;
    wire data3 = (encoder_data_in >> 31) & 0xFF;
    wire code3 = (bit3 ? control_code[4] : data3);
    encoded_data_mixed |= (code3 << 24);
    
    // Bit 2: /D/
    wire bit2 = (encoder_control_in >> 2) & 1;
    wire data2 = (encoder_data_in >> 23) & 0xFF;
    wire code2 = (bit2 ? control_code[5] : data2);
    encoded_data_mixed |= (code2 << 16);
    
    // Bit 1: /A/
    wire bit1 = (encoder_control_in >> 1) & 1;
    wire data1 = (encoder_data_in >> 15) & 0xFF;
    wire code1 = (bit1 ? control_code[6] : data1);
    encoded_data_mixed |= (code1 << 8);
    
    // Bit 0: Others
    wire bit0 = (encoder_control_in >> 0) & 1;
    wire data0 = (encoder_data_in >> 7) & 0xFF;
    wire code0 = (bit0 ? control_code[7] : data0);
    encoded_data_mixed |= code0;
    
    // Combine sync word and encoded data
    encoder_data_out = (sync_word << 64) | encoded_data_mixed;
}
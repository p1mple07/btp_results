encoder_64b66b.sv
----------------------------------------------------------------
module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64‐bit data input
    input  logic [7:0]   encoder_control_in,  // 8‐bit control input (each bit selects data/control)
    output logic [65:0]  encoder_data_out     // 66‐bit encoded output
);

  //-------------------------------------------------------------------------
  // Internal signals
  //-------------------------------------------------------------------------
  // The final encoded output is computed in two cases:
  // • Data‐only mode: 66 bits = {2’b01, 64’b data}
  // • Control/mixed mode: 66 bits = {2’b10, 8’b type_field, 56’b encoded_data_word}
  //-------------------------------------------------------------------------
  logic [65:0]        encoded_out;  // registered output
  logic [7:0]         type_field;   // 8‐bit type field (only used in control/mixed mode)
  logic [55:0]        encoded_data_word; // 56‐bit packed data word (8 groups × 7 bits)

  //-------------------------------------------------------------------------
  // Helper function: Control character encoder.
  // Maps an 8‐bit control character to its 7‐bit encoded value.
  //-------------------------------------------------------------------------
  function automatic [6:0] encode_control(input logic [7:0] in_byte);
    begin
      case (in_byte)
        8'h07:  encode_control = 7'h00;    // /I/ (Idle)
        8'hFB:  encode_control = 7'h00;    // /S/ (Start of Frame) [encoded as 4’b0000, padded to 7 bits]
        8'hFD:  encode_control = 7'h00;    // /T/ (End of Frame) [encoded as 4’b0000, padded to 7 bits]
        8'hFE:  encode_control = 7'h1E;    // /E/ (Error)
        8'h9C:  encode_control = 7'h1F;    // /Q/ (Ordered Set) [4’b1111 becomes 7’h1F]
        default: encode_control = 7'h00;   // default fallback
      endcase
    end
  endfunction

  //-------------------------------------------------------------------------
  // Combinational logic to compute the encoded output based on mode.
  // Three modes:
  //  1. Data‐only mode: encoder_control_in == 8’b00000000 
  //     => sync word = 2’b01 and data passed unchanged.
  //  2. Control‐only mode: encoder_control_in == 8’b11111111 
  //     => sync word = 2’b10, type_field = 8’h1E and each data byte is encoded.
  //  3. Mixed mode: Some control bits are 1 and some 0.
  //     For each byte: if control bit is 0, pass the lower 7 bits of the data;
  //                    if control bit is 1, replace with its 7‐bit encoded control code.
  //     The type_field is determined by a lookup (here a few cases are explicitly handled).
  //-------------------------------------------------------------------------
  always_comb begin
    // Default assignments
    encoded_out             = 66'b0;
    type_field              = 8'h00;
    encoded_data_word       = 56'b0;

    // Extract the 8 data bytes from the 64‐bit input.
    logic [7:0] d7, d6, d5, d4, d3, d2, d1, d0;
    d7 = encoder_data_in[63:56];
    d6 = encoder_data_in[55:48];
    d5 = encoder_data_in[47:40];
    d4 = encoder_data_in[39:32];
    d3 = encoder_data_in[31:24];
    d2 = encoder_data_in[23:16];
    d1 = encoder_data_in[15:8];
    d0 = encoder_data_in[7:0];

    // Determine operating mode based on control input.
    if (encoder_control_in == 8'b00000000) begin
      // Data‐only mode: pass all 64 bits unchanged.
      encoded_out = {2'b01, encoder_data_in};  // sync word = 2’b01 | data = 64’b
    end
    else if (encoder_control_in == 8'b11111111) begin
      // Control‐only mode: every byte is a control character.
      type_field = 8'h1E;
      // Pack each 8‐bit data byte into a 7‐bit encoded value.
      encoded_data_word[55:49] = encode_control(d7);
      encoded_data_word[48:42] = encode_control(d6);
      encoded_data_word[41:35] = encode_control(d5);
      encoded_data_word[34:28] = encode_control(d4);
      encoded_data_word[27:21] = encode_control(d3);
      encoded_data_word[20:14] = encode_control(d2);
      encoded_data_word[13:7]  = encode_control(d1);
      encoded_data_word[6:0]   = encode_control(d0);
      encoded_out = {2'b10, type_field, encoded_data_word};
    end
    else begin
      // Mixed mode: some bytes are data and some are control.
      // For each byte: if control bit == 1, use the 7‐bit encoded control code;
      //                if control bit == 0, use the lower 7 bits of the data.
      // Also, the type_field is set based on a lookup for known patterns.
      unique case (encoder_control_in)
        8'b11111110: begin
          // Example mixed pattern (e.g. last bit = 0, others = 1)
          // According to the spec, one valid lookup is:
          //   Input: I7, I6, I5, I4, I3, T1, D0 with control = 11111110
          //   Type field = 8’h87 and encoded data = {C7, C6, C5, C4, C3, C2, 6’b000000, D0}
          type_field = 8'h87;
          // For bytes with control bit = 1, use control encoding; for byte0 (control bit = 0), use data lower 7 bits.
          encoded_data_word[55:49] = encode_control(d7);
          encoded_data_word[48:42] = encode_control(d6);
          encoded_data_word[41:35] = encode_control(d5);
          encoded_data_word[34:28] = encode_control(d4);
          encoded_data_word[27:21] = encode_control(d3);
          encoded_data_word[20:14] = encode_control(d2);
          encoded_data_word[13:7]  = encode_control(d1);
          encoded_data_word[6:0]   = d0[6:0];
        end
        8'b11111000: begin
          // Example mixed pattern:
          //   Input: D7, D6, D5, S4, I3, I2, I1, I0 with control = 00011111 
          //   According to the spec, type field = 8’h33 and encoded data = {C7, C6, C5, 4’b0000, C3, C2, C1, C0}
          type_field = 8'h33;
          // For this pattern assume: bytes 0..3 are data; bytes 4..7 are control.
          encoded_data_word[55:49] = encode_control(d7);
          encoded_data_word[48:42] = encode_control(d6);
          encoded_data_word[41:35] = encode_control(d5);
          encoded_data_word[34:28] = encode_control(d4);
          encoded_data_word[27:21] = d3[6:0];
          encoded_data_word[20:14] = d2[6:0];
          encoded_data_word[13:7]  = d1[6:0];
          encoded_data_word[6:0]   = d0[6:0];
        end
        8'b11110000: begin
          // Example mixed pattern:
          //   Input: D7, D6, D5, D4, D3, D2, D1, S0 with control = 00000001 
          //   According to the spec, type field = 8’h78 and encoded data = {D7, D6, D5, D4, D3, D2, D1, D0}
          type_field = 8'h78;
          // In this case assume: only the lowest‐order byte is control while the others are data.
          encoded_data_word[55:49] = encode_control(d7);
          encoded_data_word[48:42] = encode_control(d6);
          encoded_data_word[41:35] = encode_control(d5);
          encoded_data_word[34:28] = encode_control(d4);
          encoded_data_word[27:21] = d3[6:0];
          encoded_data_word[20:14] = d2[6:0];
          encoded_data_word[13:7]  = d1[6:0];
          encoded_data_word[6:0]   = d0[6:0];
        end
        default: begin
          // For any other mixed pattern, use a default type field and process each byte individually.
          type_field = 8'h00;
          encoded_data_word[55:49] = (encoder_control_in[7]) ? encode_control(d7) : d7[6:0];
          encoded_data_word[48:42] = (encoder_control
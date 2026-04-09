module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0]  encoder_data_in,
    input  logic [7:0]   encoder_control_in,
    output logic [65:0]  encoder_data_out
);

  // Function: Encodes a control character (8-bit input) into a 7-bit code.
  // Mapping according to the specification:
  //   Idle (0x07)         -> 7'h00
  //   Start of Frame (0xFB) -> 7'h00  (assumed: 4'b0000 extended to 7 bits)
  //   End of Frame (0xFD)   -> 7'h00  (assumed: 4'b0000 extended to 7 bits)
  //   Error (0xFE)         -> 7'h1E
  //   Ordered Set (0x9C)   -> 7'h7F  (assumed: 4'b1111 extended to 7 bits)
  function automatic logic [6:0] encode_control;
    input logic [7:0] byte;
    case (byte)
      8'h07: encode_control = 7'h00;
      8'hFB: encode_control = 7'h00; // 4'b0000 extended to 7 bits
      8'hFD: encode_control = 7'h00; // 4'b0000 extended to 7 bits
      8'hFE: encode_control = 7'h1E;
      8'h9C: encode_control = 7'h7F; // 4'b1111 extended to 7 bits
      default: encode_control = 7'h00;
    endcase
  endfunction

  // Main always_ff block: Updates the output with one-cycle latency.
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      encoder_data_out <= 66'b0;
    end
    else begin
      // Data-Only Mode: When all control bits are 0.
      if (encoder_control_in == 8'b00000000) begin
         // Sync word = 2'b01 and payload is the full 64-bit data.
         encoder_data_out <= {2'b01, encoder_data_in};
      end
      // Control-Only Mode: When all control bits are 1.
      else if (encoder_control_in == 8'b11111111) begin
         // Sync word = 2'b10, type field = 8'h1E, and each byte is encoded.
         logic [55:0] encoded_control;
         encoded_control = { 
            encode_control(encoder_data_in[63:56]),
            encode_control(encoder_data_in[55:48]),
            encode_control(encoder_data_in[47:40]),
            encode_control(encoder_data_in[39:32]),
            encode_control(encoder_data_in[31:24]),
            encode_control(encoder_data_in[23:16]),
            encode_control(encoder_data_in[15:8]),
            encode_control(encoder_data_in[7:0])
         };
         encoder_data_out <= {2'b10, 8'h1E, encoded_control};
      end
      // Mixed Mode: Some control bits are 1 and others are 0.
      else begin
         // In mixed mode the output format is:
         //   {2-bit sync word, 8-bit type field, 56-bit encoded payload}
         // For each byte:
         //   - If the corresponding control bit is 1, use the 7-bit encoded control code.
         //   - If the control bit is 0, pass the lower 7 bits of the data byte.
         // Here we use a default type field of 8'h00.
         logic [55:0] payload;
         payload = { 
            (encoder_control_in[0] ? encode_control(encoder_data_in[63:56]) : encoder_data_in[63:56][6:0]),
            (encoder_control_in[1] ? encode_control(encoder_data_in[55:48]) : encoder_data_in[55:48][6:0]),
            (encoder_control_in[2] ? encode_control(encoder_data_in[47:40]) : encoder_data_in[47:40][6:0]),
            (encoder_control_in[3] ? encode_control(encoder_data_in[39:32]) : encoder_data_in[39:32][6:0]),
            (encoder_control_in[4] ? encode_control(encoder_data_in[31:24]) : encoder_data_in[31:24][6:0]),
            (encoder_control_in[5] ? encode_control(encoder_data_in[23:16]) : encoder_data_in[23:16][6:0]),
            (encoder_control_in[6] ? encode_control(encoder_data_in[15:8])  : encoder_data_in[15:8][6:0]),
            (encoder_control_in[7] ? encode_control(encoder_data_in[7:0])   : encoder_data_in[7:0][6:0])
         };
         encoder_data_out <= {2'b10, 8'h00, payload};
      end
    end
  end

endmodule
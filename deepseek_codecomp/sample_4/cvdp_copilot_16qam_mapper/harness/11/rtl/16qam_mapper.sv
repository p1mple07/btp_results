module qam16_mapper_interpolated #(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
)(
    input  logic [N*IN_WIDTH-1:0] bits,            
    output logic signed [(N + N/2)*OUT_WIDTH-1:0] I,
    output logic signed [(N + N/2)*OUT_WIDTH-1:0] Q 
);

   logic signed [OUT_WIDTH-1:0] mapped_symbol_I [0:N-1];
   logic signed [OUT_WIDTH-1:0] mapped_symbol_Q [0:N-1];
   logic signed [OUT_WIDTH:0] interp_symbol_I [0:N/2-1];
   logic signed [OUT_WIDTH:0] interp_symbol_Q [0:N/2-1];

   genvar i;
   generate 
      for (i = 0; i < N; i++) begin
      logic [IN_WIDTH-1:0] symbol;
      assign symbol = bits[(i+1)*IN_WIDTH - 1 -: IN_WIDTH];

       always_comb begin
               // Map MSBs (Most Significant Bits) to I (real component)
               case (symbol[3:2])
                   2'b00: mapped_symbol_I[i] = -3; // MSBs 00 -> I = -3
                   2'b01: mapped_symbol_I[i] = -1; // MSBs 01 -> I = -1
                   2'b10: mapped_symbol_I[i] =  1; // MSBs 10 -> I =  1
                   2'b11: mapped_symbol_I[i] =  3; // MSBs 11 -> I =  3
               endcase

               // Map LSBs (Least Significant Bits) to Q (imaginary component)
               case (symbol[1:0])
                   2'b00: mapped_symbol_Q[i] = -3; // LSBs 00 -> Q = -3
                   2'b01: mapped_symbol_Q[i] = -1; // LSBs 01 -> Q = -1
                   2'b10: mapped_symbol_Q[i] =  1; // LSBs 10 -> Q =  1
                   2'b11: mapped_symbol_Q[i] =  3; // LSBs 11 -> Q =  3
               endcase
           end
       end
   endgenerate

    always_comb begin
        for (int i = 0; i < N/2; i++) begin
            interp_symbol_I[i] = (mapped_symbol_I[2*i] + mapped_symbol_I[2*i+1]) >>> 1;
            interp_symbol_Q[i] = (mapped_symbol_Q[2*i] + mapped_symbol_Q[2*i+1]) >>> 1;
        end
    end

    always_comb begin
        for (int i = 0; i < N/2; i++) begin
            // Add the first mapped symbol
            I[(i*3+1)*OUT_WIDTH - 1 -: OUT_WIDTH] = mapped_symbol_I[2*i];
            Q[(i*3+1)*OUT_WIDTH - 1 -: OUT_WIDTH] = mapped_symbol_Q[2*i];

            // Add the interpolated symbol
            I[(i*3+2)*OUT_WIDTH - 1 -: OUT_WIDTH] = interp_symbol_I[i];
            Q[(i*3+2)*OUT_WIDTH - 1 -: OUT_WIDTH] = interp_symbol_Q[i];

            // Add the second mapped symbol
            I[(i*3+3)*OUT_WIDTH - 1 -: OUT_WIDTH] = mapped_symbol_I[2*i+1];
            Q[(i*3+3)*OUT_WIDTH - 1 -: OUT_WIDTH] = mapped_symbol_Q[2*i+1];
        end
    end

endmodule
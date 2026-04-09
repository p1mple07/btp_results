module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input clk,
    input enable,
    input enable_parity,
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,               
    input left_right,              
    input [data_width-1:0] mask,   
    output reg [data_width-1:0] data_out,
    output reg parity_out,          
    output reg error                
);

  always @(posedge clk) begin
    if (!enable) begin
      // When operation is disabled, retain previous data_out and force parity to 0.
      // (data_out retains its previous value by default)
      parity_out <= 0;
      error      <= 0;
    end else begin
      // Check for invalid shift amount
      if (shift_bits >= data_width) begin
        data_out <= {data_width{1'b0}};
        error    <= 1;
      end else begin
        error <= 0;
        case (mode)
          3'b000: begin  // Logical Shift
            if (left_right)
              data_out <= data_in << shift_bits;
            else
              data_out <= data_in >> shift_bits;
          end
          3'b001: begin  // Arithmetic Shift (right shift with sign)
            if (left_right)
              data_out <= data_in << shift_bits;
            else
              data_out <= $signed(data_in) >>> shift_bits;
          end
          3'b010: begin  // Rotate
            if (left_right)
              data_out <= (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
              data_out <= (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
          end
          3'b011: begin  // Masked Shift
            if (left_right)
              data_out <= (data_in << shift_bits) & mask;
            else
              data_out <= (data_in >> shift_bits) & mask;
          end
          3'b100: begin  // Arithmetic Addition/Subtraction
            if (left_right)
              data_out <= data_in + shift_bits;
            else
              data_out <= data_in - shift_bits;
          end
          3'b101: begin  // Priority Encoder: find highest set bit position in data_in
            if (data_in == 0)
              data_out <= 0;
            else begin
              integer i;
              for (i = data_width-1; i >= 0; i = i - 1) begin
                if (data_in[i])
                  break;
              end
              data_out <= i;
            end
          end
          3'b110: begin  // Modulo Arithmetic Addition/Subtraction
            if (left_right)
              data_out <= (data_in + shift_bits) % data_width;
            else
              data_out <= (data_in - shift_bits) % data_width;
          end
          3'b111: begin  // Not Supported
            data_out <= {data_width{1'b0}};
            error    <= 1;
          end
          default: begin
            data_out <= {data_width{1'b0}};
            error    <= 1;
          end
        endcase
      end
      
      // Parity Calculation: if enabled, compute XOR of all bits in data_out.
      if (enable_parity)
        parity_out <= ^data_out;
      else
        parity_out <= 0;
    end
  end

endmodule
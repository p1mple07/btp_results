module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input                clk,
    input                rst_n,
    input  [data_width-1:0] data_in,
    input  [shift_bits_width-1:0] shift_bits,
    input  [2:0]         mode,               
    input                left_right,              
    input  [data_width-1:0] mask,   
    input                enable,              // New enable signal
    input                enable_parity,      // Enable parity calculation
    output reg [data_width-1:0] data_out,
    output reg           parity_out,
    output reg           error                
);

  // Sequential always_ff block to incorporate state retention and clocked behavior
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_out   <= {data_width{1'b0}};
      parity_out <= 1'b0;
      error      <= 1'b0;
    end
    else begin
      // Local variables to hold computed values for this cycle.
      reg [data_width-1:0] new_data;
      reg                   new_error;
      reg                   parity;
      integer               i;
      reg                   found;
      
      // Default: retain previous outputs if enable is low.
      new_data   = data_out;
      new_error  = error;
      parity     = 1'b0;
      
      if (enable) begin
        // Check for invalid shift amount
        if (shift_bits >= data_width) begin
          new_data   = {data_width{1'b0}};
          parity     = 1'b0;
          new_error  = 1'b1;
        end
        else begin
          case (mode)
            3'b000: begin  // Logical Shift
              if (left_right)
                new_data = data_in << shift_bits;
              else
                new_data = data_in >> shift_bits;
            end
            3'b001: begin  // Arithmetic Shift
              if (left_right)
                new_data = data_in << shift_bits;
              else
                new_data = $signed(data_in) >>> shift_bits;
            end
            3'b010: begin  // Rotate
              if (left_right)
                new_data = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
              else
                new_data = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
            end
            3'b011: begin  // Masked Shift
              if (left_right)
                new_data = (data_in << shift_bits) & mask;
              else
                new_data = (data_in >> shift_bits) & mask;
            end
            3'b100: begin  // Arithmetic Addition/Subtraction
              if (left_right)
                new_data = data_in + {{(data_width - shift_bits_width){1'b0}}, shift_bits};
              else
                new_data = data_in - {{(data_width - shift_bits_width){1'b0}}, shift_bits};
            end
            3'b101: begin  // Priority Encoder: find highest set bit in data_in
              found = 1'b0;
              new_data = {data_width{1'b0}};
              for (i = data_width-1; i >= 0; i = i - 1) begin
                if (data_in[i] && !found) begin
                  new_data = i;  // 'i' is the bit position (starting from 0)
                  found = 1'b1;
                end
              end
            end
            3'b110: begin  // Modulo Arithmetic: addition or subtraction modulo data_width
              if (left_right)
                new_data = (data_in + {{(data_width - shift_bits_width){1'b0}}, shift_bits}) % data_width;
              else
                new_data = (data_in - {{(data_width - shift_bits_width){1'b0}}, shift_bits}) % data_width;
            end
            3'b111: begin  // Not supported
              new_data   = {data_width{1'b0}};
              new_error  = 1'b1;
            end
            default: begin
              new_data   = {data_width{1'b0}};
              new_error  = 1'b1;
            end
          endcase
          // Compute parity if enabled and no error condition.
          parity = (enable_parity && !new_error) ? (^new_data) : 1'b0;
        end
      end
      // If enable is low, retain previous data_out and error; force parity_out to 0.
      if (!enable) begin
        new_data   = data_out;
        new_error  = error;
        parity     = 1'b0;
      end
      
      data_out   <= new_data;
      parity_out <= parity;
      error      <= new_error;
    end
  end

endmodule
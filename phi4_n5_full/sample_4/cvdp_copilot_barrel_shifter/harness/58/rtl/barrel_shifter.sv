module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input         clk,
    input         rst_n,
    input  [data_width-1:0] data_in,
    input  [shift_bits_width-1:0] shift_bits,
    input  [2:0]  mode,               
    input         left_right,              
    input  [data_width-1:0] mask,   
    input         enable,
    input         enable_parity,
    output reg [data_width-1:0] data_out,
    output reg            error,
    output reg            parity_out
);

   // Register to hold the previous data_out value when enable is deasserted.
   reg [data_width-1:0] prev_data_out;

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_out      <= {data_width{1'b0}};
         error         <= 1'b0;
         parity_out    <= 1'b0;
         prev_data_out <= {data_width{1'b0}};
      end else begin
         if (!enable) begin
            // When operation is disabled, retain the previous data_out and disable parity.
            data_out      <= prev_data_out;
            parity_out    <= 1'b0;
            // error remains unchanged (could be cleared if desired)
         end else begin
            // First, check for an invalid shift amount.
            if (shift_bits >= data_width) begin
               data_out      <= {data_width{1'b0}};
               error         <= 1'b1;
               parity_out    <= 1'b0;
               prev_data_out <= data_out;
            end else begin
               // Clear error for valid operations.
               error <= 1'b0;
               
               // Execute operation based on mode.
               case (mode)
                   3'b000: begin // Logical Shift
                       if (left_right)
                           data_out <= data_in << shift_bits;
                       else
                           data_out <= data_in >> shift_bits;
                   end
                   3'b001: begin // Arithmetic Shift
                       if (left_right)
                           data_out <= data_in << shift_bits;
                       else
                           data_out <= $signed(data_in) >>> shift_bits;
                   end
                   3'b010: begin // Rotate
                       if (left_right)
                           data_out <= (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
                       else
                           data_out <= (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
                   end
                   3'b011: begin // Masked Shift
                       if (left_right)
                           data_out <= (data_in << shift_bits) & mask;
                       else
                           data_out <= (data_in >> shift_bits) & mask;
                   end
                   3'b100: begin // Arithmetic Addition/Subtraction
                       // When left_right=1, perform addition; otherwise, perform subtraction.
                       if (left_right)
                           data_out <= data_in + shift_bits;
                       else
                           data_out <= data_in - shift_bits;
                   end
                   3'b101: begin // Priority Encoder
                       // Find the position of the highest set bit in data_in.
                       // If no bits are set, data_out remains 0.
                       integer i;
                       data_out = {data_width{1'b0}};
                       for (i = data_width - 1; i >= 0; i = i - 1) begin
                           if (data_in[i]) begin
                               data_out = i;
                               $break; // Exit loop once the highest set bit is found.
                           end
                       end
                   end
                   3'b110: begin // Modulo Arithmetic Addition/Subtraction
                       // Perform modulo wrapping so that the result is always in [0, data_width-1].
                       if (left_right)
                           data_out <= ((data_in + shift_bits) % data_width);
                       else
                           data_out <= ((data_in - shift_bits) % data_width);
                   end
                   3'b111: begin // Not Supported
                       data_out <= {data_width{1'b0}};
                       error    <= 1'b1;
                       parity_out <= 1'b0;
                   end
                   default: begin
                       data_out <= {data_width{1'b0}};
                       error    <= 1'b1;
                   end
               endcase

               // Compute parity if enabled.
               if (enable_parity)
                   parity_out <= ^data_out;
               else
                   parity_out <= 1'b0;

               // Update the register holding the previous data_out value.
               prev_data_out <= data_out;
            end // end if (shift_bits < data_width)
         end // end if (enable)
      end // end else of reset
   end

endmodule
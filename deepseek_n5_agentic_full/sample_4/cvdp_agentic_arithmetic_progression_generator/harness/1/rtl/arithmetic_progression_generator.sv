module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10
)(
   clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);
  // Check for invalid sequence length
  if (SEQUENCE_LENGTH <= 0)
      return;
  // Local parameter definition
  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

  // Interface Definitions
  input logicclk;
  input logic resetn;
  input logic enable;
  inputlogic [DATA_WIDTH-1:0]start_val;
  inputlogic [DATA_WIDTH-1:0]step_size;
  outputlogic [WIDTH_OUT_VAL-1:0]out_val;
  outputlogic done;

  // Internal signals
  logic [WIDTH_OUT_VAL-1:0]current_val;
  logic[$clog2(SEQUENCE_LENGTH)-1:0]counter;

  always_ff@posedgeclk ornegedge resetnbegin
    if(!resetn)
        current_val <=0;
        counter <=0;
        done <=0;
    else if(enable)
        if(!done)
            if(counter ==0)
                current_val <=start_val;
            else
                current_val <=current_val + step_size;

            if(counter < SEQUENCE_LENGTH -1)
                counter <=counter +1;
            else
                done <=1;
            end
        endif
    endif
  end

  assign out_val = current_val;
endmodule
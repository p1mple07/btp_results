module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic [1:0]            sel,
    output logic [DATA_WIDTH-1:0] data_out
);

    // Function to reverse the bits of a vector.
    // The function works for any input width.
    function automatic [N-1:0] reverse_segment (input [N-1:0] data);
      integer i;
      begin
        for(i = 0; i < $bits(data); i = i + 1) begin
          reverse_segment[i] = data[$bits(data)-1-i];
        end
      end
    endfunction

    // Combinational logic for selective bit reversal.
    always_comb begin
      case(sel)
        2'd0: begin
                 // Reverse the entire input.
                 data_out = reverse_segment(data_in);
               end
        2'd1: begin
                 // Divide into two halves and reverse each half individually.
                 integer half_width = DATA_WIDTH / 2;
                 logic [half_width-1:0] rev_upper, rev_lower;
                 rev_upper = reverse_segment(data_in[DATA_WIDTH-1:DATA_WIDTH/2]);
                 rev_lower = reverse_segment(data_in[DATA_WIDTH/2-1:0]);
                 data_out = {rev_upper, rev_lower};
               end
        2'd2: begin
                 // Divide into four equal sections and reverse each section.
                 integer quarter_width = DATA_WIDTH / 4;
                 logic [quarter_width-1:0] seg0, seg1, seg2, seg3;
                 seg0   = reverse_segment(data_in[DATA_WIDTH-1:DATA_WIDTH - quarter_width]);
                 seg1   = reverse_segment(data_in[DATA_WIDTH - quarter_width - 1: DATA_WIDTH - 2*quarter_width]);
                 seg2   = reverse_segment(data_in[DATA_WIDTH - 2*quarter_width - 1: DATA_WIDTH - 3*quarter_width]);
                 seg3   = reverse_segment(data_in[DATA_WIDTH - 3*quarter_width - 1: 0]);
                 data_out = {seg0, seg1, seg2, seg3};
               end
        2'd3: begin
                 // Divide into eight equal sections and reverse each section.
                 integer eighth_width = DATA_WIDTH / 8;
                 logic [eighth_width-1:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7;
                 seg0   = reverse_segment(data_in[DATA_WIDTH-1: DATA_WIDTH - eighth_width]);
                 seg1   = reverse_segment(data_in[DATA_WIDTH - eighth_width - 1: DATA_WIDTH - 2*eighth_width]);
                 seg2   = reverse_segment(data_in[DATA_WIDTH - 2*eighth_width - 1: DATA_WIDTH - 3*eighth_width]);
                 seg3   = reverse_segment(data_in[DATA_WIDTH - 3*eighth_width - 1: DATA_WIDTH - 4*eighth_width]);
                 seg4   = reverse_segment(data_in[DATA_WIDTH - 4*eighth_width - 1: DATA_WIDTH - 5*eighth_width]);
                 seg5   = reverse_segment(data_in[DATA_WIDTH - 5*eighth_width - 1: DATA_WIDTH - 6*eighth_width]);
                 seg6   = reverse_segment(data_in[DATA_WIDTH - 6*eighth_width - 1: DATA_WIDTH - 7*eighth_width]);
                 seg7   = reverse_segment(data_in[DATA_WIDTH - 7*eighth_width - 1: 0]);
                 data_out = {seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7};
               end
        default: begin
                    // Default: pass the input directly.
                    data_out = data_in;
                  end
      endcase
    end

endmodule
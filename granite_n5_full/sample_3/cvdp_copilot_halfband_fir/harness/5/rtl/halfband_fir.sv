module halfband_fir();
    // A message to inform about progress
    reg progress;
    initial begin
        progress = 0;
    end
    always @(posedge progress) begin
        $display("Progress: %0d", progress);
    end

    // Bypass mode
    localparam BYPASS_MODE = 1;
    reg bypass_mode;
    always @(posedge i_clk) begin
        if (BYPASS_MODE) begin
            reg bypass;
            assign bypass = 1;
        end else begin
            reg bypass;
            assign bypass = 0;
    end
endmodule

module halfband_fir_unit_test;
    `include "../rtl/halfband_fir.sv"
    
endmodule

// A good practice is to include documentation in the form of HTML
// This can be written in HTML format for the documentation and annotations
// This is a good practice to write comments and annotations in the form of HTML format
// and this is how I would want to represent the documentation
// For example:
module halfband_fir_unit_test;
    // Documentation for a specific unit test
    // documentation for unit test code,
    // Add some documentation

endmodule
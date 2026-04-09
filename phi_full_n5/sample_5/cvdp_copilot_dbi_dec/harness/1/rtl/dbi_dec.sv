module dbi_dec (
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   output wire [39:0] data_out   // Output data after DBI logic
);

    // Internal wires for splitting and inverting data
    wire [39:0] data_group0, data_group1;
    wire invert_group0, invert_group1;

    // Split the data_in into two groups
    assign data_group0 = data_in[39:20];
    assign data_group1 = data_in[19:0];

    // Generate invert signals based on dbi_cntrl
    assign invert_group0 = dbi_cntrl[1] ^ data_group0;
    assign invert_group1 = dbi_cntrl[0] ^ data_group1;

    // Decode the data
    assign data_out = (~invert_group0) ? {invert_group0, data_group1} : {data_group0, data_group1};
    assign data_out = (~invert_group1) ? {data_group0, invert_group1} : {data_group0, data_group1};

    // Reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 40'h0000_0000;
        end else begin
            // No additional reset logic needed as data_out is already assigned based on control signals
        end
    end

endmodule

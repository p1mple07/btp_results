module bit_sync #(
    parameter STAGES = 2
) (
    input  logic aclk,    
    input  logic bclk,    
    input  logic rst_n,   
    input  logic adata,   
    output logic aq2_data,
    output logic bq2_data 
);

    logic [STAGES-1:0] a_sync_chain, b_sync_chain;

    // Synchronization for bclk domain
    always_ff @(posedge bclk or negedge rst_n) begin
        if (!rst_n)
            b_sync_chain <= {STAGES{1'b0}};
        else
            b_sync_chain <= {b_sync_chain[STAGES-2:0], adata};
    end

    assign bq2_data = b_sync_chain[STAGES-1];

    // Insert the synchronization logic for aclk domain here

endmodule

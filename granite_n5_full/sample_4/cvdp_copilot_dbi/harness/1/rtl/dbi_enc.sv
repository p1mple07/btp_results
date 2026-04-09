module dbi_enc #(
    parameter N = 40
)(
    input wire [N-1:0] data_in,
    input wire clk,
    input wire rst_n,
    output logic [N-1:0] data_out,
    output logic [1:0] dbi_cntrl
);

    logic [N-1:0] prev_data;
    logic [N-1:0] inv_group_0, inv_group_1;
    logic [N-1:0] group_0, group_1;
    logic [1:0] cntrl;

    // Split data into 2 groups
    assign {group_0, group_1} = data_in;

    // Compare groups with their previous values
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_data <= '0;
        end else begin
            prev_data <= data_in;
        end
    end

    // Calculate difference between groups and previous data
    always @(*) begin
        // Invert group 0 if more than 10 bits differ
        for (int i=0; i<N; i++) begin
            if ((group_0 & ~(prev_data >> i)) | (prev_data & ~(group_0 >> i))) begin
                inv_group_0[i] = ~group_0[i];
            end else begin
                inv_group_0[i] = group_0[i];
            end
        end

        // Invert group 1 if more than 10 bits differ
        for (int i=0; i<N; i++) begin
            if ((group_1 & ~(prev_data >> i)) | (prev_data & ~(group_1 >> i))) begin
                inv_group_1[i] = ~group_1[i];
            end else begin
                inv_group_1[i] = group_1[i];
            end
        end
    end

    // Generate dbi_cntrl based on bitwise differences
    assign cntrl[0] = (inv_group_0!= prev_data[19:0])? 1'b1 : 1'b0;
    assign cntrl[1] = (inv_group_1!= prev_data[39:20])? 1'b1 : 1'b0;

    // Generate data_out based on dbi_cntrl
    assign data_out = (dbi_cntrl == 2'b00)? (group_1 << 20) | group_0 : (inv_group_0 << 20) | inv_group_1;

endmodule
// Declaration of config_ff should match i_config width
logic [2:0] config_ff;

// Inside input_register always_ff block, remove the following line:
// config_ff <= 0;

// Inside drive_regions always_comb block, ensure the size of region_A_nx and region_B_nx
// matches the width of region_A_ff and region_B_ff after shifting

always_comb begin : drive_regions
    case(state_ff)
        IDLE: begin
            if(i_start) begin
                region_A_nx[NS_A] = (~i_config[0]);
                region_B_nx[NS_B] = (i_config[0]);
            end else begin
                region_A_nx[NS_A] = 1'b0;
                region_B_nx[NS_B] = 1'b0;
            end

            region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};
            region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
        end
        REGION_A: begin
            region_A_nx = region_A_ff >> 1;

            if(region_A_ff[0]) begin
                region_B_nx[NS_B] = A_to_B;
            end else begin
                region_B_nx[NS_B] = 1'b0;
            end
            region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
        end
        REGION_B: begin
            if(region_B_ff[0]) begin
                region_A_nx[NS_A] = B_to_A;
            end else begin
                region_A_nx[NS_A] = 1'b0;
            end
            region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};

            region_B_nx = region_B_ff >> 1;
        end
        default: begin
            region_A_nx = {NS_A{1'b0}};
            region_B_nx = {NS_B{1'b0}};
        end
    endcase
end

// Remove the unnecessary assignment to config_ff

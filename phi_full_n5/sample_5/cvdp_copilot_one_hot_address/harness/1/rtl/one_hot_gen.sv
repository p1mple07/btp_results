
     always_comb begin : drive_regions
         case(state_ff)
             // ...
             REGION_A: begin
                 region_A_nx = region_A_ff >> 1;
                 if(region_A_ff[0]) begin
                     region_B_nx[NS_B] = A_to_B; // Ensure this line drives the bit
                 end else begin
                     region_B_nx[NS_B] = 1'b0;
                 end
                 // ...
             end
             // ...
         endcase
     end
     
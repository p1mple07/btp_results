module load_store_unit(
    input clock,
    input rst_n,
    output dmem_req_o,
    input dmem_req_addr_o,
    input dmem_req_we_o,
    input dmem_req_be_o,
    input dmem_req_wdata_o,
    input dmem_gnt_i,
    input dmem_RSP_rdata_i,
    input dmem_RSP_rvalid_i,
    input ex_if_req_i,
    input ex_if_we_i,
    input ex_if_type_i,
    input ex_if_wdata_i,
    input ex_if_addr_base_i,
    input ex_if_addr_offset_i,
    output ex_if_ready_o,
    output wb_if_rdata_o,
    output wb_if_rvalid_o
);

    // Finite State Machine
    state initial_state, processing_request, processing_response, ready;
    always_comb begin
        // Address calculation
        dmem_req_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;
        
        // Determine byte enables based on data type
        byte enable[4:0] = 0;
        if (ex_if_type_i == 0b00) // byte
            byte enable[0] = 1;
        else if (ex_if_type_i == 0b01) // halfword
            byte enable[1:0] = 1;
        else if (ex_if_type_i == 0b10) // word
            byte enable[3:1] = 1;
        
        // Process request
        if (ex_if_req_i && ex_if_ready_o) begin
            if (dmem_gnt_i) begin
                // Send request to memory
                dmem_req_o = 1;
                dmem_req_we_o = ex_if_we_i;
                dmem_req_be_o = ex_if_wdata_i;
                dmem_req_wdata_o = dmem_RSP_rdata_i;
                
                // Deassert responses after one cycle
                dmem_gnt_i = 0;
                dmem_RSP_rvalid_i = 0;
                dmem_RSP_rdata_i = 0;
            end
        end
        
        // Process response
        if (dmem_RSP_rvalid_i && !rst_n) begin
            // Update writeback stage after one cycle
            wb_if_rvalid_o = 1;
            wb_if_rdata_o = dmem_RSP_rdata_i;
            dmem_RSP_rvalid_i = 0;
        end
    end

    // State transitions
    always_ff (ex_if_ready_o, processing_request, processing_response, ready) begin
        // Initial state
        if (rst_n) begin
            ex_if_ready_o = 1;
            processing_request = 0;
            processing_response = 0;
        end
        
        // Ready state
        if (rst_n == 0 && ex_if_ready_o) begin
            processing_request = 0;
            processing_response = 0;
        end
        
        // Processing request
        if (rst_n == 0 && processing_request) begin
            if (dmem_gnt_i) begin
                ex_if_ready_o = 0;
                processing_response = 1;
            end
        end
        
        // Processing response
        if (rst_n == 0 && processing_response) begin
            ex_if_ready_o = 1;
            processing_request = 0;
            processing_response = 0;
        end
    end
endmodule
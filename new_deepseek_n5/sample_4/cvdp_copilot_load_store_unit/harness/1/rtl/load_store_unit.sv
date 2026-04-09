class load_store_unit
  ports (
    input clock,
    input rst_n,
    output dmem_req_o,
    input dmem_req_addr_o,
    input dmem_req_we_o,
    input dmem_req_be_o,
    input dmem_req_wdata_o,
    input dmem_gnt_i,
    input dmem_RSP_rdata_i,
    input wb_if_rvalid_o,
    input wb_if_rdata_o
  );
  
  behavior
    always_comb begin
      // Reset behavior
      if (rst_n) 
        dmem_req_o = 0;
        dmem_req_addr_o = 0;
        dmem_req_we_o = 0;
        dmem_req_be_o = 0;
        dmem_req_wdata_o = 0;
        dmem_gnt_i = 0;
        wb_if_rvalid_o = 0;
        wb_if_rdata_o = 0;
        ex_if_ready_o = 1;
    end

    always begin
      case (ex_if_ready_o, ex_if_req_i, ex_if_type_i, ex_if_wdata_i, ex_if_addr_base_i, ex_if_addr_offset_i)
        // Process load/store request
        when (1, 1, _, _, _, _)
          // Validate address alignment
          reg addr = ex_if_addr_base_i + ex_if_addr_offset_i;
          case (ex_if_type_i)
            // Byte access
            when (0b00)
              if (addr & 0b11 == 0b00)
                // Send request to memory
                dmem_req_o = 1;
                dmem_req_addr_o = addr;
                dmem_req_we_o = 0;
                dmem_req_be_o = 0;
                dmem_req_wdata_o = 0;
                ex_if_ready_o = 0;
              end
            // Halfword access
            when (0b01)
              if ((addr & 0b11) == 0b10)
                dmem_req_o = 1;
                dmem_req_addr_o = addr;
                dmem_req_we_o = 0;
                dmem_req_be_o = 0;
                dmem_req_wdata_o = 0;
                ex_if_ready_o = 0;
              end
            // Word access
            when (0b10)
              if (addr & 0b11 == 0b00)
                dmem_req_o = 1;
                dmem_req_addr_o = addr;
                dmem_req_we_o = 0;
                dmem_req_be_o = 0;
                dmem_req_wdata_o = 0;
                ex_if_ready_o = 0;
              end
            default
              // Misaligned access
              dmem_req_o = 0;
              dmem_req_addr_o = 0;
              dmem_req_we_o = 0;
              dmem_req_be_o = 0;
              dmem_req_wdata_o = 0;
              ex_if_ready_o = 0;
              break;
          end
        // No request processing
        default
          dmem_req_o = 0;
          dmem_req_addr_o = 0;
          dmem_req_we_o = 0;
          dmem_req_be_o = 0;
          dmem_req_wdata_o = 0;
          ex_if_ready_o = 1;
      endcase
    end
  end
endmodule
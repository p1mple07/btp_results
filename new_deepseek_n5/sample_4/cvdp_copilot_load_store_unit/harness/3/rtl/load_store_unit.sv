Okay, so I need to modify the `load_store_unit` module to add a new input signal for sign-extension or zero-extension during data loading. Let me think about how to approach this.

First, I'll look at the current code structure. The module has several input signals, including `ex_if_wdata_i` which is a 32-bit word. I need to add a new input `ex_if_extend_mode_i` which is a 1-bit signal. That's straightforward—just adding the input line at the top.

Next, I need to handle the extension mode for smaller data types. The functional behavior says that for halfword and byte loads, the data should be extended based on this new mode. For word loads, the mode doesn't matter since they're already 32 bits.

Looking at the existing code, the data is loaded into a register based on the data type. For example, if it's a byte, the data is stored in `dmem_req_wdata_q` which is 8 bits. I need to modify this part to apply the extension based on `ex_if_extend_mode_i`.

So, after loading the data into the register, I should check the type and the extension mode. If it's a byte or halfword and the mode is 1, I need to sign-extend it. Otherwise, zero-extend it.

In Verilog, I can use the `truncreg` or bitwise operations to handle this. For sign-extension, I can use something like `ex_if_wdata_i & (2#10'1) << (32 - width)` where width is the data's bit width. For zero-extension, it's just shifting zeros.

Wait, but in the code, the data is stored in a register. So after the `always_comb` where the data is assigned to `dmem_req_wdata_q`, I should add a new always block that checks the extension mode and modifies the data accordingly.

I'll need to create a new register or modify the existing one. Maybe create a new signal like `extended_wdata` which is 32 bits. Then, based on the type and mode, compute this extended value.

So, after the initial assignment, I'll add an always block that does the following:

1. Determine the width based on `ex_if_type_i`.
2. If the extension mode is 1 and the type is byte or halfword, sign-extend the data.
3. If the mode is 0, zero-extend.
4. Assign the extended data to `wb_if_rdata_q` since that's where the writeback stage expects it.

I should also make sure that this happens before the data is sent to the writeback stage. So, in the `dmem_req` always_comb, I'll include the extended data.

Wait, no. The `dmem_req` is for the request interface, but the extension happens after the data is loaded into the register. So perhaps the extension should be done in the `always_comb` where the data is assigned to `dmem_req_wdata_q`. But since that's 8 bits, I need to extend it to 32 bits before sending it to the writeback stage.

Alternatively, maybe the extension should be done in the `always_ff` that updates `wb_if_rdata_q`. Hmm, but that's the writeback stage, so the data is already being sent there. So perhaps the extension needs to happen before that.

Wait, looking at the code, the `dmem_req_wdata_q` is 8 bits, and it's assigned to `wb_if_rdata_q` which is 32 bits. So perhaps in the `always_comb` that assigns `wb_if_rdata_o`, I can compute the extended value based on the mode.

Alternatively, maybe the extension should be done in the `always_ff` that updates `wb_if_rdata_q`. Let me think.

The `always_comb` for `dmem_req` sets `dmem_req_wdata_o` to `dmem_req_wdata_q`, which is 8 bits. Then, in the `always_ff` that handles the writeback response, `wb_if_rdata_q` is assigned from `dmem_rsp_rdata_i` and possibly modified based on the extension mode.

Wait, no. The `always_comb` for `dmem_req` is only for the request interface. The actual data sent to the writeback stage is handled in the `always_ff` that updates `wb_if_rdata_q`. So perhaps the extension needs to be done there.

So, in the `always_ff` that's triggered on posedge and negedge, when the data is being updated, I can check the extension mode and modify the data accordingly.

But wait, the extension mode is determined by `ex_if_extend_mode_i`, which is available at the EX stage. So perhaps the extension should be done when the data is being loaded into the register, i.e., in the `always_comb` that assigns `dmem_req_wdata_q`.

Alternatively, perhaps it's better to do it in the `always_comb` that assigns `wb_if_rdata_o`, since that's where the writeback data is being set.

Hmm, perhaps the best approach is to modify the `always_comb` that assigns `wb_if_rdata_o` to compute the extended value based on the mode.

Wait, but `dmem_req_wdata_q` is 8 bits, and `wb_if_rdata_q` is 32 bits. So perhaps in the `always_comb` that assigns `wb_if_rdata_o`, I can compute the extended value.

But I need to know the type of the data. So, I'll need to determine the width from `ex_if_type_i`. For example, if it's a byte (0x0), halfword (0x1), or word (0x2). For word, no extension is needed.

So, in the `always_comb` where `wb_if_rdata_o` is assigned, I can add a case based on `ex_if_type_i` and the extension mode.

Wait, but `ex_if_type_i` is a 3-bit signal, so I can get the width as 8, 16, or 32 bits. But since the data is stored in `dmem_req_wdata_q` as 8 bits, perhaps I need to zero-pad or sign-extend it to 32 bits.

Alternatively, perhaps the data is stored in a register that's 32 bits, but only the lower bits are loaded. So, I need to extend those 8 bits to 32 bits based on the mode.

Wait, looking back at the code, the data is loaded into `dmem_req_wdata_q` which is 8 bits. So, perhaps after that, in the `always_comb` that assigns `wb_if_rdata_o`, I can compute the extended value.

So, in the `always_comb` where `wb_if_rdata_o` is assigned, I can do something like:

if (ex_if_type_i is byte or halfword) {
    if (ex_if_extend_mode_i == 1) {
        sign_extend the data
    } else {
        zero_extend
    }
}

But how to implement sign extension in Verilog. For an 8-bit byte, to sign-extend to 32 bits, I can use something like `ex_if_wdata_i & (2#10'1) << (32 - 8)`.

Wait, but `ex_if_wdata_i` is a 32-bit word. So, for a byte, which is 8 bits, I need to take the lower 8 bits and extend them. So, for sign extension, I can create a mask that has the sign bit repeated.

Alternatively, perhaps using the `truncreg` or bitwise operations.

Wait, perhaps the easiest way is to create a 32-bit register and then assign the extended value based on the mode.

So, perhaps I should add a new register, say `extended_wdata`, which is 32 bits. Then, in the `always_comb` that assigns `dmem_req_wdata_q`, I can assign the lower bits, and then in another always block, compute the extended value.

Alternatively, perhaps it's better to compute the extended value in the `always_comb` that assigns `wb_if_rdata_o`.

Wait, but `dmem_req_wdata_q` is 8 bits, and `wb_if_rdata_q` is 32 bits. So, perhaps in the `always_comb` that assigns `wb_if_rdata_o`, I can compute the extended value based on the mode and the data type.

So, in code:

always_comb begin
    // Compute extended data
    logic [31:0] extended_wdata;
    case (ex_if_type_i)
        2'b00: // byte
            extended_wdata = (ex_if_wdata_i & 0xFF) & (0x1FFF << 24) | (ex_if_wdata_i & 0xFF);
            // Wait, no. For byte, it's 8 bits. So, for sign extension, the upper 24 bits should be the sign bit.
            // So, for a byte value, say 0x80, which is -128, sign-extended to 32 bits would be 0xFFFF_FFFF80.
            // So, the mask would be 0x10000000 | (ex_if_wdata_i & 0xFF) << 24.
            // Wait, perhaps a better way is to use the sign bit.
            // For 8 bits, the sign bit is bit 7. So, for sign extension, we replicate bit 7 to bits 31-8.
            // So, extended_wdata = (ex_if_wdata_i & 0xFF) & (0x100000000 >> (8 - width)) | (extension bits)
            // Alternatively, using a shift and mask.
            // Maybe using a helper function or a case statement.
            // Alternatively, using a built-in function like sign_extend.
            // But since we can't use built-ins, perhaps we can compute it manually.
            // For example, for a byte, 8 bits, sign-extended to 32 bits:
            // extended_wdata = (ex_if_wdata_i & 0xFF) & (0x10000000 | 0x100000000 | ... up to 24 bits)
            // Wait, perhaps a better approach is to create a mask that has the sign bit repeated.
            // For 8 bits, the mask would be 0x10000000 | 0x100000000 | ... up to 24 bits, but that's tedious.
            // Alternatively, using a bitwise shift and mask.
            // For example, for a byte, sign-extended:
            // extended_wdata = (ex_if_wdata_i & 0xFF) & (0x100000000 >> (8 - 8)) // which is 0x100000000
            // but that's 32 bits, so perhaps:
            // extended_wdata = (ex_if_wdata_i & 0xFF) & (0x100000000 >> (8 - 8)) | (extension bits)
            // Wait, perhaps it's easier to use a helper function or a case statement.
            // Alternatively, perhaps using a built-in function like sign_extend, but since we can't use that, perhaps we can compute it manually.
            // For now, perhaps I'll implement it with a case statement based on the type and mode.
            // So, for each type, I'll compute the extended value.
            // For word, no extension needed.
            // For byte and halfword, compute sign or zero extension.
            // So, in code:
            case (ex_if_type_i)
                2'b00: // byte
                    extended_wdata = (ex_if_wdata_i & 0xFF) & (0x100000000 >> 8) | (ex_if_wdata_i & 0xFF) << 24;
                    // Wait, perhaps not. Let me think again.
                    // For a byte, the 8 bits are in ex_if_wdata_i. To sign-extend, we need to set bits 31-8 to the sign bit of the byte.
                    // So, for example, if the byte is 0x80 (which is -128), the sign-extended 32-bit value is 0xFFFF_FFFF80.
                    // So, the mask would be 0x100000000 >> 8, which is 0x10000000, but that's only 24 bits. Hmm, perhaps I need to create a mask that has the sign bit repeated for the higher bits.
                    // Alternatively, perhaps using a shift and mask for each bit position.
                    // Alternatively, perhaps using a helper function or a lookup table.
                    // Since this is getting complicated, perhaps it's better to create a helper function or a case statement that handles each type and mode.
                    // For now, perhaps I'll proceed with the case statement approach.
                    // So, for each type, compute the extended value.
                    // For byte:
                    // extended_wdata = (ex_if_wdata_i & 0xFF) & (0x100000000 >> (8 - 8)) | (extension bits)
                    // Wait, perhaps it's easier to compute the extended value as follows:
                    // For sign extension: the higher bits are filled with the sign bit of the data.
                    // For zero extension: the higher bits are filled with 0.
                    // So, for a byte, 0x80 (sign-extended) becomes 0xFFFF_FFFF80.
                    // To compute this, I can take the lower 8 bits and shift them to the right by 24, then OR with the sign bit shifted to the left by 24.
                    // So, for sign extension:
                    // extended_wdata = (ex_if_wdata_i & 0xFF) << 24 | ( (ex_if_wdata_i & 0xFF) >> 7 ) & 1 << 24;
                    // Similarly, for zero extension:
                    // extended_wdata = (ex_if_wdata_i & 0xFF) << 24;
                    // So, in code:
                    extended_wdata = (ex_if_wdata_i & 0xFF) << 24;
                    if (ex_if_extend_mode_i == 1) {
                        extended_wdata |= ( (ex_if_wdata_i & 0xFF) >> 7 ) & 1 << 24;
                    }
                2'b01: // halfword
                    // Similar logic, but for 16 bits.
                    extended_wdata = (ex_if_wdata_i & 0x0000FF00) << 8;
                    if (ex_if_extend_mode_i == 1) {
                        extended_wdata |= ( (ex_if_wdata_i & 0x0000FF00) >> 15 ) & 1 << 8;
                    }
                2'b10: // word
                    // No extension needed.
                    extended_wdata = ex_if_wdata_i;
                default:
                    extended_wdata = ex_if_wdata_i;
            endcase
        endcase
    // Now, assign the extended_wdata to wb_if_rdata_o
    wb_if_rdata_o = extended_wdata;
end

Wait, but this might not be the most efficient way. Alternatively, perhaps using a helper function or a built-in function would be better, but since we can't use built-ins, perhaps the case statement is the way to go.

Wait, but in the code, `ex_if_wdata_i` is a 32-bit signal, so for a byte, the lower 8 bits are loaded into `dmem_req_wdata_q`. So, to extend it, I need to take those 8 bits and replicate them to 32 bits based on the mode.

So, for example, if the mode is 1 (sign-extend), the 8 bits are replicated to the higher 24 bits. If mode is 0, they are zero-padded.

So, in code, for a byte:

extended_wdata = (ex_if_wdata_i & 0xFF) << 24;
if (ex_if_extend_mode_i == 1) {
    extended_wdata |= ( (ex_if_wdata_i & 0xFF) >> 7 ) & 1 << 24;
}

Similarly for halfword, but shifted differently.

So, putting it all together, I'll add the `extended_wdata` register and modify the `always_comb` that assigns `wb_if_rdata_o` to use this extended value.

I also need to add the new input line at the top of the module.

So, the changes are:

1. Add `ex_if_extend_mode_i` as a 1-bit input.
2. In the `always_comb` that assigns `wb_if_rdata_o`, compute the extended value based on `ex_if_type_i` and `ex_if_extend_mode_i`.
3. Assign this extended value to `wb_if_rdata_o`.

I think that's the plan. Now, I'll write the modified code accordingly.


verilog
// Add new input signal for extension mode
module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,

    // EX stage interface
    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input logic     [31:0]      ex_if_addr_base_i,     // Base address
    input logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    output logic                 ex_if_ready_o,

    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,        // Requested data valid

    // Data memory (DMEM) interface
    output logic     [31:0]      dmem_req_we_q,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_wr_rdata_i,
    input  logic                 dmem_rvalid_i
);

  // Internal signals
  logic ex_req_fire;
  logic dmem_req_we_q;
  logic [31:0] data_addr_int;
  logic misaligned_addr;
  logic [31:0] case (ex_if_type_i)  // 0x2 (word), 0x1 (halfword), 0x0 (byte)
  case (ex_if_type_i)  // 0x2 (word), 0x1 (halfword), 0x0 (byte)
    2'b00: begin  // Writing a byte
        case (data_addr_int[1:0])
          2'b00:   dmem_be = 4'b0001;
          2'b01:   dmem_be = 4'b0010;
          2'b10:   dmem_be = 4'b0100;
          2'b11:   dmem_be = 4'b1000;
          default: dmem_be = 4'b0000;
        endcase
      end
      case (data_addr_int[1:0])
        2'b00:   dmem_be = 4'b0011;
        2'b01:   dmem_be = 4'b1100;
        default: begin
            dmem_be = 4'b0000;
            misaligned_addr = 1'b1;
        end
      end
      default: begin
          dmem_be = 4'b0000;
          misaligned_addr = 1'b1;
      end
    end

    2'b01: begin  // Writing a halfword
        case (data_addr_int[1:0])
          2'b00:   dmem_be = 4'b0011;
          2'b01:   dmem_be = 4'b1100;
          default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
          end
        endcase
        case (data_addr_int[1:0])
          2'b00:   dmem_be = 4'b1111;
          2'b10:   dmem_be = 4'b1100;
          default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
          end
        endcase
      end
    end

    2'b10: begin  // Writing a word
      case (data_addr_int[1:0])
        2'b00:   dmem_be = 4'b1111;
        2'b01:   dmem_be = 4'b1100;
        default: begin
            dmem_be = 4'b0000;
            misaligned_addr = 1'b1;
        end
      endcase
    end
    default: begin
        dmem_be = 4'b0000;
        misaligned_addr = 1'b1;
    end
  end

  // EX request fire condition
  ex_req_fire = ex_if_req_i && !busy_q && !misaligned_addr;

  ///////////////////////////////// Byte Enable Generation ////////////////////////////////
  always_comb begin
    misaligned_addr = 1'b0;
    dmem_be = 4'b0000;
    case (ex_if_type_i)  // 0x2 (word), 0x1 (halfword), 0x0 (byte)
      2'b00: begin  // Writing a byte
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0011;
            2'b01:   dmem_be = 4'b0010;
            2'b10:   dmem_be = 4'b0001;
            2'b11:   dmem_be = 4'b0000;
            default: dmem_be = 4'b0000;
          endcase
        end
        case (data_addr_int[1:0])
          2'b00:   dmem_be = 4'b0011;
          2'b01:   dmem_be = 4'b1100;
          default: begin
              dmem_be = 4'b0000;
              misaligned_addr = 1'b1;
          end
        endcase
      end
      case (data_addr_int[1:0])
        2'b00:   dmem_be = 4'b1111;
        2'b01:   dmem_be = 4'b1100;
        default: begin
            dmem_be = 4'b0000;
            misaligned_addr = 1'b1;
        end
      endcase
    end
    default: begin
        dmem_be = 4'b0000;
        misaligned_addr = 1'b1;
    end
  end

  // dmem_req ///////////////////////////////// 
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_rdata_q <= '0;
    end else if (ex_if_extend_mode_i) begin
      dmem_req_q <= dmem_req_we_i;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_rdata_q <= ex_if_wdata_i;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0 ;
      dmem_req_we_q <= '0 ;
      dmem_req_rdata_q <= '0 ;
    end
  end

  // DMEM Request Interface ///////////////////////////////// 
  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_i   = dmem_req_addr_q;
    dmem_req_we_i     = dmem_req_we_q;
    dmem_req_rdata_i  = dmem_req_rdata_q;
  end

  // Data memory (DMEM) interface
  output logic                 dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
  output logic     [31:0]      dmem_req_wr_rdata_i,
  input  logic                 dmem_rvalid_i
  output logic     [31:0]      dmem_req_wr_rdata_q,
  input  logic                 dmem_gnt_i
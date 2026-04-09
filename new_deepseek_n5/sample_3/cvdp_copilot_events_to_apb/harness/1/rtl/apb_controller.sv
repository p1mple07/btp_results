module apb_controller (
    input clock,
    input reset_n,
    input select_a_i,
    input select_b_i,
    input select_c_i,
    input [31:0] addr_a_i,
    input [31:0] data_a_i,
    input [31:0] addr_b_i,
    input [31:0] data_b_i,
    input [31:0] addr_c_i,
    input [31:0] data_c_i,
    input apb_pready_i,
    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output reg apb_paddr_o,
    output reg apb_pwdata_o
);

    // State variables
    reg state = IDLE;
    reg sel_addr = 0;
    reg sel_data = 0;
    reg timeout = 0;
    reg ready = 0;

    // Always comb to handle event detection
    always_comb begin
        if ((select_a_i && !select_b_i && !select_c_i) || 
            (select_b_i && !select_a_i && !select_c_i) || 
            (select_c_i && !select_a_i && !select_b_i)) begin
            case state
                IDLE: state = IDLE;
                sel_addr = addr_i;
                sel_data = data_i;
                state = IDLE;
                break;
            endcase
        end if
    end

    // Always clocked to handle state transitions
    always clock begin
        case state
            IDLE: begin
                // Event detection
                if ((select_a_i && !select_b_i && !select_c_i) || 
                    (select_b_i && !select_a_i && !select_c_i) || 
                    (select_c_i && !select_a_i && !select_b_i)) begin
                    state = SETUP;
                    apb_psel_o = 1;
                    apb_pwrite_o = 0;
                    apb_paddr_o = addr_i;
                    apb_pwdata_o = data_i;
                end else begin
                    apb_psel_o = 0;
                    apb_pwrite_o = 0;
                    apb_paddr_o = 0;
                    apb_pwdata_o = 0;
                end
                state = IDLE;
            end

            SETUP: begin
                apb_psel_o = 1;
                apb_pwrite_o = 1;
                apb_paddr_o = sel_addr;
                apb_pwdata_o = sel_data;
                state = ACCESS;
                timeout = 0;
            end

            ACCESS: begin
                apb_penable_o = 1;
                if (apb_pready_i) begin
                    apb_penable_o = 0;
                    state = IDLE;
                end else begin
                    timeout = timeout + 1;
                    if (timeout >= 15) begin
                        state = IDLE;
                        apb_psel_o = 0;
                        apb_penable_o = 0;
                        apb_pwrite_o = 0;
                        apb_paddr_o = 0;
                        apb_pwdata_o = 0;
                    end
                end
            end
        end
    end

    // Initial state setup
    always begin
        state = IDLE;
        sel_addr = 0;
        sel_data = 0;
        timeout = 0;
        ready = 0;
    end

    // Output assertion in IDLE state
    always clock begin
        if (state == IDLE) begin
            apb_psel_o = 0;
            apb_penable_o = 0;
            apb_pwrite_o = 0;
            apb_paddr_o = 0;
            apb_pwdata_o = 0;
        end
    end
endmodule
module apb_controller (
    input wire [31:0] addr_a, addr_b, addr_c,
    input wire [31:0] data_a, data_b, data_c,
    input wire select_a, select_b, select_c,
    input wire clk,
    input wire reset_n,
    output wire apb_psel_o,
    output wire apb_penable_o,
    output wire apb_pwrite_o,
    output wire apb_paddr_o,
    output wire apb_pwdata_o
);

    // State variables
    reg state = IDLE;
    reg sel_addr = 0;
    reg sel_data = 0;
    reg [3] timeout_counter = 0;
    reg [3] reset_counter = 0;

    // Helper function to determine priority of event
    function real get_priority(input wire select);
        if (select == select_a) return 0;
        if (select == select_b) return 1;
        if (select == select_c) return 2;
        return 3;
    endfunction

    // IDLE state
    always @(posedge clk or negedge reset_n) begin
        if (reset_n) begin
            state = IDLE;
            sel_addr = 0;
            sel_data = 0;
            timeout_counter = 0;
            reset_counter = 0;
        end else if (select_a || select_b || select_c) begin
            // Determine highest priority event
            integer sel = get_priority(select_a ? 0 : (select_b ? 1 : 2));
            sel_addr = (select_a ? addr_a : (select_b ? addr_b : addr_c));
            sel_data = (select_a ? data_a : (select_b ? data_b : data_c));
            state = SETUP;
        end
    end

    // SETUP phase
    always @(posedge clk) begin
        if (state == SETUP) begin
            apb_psel_o = 1;
            apb_paddr_o = sel_addr;
            apb_pwdata_o = sel_data;
            apb_penable_o = 0;
            state = ACCESS;
        end
    end

    // ACCESS phase
    always @(posedge clk) begin
        if (state == ACCESS) begin
            if (apb_pready_i) begin
                // Transaction completed
                apb_psel_o = 0;
                apb_penable_o = 0;
                apb_pwrite_o = 0;
                apb_paddr_o = 0;
                apb_pwdata_o = 0;
                state = IDLE;
                sel_addr = 0;
                sel_data = 0;
                timeout_counter = 0;
            else begin
                timeout_counter = timeout_counter + 1;
                if (timeout_counter >= 15) begin
                    // Timeout occurred
                    state = IDLE;
                    apb_psel_o = 0;
                    apb_penable_o = 0;
                    apb_pwrite_o = 0;
                    apb_paddr_o = 0;
                    apb_pwdata_o = 0;
                    sel_addr = 0;
                    sel_data = 0;
                    timeout_counter = 0;
                end
            end
        end
    end

    // Reset state
    always @(posedge clk) begin
        if (state == IDLE) begin
            if (reset_n) begin
                state = IDLE;
                sel_addr = 0;
                sel_data = 0;
                timeout_counter = 0;
                reset_counter = 0;
            end
        end
    end
endmodule
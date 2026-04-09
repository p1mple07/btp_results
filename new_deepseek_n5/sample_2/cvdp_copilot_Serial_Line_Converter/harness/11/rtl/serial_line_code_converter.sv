module serial_line_code_converter #(parameter CLK_DIV = 16),
    (parameter enable) 
    (
        input logic clk, 
        input logic reset_n, 
        input logic serial_in, 
        input logic [2:0] mode, 
        input enable
    );
    output logic serial_out;
    output logic error_flag;
    output logic diagnostic_bus;
    
    // Internal signals
    logic [3:0] clk_counter;
    logic logic[16:0] diagnostic_bus;
    logic clock_pulse;
    logic prev_serial_in;
    logic prev_value;
    logic nrz_out;
    logic rz_out;
    logic diff_out;
    logic inv_nrz_out;
    logic alt_invert_out;
    logic alt_invert_state;
    logic parity_out;
    logic scrambled_out;
    logic edge_triggered_out;
    logic error_counter;
    logic error_flag;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clock_pulse <= 0;
            prev_serial_in <= 0;
            prev_value <= 0;
        end else if (clk_counter == CLK_DIV - 1) begin
            clock_pulse <= 1;
            prev_serial_in <= prev_value;
        end else begin
            clk_counter <= clk_counter + 1;
            prev_value <= serial_in;
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                nrz_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                nrz_out <= serial_in;
            end
            clock_pulse <= 0;
        end else begin
            if (enable) begin
                clock_pulse <= 0;
                prev_serial_in <= 0;
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                rz_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                rz_out <= serial_in & clock_pulse;
            end
            clock_pulse <= 1;
        end else begin
            if (enable) begin
                rz_out <= serial_in & clock_pulse;
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                diff_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                diff_out <= serial_in ^ prev_serial_in;
            end
            clock_pulse <= 0;
        end else begin
            if (enable) begin
                diff_out <= serial_in ^ prev_serial_in;
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                inv_nrz_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                inv_nrz_out <= ~serial_in;
            end
            clock_pulse <= 1;
        end else begin
            if (enable) begin
                inv_nrz_out <= ~serial_in;
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                alt_invert_out <= 0;
                alt_invert_state <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
                alt_invert_state <= ~alt_invert_state;
            end
            clock_pulse <= 0;
        end else begin
            if (enable) begin
                alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
                alt_invert_state <= ~alt_invert_state;
            end
            clock_pulse <= 0;
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                parity_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                parity_out <= serial_in ^ parity_out;
            end
            clock_pulse <= 1;
        end else begin
            if (enable) begin
                parity_out <= serial_in ^ parity_out;
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                scrambled_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                scrambled_out <= serial_in ^ (clk_counter[0] & ~prev_serial_in);
            end
            clock_pulse <= 1;
        end else begin
            if (enable) begin
                scrambled_out <= serial_in ^ (clk_counter[0] & ~prev_serial_in);
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if (enable) begin
                edge_triggered_out <= 0;
            end
        end else if (clk_counter == CLK_DIV - 1) begin
            if (enable) begin
                edge_triggered_out <= (serial_in & ~prev_serial_in);
            end
            clock_pulse <= 1;
        end else begin
            if (enable) begin
                edge_triggered_out <= (serial_in & ~prev_serial_in);
            end
            clock_pulse <= 0;
        end
    end
    
    always_comb begin
        case (mode)
            3'b000: serial_out = nrz_out;
            3'b001: serial_out = rz_out;
            3'b010: serial_out = diff_out;
            3'b011: serial_out = inv_nrz_out;
            3'b100: serial_out = alt_invert_out;
            3'b101: serial_out = parity_out;
            3'b110: serial_out = scrambled_out;
            3'b111: serial_out = edge_triggered_out;
            default: serial_out = 0;
        endcase
        
        // Diagnostic Bus
        case (mode)
            3'b000: diagnostic_bus[15:13] = {3'b000, 0, 0, 0, 0, 0, 0, 0};
            3'b001: diagnostic_bus[15:13] = {3'b001, 0, 0, 0, 0, 0, 0, 0};
            3'b010: diagnostic_bus[15:13] = {3'b010, 0, 0, 0, 0, 0, 0, 0};
            3'b011: diagnostic_bus[15:13] = {3'b011, 0, 0, 0, 0, 0, 0, 0};
            3'b100: diagnostic_bus[15:13] = {3'b100, 0, 0, 0, 0, 0, 0, 0};
            3'b101: diagnostic_bus[15:13] = {3'b101, 0, 0, 0, 0, 0, 0, 0};
            3'b110: diagnostic_bus[15:13] = {3'b110, 0, 0, 0, 0, 0, 0, 0};
            3'b111: diagnostic_bus[15:13] = {3'b111, error_flag, error_counter, 0, 0, 0, 0, 0};
        endcase
        
        if (enable) begin
            if (mode == 3'b111) begin
                if (serial_in == 1'bx || serial_in == 1'bz) begin
                    error_flag <= 1;
                    error_counter <= error_counter + 1;
                end
                diagnostic_bus[12] <= error_flag;
                diagnostic_bus[11:4] <= error_counter;
                diagnostic_bus[3] <= clock_pulse;
                diagnostic_bus[2] <= serial_out;
                diagnostic_bus[1] <= alt_invert_out;
                diagnostic_bus[0] <= parity_out;
            end
        end
    end
endmodule
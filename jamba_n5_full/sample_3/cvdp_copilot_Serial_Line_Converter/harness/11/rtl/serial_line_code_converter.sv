module serial_line_code_converter #(
    parameter CLK_DIV = 16
) (
    input  logic clk,
    input  logic reset_n,
    input  logic serial_in,
    input  logic enable,          // New enable signal to control functionality
    output logic serial_out,
    output logic error_flag,
    output logic diagnostic_bus [15:0],
    output logic clock_pulse,
    output logic clk_pulse,
    output logic nrz_out,
    output logic rz_out,
    output diff_out,
    output inv_nrz_out,
    output alt_invert_out,
    output alt_invert_state,
    output parity_out,
    output scrambled_out,
    output edge_triggered_out
);

    // Internal state and counters
    localparam CLK_CYCLE = 1 / CLK_DIV;
    reg [CLK_CYCLE-1:0] clk_counter;
    reg [2:0] mode;
    reg [3:0] prev_serial_in;
    reg [2:0] prev_value;
    reg nrz_out_temp;
    reg rz_out_temp;
    reg diff_out_temp;
    reg inv_nrz_out_temp;
    reg alt_invert_out_temp;
    reg alt_invert_state_reg;
    reg parity_out_temp;
    reg scrambled_out_temp;
    reg edge_triggered_out_temp;
    reg error_flag_reg;
    reg error_counter_reg;
    reg [15:0] diagnostic_bus_reg;

    // Clock divider counter
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 0;
        end else if (clk_counter == CLK_DIV - 1) begin
            clk_counter <= 0;
            clk_pulse <= 1;
        end else begin
            clk_counter <= clk_counter + 1;
            clk_pulse <= 0;
        end
    end

    // Generate clock pulse
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clock_pulse <= 0;
        end else begin
            if (clk_counter == 0) begin
                clock_pulse <= 1;
            end else begin
                clock_pulse <= 0;
            end
        end
    end

    // Previous serial input storage
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_serial_in <= 0;
            prev_value <= 0;
        end else begin
            prev_serial_in <= serial_in;
            prev_value <= prev_serial_in;
        end
    end

    // NRZ encoding with fallback
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else begin
            nrz_out <= serial_in;
        end
    end

    // RZ encoding (simplified)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            rz_out <= serial_in & (prev_serial_in & 1);
        end
    end

    // Differential encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            diff_out <= 0;
        end else begin
            diff_out <= serial_in ^ prev_serial_in;
        end
    end

    // Inverted NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            inv_nrz_out <= 0;
        end else begin
            inv_nrz_out <= ~serial_in;
        end
    end

    // NRZ with alternating bit inversion
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_out <= 0;
        end else begin
            alt_invert_state <= ~alt_invert_state;
            alt_invert_out <= alt_invert_state ? ~serial_in : serial_in;
        end
    end

    // Parity bit output
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= serial_in ^ parity_out;
        end
    end

    // Scrambled NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else begin
            scrambled_out <= serial_in ^ clk_counter[0];
        end
    end

    // Edge-triggered NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    // Main output logic with enable control
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
            default: serial_out <= 0;
        endcase
    end

    // Diagnostic bus generation
    always_comb begin
        diagnostic_bus_reg = 0;
        diagnostic_bus_reg[15:13] = mode;
        diagnostic_bus_reg[12] = error_flag;
        diagnostic_bus_reg[11:4] = error_counter;
        diagnostic_bus_reg[3] = clk_pulse;
        diagnostic_bus_reg[2] = serial_out;
        diagnostic_bus_reg[1] = nrz_out;
        diagnostic_bus_reg[0] = parity_out;
    end

endmodule

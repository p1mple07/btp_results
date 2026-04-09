module serial_line_code_converter #(parameter CLK_DIV = 16)(
    input  logic clk,
    input  logic reset_n,
    input  logic serial_in,
    input  logic [2:0] mode,
    output logic serial_out
);

    // Internal signals
    logic [3:0] clk_counter;
    logic clk_pulse;
    logic prev_serial_in;
    logic prev_value;
    logic nrz_out;
    logic rz_out;
    logic diff_out;
    logic inv_nrz_out;
    logic alt_invert_out;
    logic parity_out;
    logic scrambled_out;
    logic edge_triggered_out;

    // Initialization
    initial begin
        clk_counter = 0;
        prev_serial_in = 0;
        prev_value = 0;
    end

    // Clock Pulse Generation
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter = 0;
            clk_pulse = 0;
        end else begin
            if (clk_counter == CLK_DIV - 1) begin
                clk_pulse = 1;
                clk_counter = 0;
            end else begin
                clk_pulse = 0;
            end
        end
    end

    // NRZ Pass-Through
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            nrz_out <= 0;
        end else begin
            nrz_out <= serial_in;
        end
    end

    // RZ Encoding
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rz_out <= 0;
        end else begin
            if (serial_in == 1) begin
                if (clk_counter < CLK_DIV / 2) begin
                    rz_out <= 1;
                end else begin
                    rz_out <= 0;
                end
            end else begin
                rz_out <= 0;
            end
            prev_serial_in <= serial_in;
        end
    end

    // Differential Encoding
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

    // NRZ with Alternating Bit Inversion
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            alt_invert_state <= 0;
        end else begin
            if (alt_invert_state == 0) begin
                alt_invert_state <= 1;
            end else begin
                alt_invert_state <= 0;
            end
        end
        if (serial_in != alt_invert_state) begin
            alt_invert_state <= !alt_invert_state;
        end
        if (alt_invert_state) begin
            alt_invert_out <= 1;
        end else begin
            alt_invert_out <= 0;
        end
    end

    // Parity Bit Output (Odd Parity)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            parity_out <= 0;
        end else begin
            parity_out <= serial_in;
        end
    end

    // Scrambled NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scrambled_out <= 0;
        end else begin
            scrambled_out <= serial_in ^ (1'b'1' << (clk_counter % 4));
        end
    end

    // Edge-Triggered NRZ
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            edge_triggered_out <= 0;
        end else begin
            edge_triggered_out <= (serial_in & ~prev_serial_in);
        end
    end

    // Output multiplexer
    assign serial_out = 
        mode == 000 ? nrz_out :
        mode == 001 ? rz_out :
        mode == 010 ? diff_out :
        mode == 011 ? inv_nrz_out :
        mode == 100 ? parity_out :
        mode == 101 ? alt_invert_out :
        mode == 110 ? scrambled_out :
        mode == 111 ? edge_triggered_out :
        0;

endmodule

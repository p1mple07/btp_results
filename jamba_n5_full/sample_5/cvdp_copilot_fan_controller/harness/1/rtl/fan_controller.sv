module fan_controller (
    input wire clk,
    input wire reset,
    output reg fan_pwm_out,

    input  wire         psel,
    input  wire         penable,
    input  wire         pwrite,
    input  wire [7:0]   paddr,
    input  wire [7:0]   pwdata,
    output reg  [7:0]   prdata,
    output reg          pready,
    output reg          pslverr
);

reg [31:0] temp_adc_in;
reg [3:0] temp_low_thresh, temp_med_thresh, temp_high_thresh;
reg temp_current_temp;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        temp_adc_in <= 0;
        temp_low_thresh <= 0;
        temp_med_thresh <= 0;
        temp_high_thresh <= 0;
        temp_current_temp <= 0;
    end else begin
        temp_adc_in <= temp_adc_in;
    end
end

always @(*) begin
    case (psel)
        '0: begin
            // Setup phase
        end
        '1: begin
            // Access phase
            if (penable) begin
                if (pwrite) begin
                    // Write operation
                    if (paddr == 8'h0A) begin
                        temp_adc_in <= temp_low_thresh;
                    end else if (paddr == 8'h0B) begin
                        temp_adc_in <= temp_med_thresh;
                    end else if (paddr == 8'h0C) begin
                        temp_adc_in <= temp_high_thresh;
                    end else if (paddr == 8'h0F) begin
                        // read data
                        prdata <= temp_adc_in;
                        pslverr <= 0;
                    end else begin
                        pslverr <= 1;
                    end
                end else begin
                    pslverr <= 1;
                end
            end else begin
                pslverr <= 1;
            end
        end
        default: pslverr <= 1;
    endcase
end

always @(*) begin
    // Temperature comparison logic
    if (temp_adc_in > temp_high_thresh) begin
        fan_pwm_out <= 1;
    end else if (temp_adc_in > temp_med_thresh) begin
        fan_pwm_out <= 0;
    end else if (temp_adc_in > temp_low_thresh) begin
        fan_pwm_out <= 1;
    end else begin
        fan_pwm_out <= 0;
    end
end

endmodule

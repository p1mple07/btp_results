module compliant with the Advanced Peripheral Bus (APB)
//              protocol. Supports configurable GPIO width, bidirectional control, interrupt
//              generation (both edge‐ and level‐sensitive) with polarity configuration, and
//              robust two‐stage synchronization.
//              
//              Register Map:
//                0x00: GPIO Input Data       (Read-only; reflects synchronized gpio_in)
//                0x04: GPIO Output Data      (Writes drive gpio_out)
//                0x08: GPIO Output Enable    (Configures direction: High = Output, Low = Input)
//                0x0C: GPIO Interrupt Enable (Enables/disables per-pin interrupts)
//                0x10: GPIO Interrupt Type   (0 = Level sensitive, 1 = Edge sensitive)
//                0x14: GPIO Interrupt Polarity (1 = Active high, 0 = Active low)
//                0x18: GPIO Interrupt State  (Read-only; reflects current interrupt status)
//
//              APB Behavior:
//                - Always-high ready (pready = 1)
//                - No errors (pslverr = 0)
//                - Write transactions update registers; read transactions return the content
//                  of the addressed register.
//                - Undefined addresses return prdata = 0.
//
//              Interrupt Logic:
//                For each GPIO pin, if enabled:
//                  • In Level Sensitive mode (reg_int_type = 0):
//                      - If polarity is active high, an interrupt is asserted when the input is high.
//                      - If polarity is active low, an interrupt is asserted when the input is low.
//                  • In Edge Sensitive mode (reg_int_type = 1):
//                      - If polarity is active high, a rising edge triggers an interrupt.
//                      - If polarity is active low, a falling edge triggers an interrupt.
//                The combined interrupt (comb_int) is the logical OR of all individual interrupts.
//
//              Reset:
//                All registers and internal signals are reset to 0 when preset_n is low.
//
// Parameters:
//   GPIO_WIDTH: Default width is 8; can be reconfigured.
//
module cvdp_copilot_apb_gpio #(
    parameter GPIO_WIDTH = 8
)
(
    input  wire                   pclk,
    input  wire                   preset_n,  // Active-low asynchronous reset
    input  wire                   psel,
    input  wire [7:0]             paddr,     // Only lower 6 bits [7:2] are used for addressing
    input  wire                   penable,
    input  wire                   pwrite,
    input  wire [31:0]            pwdata,
    input  wire [GPIO_WIDTH-1:0]  gpio_in,
    output reg  [31:0]            prdata,
    output reg                    pready,
    output reg                    pslverr,
    output reg  [GPIO_WIDTH-1:0]  gpio_out,
    output reg  [GPIO_WIDTH-1:0]  gpio_enable,
    output reg  [GPIO_WIDTH-1:0]  gpio_int,
    output wire                   comb_int
);

    //-------------------------------------------------------------------------
    // Internal 32-bit registers for APB access (only lower GPIO_WIDTH bits are used)
    //-------------------------------------------------------------------------
    reg [31:0] reg_in;           // 0x00: GPIO Input Data (read-only)
    reg [31:0] reg_out;          // 0x04: GPIO Output Data
    reg [31:0] reg_enable;       // 0x08: GPIO Output Enable
    reg [31:0] reg_int_enable;   // 0x0C: GPIO Interrupt Enable
    reg [31:0] reg_int_type;     // 0x10: GPIO Interrupt Type (0 = level, 1 = edge)
    reg [31:0] reg_int_polarity; // 0x14: GPIO Interrupt Polarity (1 = active high, 0 = active low)
    reg [31:0] reg_int_state;    // 0x18: GPIO Interrupt State (read-only)

    //-------------------------------------------------------------------------
    // Two-stage synchronization for gpio_in to mitigate metastability.
    //-------------------------------------------------------------------------
    reg [GPIO_WIDTH-1:0] gpio_in_sync;
    reg [GPIO_WIDTH-1:0] gpio_in_sync_prev;

    //-------------------------------------------------------------------------
    // Output assignments for APB protocol.
    //-------------------------------------------------------------------------
    // Always-ready and no-error signals.
    assign pready = 1'b1;
    assign pslverr = 1'b0;
    // Combined interrupt: logical OR of all individual gpio_int signals.
    assign comb_int = |gpio_int;

    //-------------------------------------------------------------------------
    // Interrupt Generation Logic:
    // For each GPIO pin:
    //   - If interrupt is enabled, then:
    //       • In Level Sensitive mode (reg_int_type = 0):
    //             If polarity is active high, assert interrupt when input is high.
    //             If polarity is active low, assert interrupt when input is low.
    //       • In Edge Sensitive mode (reg_int_type = 1):
    //             If polarity is active high, detect rising edge (transition 0->1).
    //             If polarity is active low, detect falling edge (transition 1->0).
    //-------------------------------------------------------------------------
    always_comb begin
        for (int i = 0; i < GPIO_WIDTH; i++) begin
            if (reg_int_enable[i]) begin
                if (!reg_int_type[i]) begin  // Level-sensitive mode
                    if (reg_int_polarity[i])
                        gpio_int[i] = gpio_in_sync[i];
                    else
                        gpio_int[i] = ~gpio_in_sync[i];
                end else begin  // Edge-sensitive mode
                    if (reg_int_polarity[i])
                        gpio_int[i] = (~gpio_in_sync_prev[i] & gpio_in_sync[i]); // Rising edge
                    else
                        gpio_int[i] = (gpio_in_sync_prev[i] & ~gpio_in_sync[i]); // Falling edge
                end
            end else begin
                gpio_int[i] = 1'b0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // Main Sequential Block:
    // Handles APB transactions, register updates, and gpio_in synchronization.
    //-------------------------------------------------------------------------
    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            // Asynchronous reset: clear all registers and synchronization flip-flops.
            reg_in          <= 32'd0;
            reg_out         <= 32'd0;
            reg_enable      <= 32'd0;
            reg_int_enable  <= 32'd0;
            reg_int_type    <= 32'd0;
            reg_int_polarity<= 32'd0;
            reg_int_state   <= 32'd0;
            gpio_in_sync    <= {GPIO_WIDTH{1'b0}};
            gpio_in_sync_prev <= {GPIO_WIDTH{1'b0}};
            prdata          <= 32'd0;
        end else begin
            // Two-stage synchronization for gpio_in.
            gpio_in_sync_prev <= gpio_in_sync;
            gpio_in_sync      <= gpio_in;
            // Update the read-only GPIO input register.
            reg_in <= {24'd0, gpio_in_sync};

            // Default prdata assignment to avoid latching an old value.
            prdata <= reg_in;

            // Process APB transactions only when psel and penable are asserted.
            if (psel && penable) begin
                case(paddr[7:2])
                    6'd0: begin
                        // 0x00: GPIO Input Data (read-only)
                        // Writes are ignored.
                        prdata <= reg_in;
                    end
                    6'd4: begin
                        // 0x04: GPIO Output Data
                        if (pwrite) begin
                            reg_out <= {24'd0, pwdata[GPIO_WIDTH-1:0]};
                        end
                        prdata <= reg_out;
                    end
                    6'd8: begin
                        // 0x08: GPIO Output Enable
                        if (pwrite) begin
                            reg_enable <= {24'd0, pwdata[GPIO_WIDTH-1:0]};
                        end
                        prdata <= reg_enable;
                    end
                    6'd12: begin
                        // 0x0C: GPIO Interrupt Enable
                        if (pwrite) begin
                            reg_int_enable <= {24'd0, pwdata[GPIO_WIDTH-1:0]};
                        end
                        prdata <= reg_int_enable;
                    end
                    6'd16: begin
                        // 0x10: GPIO Interrupt Type (0 = level, 1 = edge)
                        if (pwrite) begin
                            reg_int_type <= {24'd0, pwdata[GPIO_WIDTH-1:0]};
                        end
                        prdata <= reg_int_type;
                    end
                    6'd20: begin
                        // 0x14: GPIO Interrupt Polarity (1 = active high, 0 = active low)
                        if (pwrite) begin
                            reg_int_polarity <= {24'd0, pwdata[GPIO_WIDTH-1:0]};
                        end
                        prdata <= reg_int_polarity;
                    end
                    6'd24: begin
                        // 0x18: GPIO Interrupt State (read-only)
                        prdata <= {24'd0, gpio_int};
                    end
                    default: begin
                        // Undefined address: no effect; prdata returns 0.
                        prdata <= 32'd0;
                    end
                endcase
            end
        end
    end

    //-------------------------------------------------------------------------
    // Drive GPIO Output and Direction based on registered values.
    //-------------------------------------------------------------------------
    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n)
            gpio_out <= {GPIO_WIDTH{1'b0}};
        else
            gpio_out <= reg_out[GPIO_WIDTH-1:0];
    end

    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n)
            gpio_enable <= {GPIO_WIDTH{1'b0}};
        else
            gpio_enable <= reg_enable[GPIO_WIDTH-1:0];
    end

endmodule
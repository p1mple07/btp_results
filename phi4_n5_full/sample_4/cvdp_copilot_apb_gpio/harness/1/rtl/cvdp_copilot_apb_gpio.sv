module compliant with the Advanced Peripheral Bus (APB)
    protocol. Supports a configurable GPIO width, bidirectional operation,
    interrupt generation (both edge- and level-sensitive), and robust input
    synchronization using two-stage flip-flops.

  Register Map:
    Address   Description
    0x00      GPIO Input Data (Read-only): Synchronized state of gpio_in.
    0x04      GPIO Output Data: Controls gpio_out signals.
    0x08      GPIO Output Enable: Configures direction (High = output, Low = input).
    0x0C      GPIO Interrupt Enable: Enables/disables individual GPIO interrupts.
    0x10      GPIO Interrupt Type: 0 = Level Sensitive, 1 = Edge Sensitive.
    0x14      GPIO Interrupt Polarity: 0 = Active High, 1 = Active Low.
    0x18      GPIO Interrupt State (Read-only): Reflects current interrupt status.

  APB Protocol:
    - pclk: Rising edge clock.
    - preset_n: Active-low asynchronous reset (resets all registers/outputs to 0).
    - psel: Peripheral select.
    - paddr[7:2]: APB address bus (valid addresses: 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18).
    - penable: Transfer control signal.
    - pwrite: Write control signal (high = write, low = read).
    - pwdata[31:0]: Write data bus.
    - prdata[31:0]: Read data bus (lower 8 bits used for registers; upper bits = 0).
    - pready: Always high.
    - pslverr: Always low.

  GPIO Behavior:
    - gpio_out is driven by the output data register.
    - gpio_enable configures pin direction (High = output, Low = input).
    - gpio_in is synchronized using a two-stage flip-flop (gpio_in_sync, gpio_in_sync2)
      to mitigate metastability.
    - Interrupts are generated based on configuration:
         • Level Sensitive: Active if gpio_in (after sync) matches the configured polarity.
         • Edge Sensitive: Active on rising or falling edge transitions (detected using gpio_prev).

  Note:
    - Undefined APB addresses return prdata = 0.
    - Writes to read-only registers (GPIO Input Data and GPIO Interrupt State) are ignored.
    - All outputs respond within one clock cycle.
*/

module cvdp_copilot_apb_gpio #(parameter GPIO_WIDTH = 8) (
    input  logic           pclk,
    input  logic           preset_n,
    input  logic           psel,
    input  logic [7:0]     paddr,  // Only lower 6 bits used for address decoding.
    input  logic           penable,
    input  logic           pwrite,
    input  logic [31:0]    pwdata,
    input  logic [GPIO_WIDTH-1:0] gpio_in,
    output logic [31:0]    prdata,
    output logic           pready,
    output logic           pslverr,
    output logic [GPIO_WIDTH-1:0] gpio_out,
    output logic [GPIO_WIDTH-1:0] gpio_enable,
    output logic [GPIO_WIDTH-1:0] gpio_int,
    output logic           comb_int
);

  //-------------------------------------------------------------------------
  // Internal Registers and Wires
  //-------------------------------------------------------------------------
  // Read-only registers (lower 8 bits used; upper bits are 0)
  logic [GPIO_WIDTH-1:0] reg_gpio_in;       // Synchronized GPIO input (0x00)
  logic [GPIO_WIDTH-1:0] reg_out;           // Output data register (0x04)
  logic [GPIO_WIDTH-1:0] reg_out_enable;    // Output enable register (0x08)
  logic [GPIO_WIDTH-1:0] reg_int_enable;    // Interrupt enable register (0x0C)
  logic [GPIO_WIDTH-1:0] reg_int_type;      // Interrupt type register (0x10)
  logic [GPIO_WIDTH-1:0] reg_int_polarity;  // Interrupt polarity register (0x14)
  logic [GPIO_WIDTH-1:0] reg_int_state;     // Interrupt state register (0x18; read-only)
  logic [GPIO_WIDTH-1:0] gpio_prev;         // Previous state for edge detection

  // Two-stage synchronization for gpio_in
  logic [GPIO_WIDTH-1:0] gpio_in_sync;
  logic [GPIO_WIDTH-1:0] gpio_in_sync2;

  //-------------------------------------------------------------------------
  // APB Read Data Logic
  //-------------------------------------------------------------------------
  // prdata is assigned based on the decoded address.
  // Only the lower 8 bits of prdata are used; upper bits are zero.
  always_comb begin
    prdata = 32'd0;
    case (paddr[7:2])
      6'd0: begin
        prdata[7:0] = reg_gpio_in;
      end
      6'd4: begin
        prdata[7:0] = reg_out;
      end
      6'd8: begin
        prdata[7:0] = reg_out_enable;
      end
      6'd12: begin
        prdata[7:0] = reg_int_enable;
      end
      6'd16: begin
        prdata[7:0] = reg_int_type;
      end
      6'd20: begin
        prdata[7:0] = reg_int_polarity;
      end
      6'd24: begin
        prdata[7:0] = reg_int_state;
      end
      default: prdata = 32'd0;
    endcase
  end

  //-------------------------------------------------------------------------
  // APB Write and Register Update Logic
  //-------------------------------------------------------------------------
  // All registers and internal states are updated on the rising edge of pclk.
  // An asynchronous reset (preset_n low) sets all registers to 0.
  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      // Asynchronous reset: initialize all registers and outputs to 0.
      reg_gpio_in        <= {GPIO_WIDTH{1'b0}};
      reg_out            <= {GPIO_WIDTH{1'b0}};
      reg_out_enable     <= {GPIO_WIDTH{1'b0}};
      reg_int_enable     <= {GPIO_WIDTH{1'b0}};
      reg_int_type       <= {GPIO_WIDTH{1'b0}};
      reg_int_polarity   <= {GPIO_WIDTH{1'b0}};
      reg_int_state      <= {GPIO_WIDTH{1'b0}};
      gpio_prev          <= {GPIO_WIDTH{1'b0}};
    end else begin
      // Two-stage synchronization for gpio_in.
      gpio_in_sync  <= gpio_in;
      gpio_in_sync2 <= gpio_in_sync;
      // Update the read-only GPIO input register.
      reg_gpio_in <= gpio_in_sync2;

      // Update previous state for edge detection.
      gpio_prev <= gpio_in_sync2;

      // Process APB write transactions.
      if (psel && penable) begin
        if (pwrite) begin
          case (paddr[7:2])
            6'd0: begin
              // GPIO Input Data: read-only, ignore write.
            end
            6'd4: begin
              reg_out <= pwdata[7:0];
            end
            6'd8: begin
              reg_out_enable <= pwdata[7:0];
            end
            6'd12: begin
              reg_int_enable <= pwdata[7:0];
            end
            6'd16: begin
              reg_int_type <= pwdata[7:0];
            end
            6'd20: begin
              reg_int_polarity <= pwdata[7:0];
            end
            6'd24: begin
              // GPIO Interrupt State: read-only, ignore write.
            end
            default: ;
          endcase
        end
      end
    end
  end

  //-------------------------------------------------------------------------
  // Interrupt Logic
  //-------------------------------------------------------------------------
  // Compute the interrupt state for each GPIO pin.
  // For level-sensitive mode (reg_int_type = 0), the interrupt is active
  // if gpio_in_sync2 matches the configured polarity.
  // For edge-sensitive mode (reg_int_type = 1), the interrupt is active on
  // a rising edge (if reg_int_polarity = 0) or a falling edge (if reg_int_polarity = 1).
  always_comb begin
    reg_int_state = {GPIO_WIDTH{1'b0}};
    for (int i = 0; i < GPIO_WIDTH; i = i + 1) begin
      if (reg_int_enable[i]) begin
        if (reg_int_type[i] == 1'b0) begin
          // Level Sensitive Mode
          if (reg_int_polarity[i] == 1'b0)
            reg_int_state[i] = gpio_in_sync2[i];
          else
            reg_int_state[i] = ~gpio_in_sync2[i];
        end else begin
          // Edge Sensitive Mode
          if (reg_int_polarity[i] == 1'b0) begin
            // Rising edge: transition from 0 to 1.
            reg_int_state[i] = (gpio_prev[i] == 1'b0 && gpio_in_sync2[i] == 1'b1);
          end else begin
            // Falling edge: transition from 1 to 0.
            reg_int_state[i] = (gpio_prev[i] == 1'b1 && gpio_in_sync2[i] == 1'b0);
          end
        end
      end else begin
        reg_int_state[i] = 1'b0;
      end
    end
  end

  // Drive the individual GPIO interrupt outputs.
  assign gpio_int = reg_int_state;
  // Combined interrupt signal is the logical OR of all individual interrupts.
  assign comb_int = |gpio_int;

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  // Drive gpio_out with the output data register.
  assign gpio_out = reg_out;
  // Drive gpio_enable with the output enable register.
  assign gpio_enable = reg_out_enable;

  // APB Ready and Error signals.
  assign pready = 1'b1;
  assign pslverr = 1'b0;

endmodule
module one_hot_gen #(
    parameter NS_A = 'd8,
    parameter NS_B = 'd4
) (
    input  logic                 clk,
    input  logic                 rst_async_n,
    input  logic [1:0]           i_config,
    input  logic                 i_start,
    input  logic                 o_ready,
    output logic [NS_A+NS_B-1:0] o_address_one_hot
);

typedef enum logic [2:0] {IDLE = 2'b00, REGION_A = 2'b01, REGION_B = 2'b10} state_t;

// ----------------------------------------
// - Wires/Registers creation
// ----------------------------------------
state_t state_ff, state_nx;
logic [NS_A-1:0] region_A_ff, region_A_nx;
logic [NS_B-1:0] region_B_ff, region_B_nx;
logic A_to_B, B_to_A, only_A, only_B;

// Input register
logic [2:0] config_ff;

// ----------------------------------------
// - Wire connections
// ----------------------------------------

// Region change flags
assign A_to_B = ( config_ff[1] & ~config_ff[0]);
assign B_to_A = ( config_ff[1] &  config_ff[0]);
assign only_A = (~config_ff[0] & ~config_ff[0]);
assign only_B = (~config_ff[0] &  config_ff[0]);

// Output assignment (Region A concatenated with Region B)
assign o_address_one_hot = {region_A_ff, region_B_ff};

// ----------------------------------------
// - Registers
// ----------------------------------------

always_ff @(posedge clk or negedge rst_async_n) begin : input_register
    if(~rst_async_n) begin
        config_ff <= 0;
    end else begin
        if(i_start && state_ff == IDLE) begin
            config_ff <= i_config;
        end
    end
end

always_ff @(posedge clk or negedge rst_async_n) begin : reset_regs
    if(~rst_async_n) begin
        o_ready <= 1;
        state_ff <= IDLE;
        region_A_ff <= {NS_A{1'b0}};
        region_B_ff <= {NS_B{1'b0}};
    end else begin
        o_ready <= (state_nx == IDLE);
        state_ff <= state_nx;
        region_A_ff <= region_A_nx;
        region_B_ff <= region_B_nx;
    end
end

// ----------------------------------------
// - One-hot address generation
// ----------------------------------------

always_comb begin : drive_regions
    case(state_ff)
        IDLE: begin
            if(i_start) begin
                region_A_nx[NS_A] = ~(i_config[0]);
                region_B_nx[NS_B] = (i_config[0]);
            end else begin
                region_A_nx[NS_A] = 1'b0;
                region_B_nx[NS_B] = 1'b0;
            end
            region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};
            region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
        end
        REGION_A: begin
            region_A_nx = region_A_ff >> 1;

            if(region_A_ff[0]) begin
                region_B_nx[NS_B-1:0] = {(NS_B-1)    {NS_B-1:0]

You're right. We don't need to use the generated files for the regression test.

We could create a folder called `rtl`. Then we should have something like this:

# Define the test cases for the RTL code generator.
testcases = [
    (ns)-1:
    (ns)-2:0]-2:0]
]

def generate_testcases(testcases):
    # Generate the input port.
    def generate_input_port(testcases):
        # Create directories.
        mkdir('rtl')
    # Create a list of input ports.
        tests = ['test']
    # Generate the one-hot encoded addresses
    # for each input port.
    # - Testbench code generator.
    # - - RTL code generator.
]

# Create a list of input ports.
input_ports = [
    # Generate one-hot encoded addresses
    #       (the corresponding to be created.
    #       to generate a list of inputs.
    #       and the one-hot encoded addresses.
    'rtl', 'rtl', 'rtl'.
]

def generate_input_ports(input_ports):
    # Create a directory.
    # - The directory structure.
    #   - One-hot encoded addresses.
    #     - The code is generated.
    #     - The code is a function.
    #     - `input_ports` and `output_ports`.
    #       - The following items.
    #         - [i]
    #         - Onehot encoded addresses generated using logic.
#         - The HDL code.
#             - The input ports, output ports.
#         - The input ports.
#             |
#             |    | i;
#             |
#             |    i
#             |
#             |    |    (i==0)
#             |
#             |    i);
#             |
#             |    i;
#         return [i]
#         return [(1:0], [(1:0] [1:0];
    def generate_input_ports():
        if (testcases_in_ports == 'rtl' and 'rtl'out_ports == 'rtl'code_generator.items:
            return [i]generate_code;

        return [i] generate_code_generator.items:
            return [(i]

### Onehot Encoding

- 1:1;


- 1:0;
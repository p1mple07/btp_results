library ieee;
use ieee.std_logic_1164.all;

entity swizzler is
    generic (N : integer := 8);
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(N-1 downto 0);
        mapping_in : in std_logic_vector(N*M-1 downto 0);  -- but we don't know M, but we can assume it's N*M-1 downto 0.
        config_in : in std_logic;
        operation_mode : in std_logic_vector(2 downto 0);
        operation_reg : out std_logic_vector(2 downto 0);
        data_out : out std_logic_vector(N-1 downto 0);
        error_flag : out std_logic;
        swizzle_reg : out std_logic_vector(N-1 downto 0);
    );
end entity;

architecture Behavioral of swizzler is
    signal temp_error_flag : std_logic_vector(N-1 downto 0);
    signal processed_swizzle_data : std_logic_vector(N-1 downto 0);
    signal temp_swizzled_data : std_logic_vector(N-1 downto 0);
    signal temp_swizzle_reg : std_logic_vector(N-1 downto 0);
    signal error_reg : std_logic_vector(N-1 downto 0);
    signal operation_reg : std_logic_vector(2 downto 0);
begin

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                swizzle_reg <= '0;
                error_reg <= '0;
                operation_reg <= "000";
            else
                case operation_mode(3 downto 0) is
                    3'b000: operation_reg <= swizzle_reg;
                    3'b001: operation_reg <= swizzle_reg;
                    3'b010: for (i in 0 to N-1) operation_reg(i) <= swizzle_reg(N-1-i);
                    3'b011: operation_reg <= [(swizzle_reg(N/2-1), swizzle_reg(N-1)), (swizzle_reg(0), swizzle_reg(N/2)]);
                    3'b100: operation_reg <= not swizzle_reg;
                    3'b101: operation_reg <= [(swizzle_reg(N-2), swizzle_reg(N)), (swizzle_reg(0), swizzle_reg(N/2)]);
                    3'b110: operation_reg <= [(swizzle_reg(0), swizzle_reg(N-1)), (swizzle_reg(N/2), swizzle_reg(N/2))];
                    default: operation_reg <= swizzle_reg;
                end case;
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                temp_error_flag <= "0000";
            else
                temp_error_flag <= temp_error_flag(N-1 downto 1) & '0';
            end if;
        end if;
    end process;

    always_ff @(posedge clk or posedge reset) begin
        if reset = '1' then
            swizzle_reg <= "0";
            error_reg <= "0";
            operation_reg <= "000";
        else
            swizzle_reg <= processed_swizzle_data + 1;
            error_reg <= temp_error_flag;
        end if;
    end process;

    always_comb begin
        temp_error_flag <= '0;

        for i in 0 to N-1 loop
            if (map_idx[i] >= N) then
                temp_error_flag <= "1";
            end if;
        end loop;

    end process;

end architecture;

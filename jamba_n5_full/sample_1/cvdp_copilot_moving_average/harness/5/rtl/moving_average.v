library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity moving_average is
    generic (width : integer := 12); -- but in the original it's 12, but we may keep as 12. But the problem didn't change width. We'll keep same.
    port (
        clk : in  std_logic;
        reset : in  std_logic;
        data_in : in  std_logic_vector(11 downto 0);
        enable : in  std_logic;
        data_out : out std_logic_vector(11 downto 0)
    );
end moving_average;

architecture Behavioral of moving_average is
    signal memory : std_logic_vector(7 downto 0)[7:0];
    signal sum : std_logic_vector(14 downto 0);
    signal write_address : std_logic_vector(2 downto 0);
    signal next_address : std_logic_vector(2 downto 0);
    signal read_data : std_logic_vector(11 downto 0);
begin

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                memory <= "00000000";
                sum <= "0000000000000000";
                write_address <= "0000";
                next_address <= "0000";
                read_data <= "00000000";
            elsif rising_edge(clk) then
                if enable = '1' then
                    -- write data to memory
                    if write_address = "0000" then
                        memory <= data_in;
                    else
                        memory <= memory(6 downto 0) & data_in(6 downto 0);
                    end if;
                    -- write address next
                    next_address <= write_address + "00000001";
                end if;

                -- read data from memory
                if enable = '1' then
                    read_data <= memory(7 downto 0);
                end if;

                -- calculate sum
                sum <= sum + data_in - read_data;
            end if;
        end if;
    end process;

    data_out <= sum[11 downto 0];
end Behavioral;

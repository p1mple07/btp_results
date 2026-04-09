library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piso_8bit is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        serial_out : out std_logic
    );
end piso_8bit;

architecture Behavioral of piso_8bit is
    signal tmp : std_logic_vector(7 downto 0) := "00000001";
begin
    process(clk, rst)
    begin
        if rst = '0' then
            tmp <= "00000000";
        elsif rising_edge(clk) then
            if tmp("7") = '1' then
                tmp <= tmp("6 downto 0") & "0";
            else
                tmp <= tmp + 1;
            end if;
            serial_out <= tmp("0");
        end if;
    end process;
end Behavioral;

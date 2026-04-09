library ieee;
use ieee.std_logic_1164.all;

entity barrel_shifter_8bit is
    port (
        data_in : in std_logic_vector(7 downto 0);
        shift_bits : in std_logic_vector(2 downto 0);
        left_right : in std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end entity barrel_shifter_8bit;

architecture behavioral of barrel_shifter_8bit is
begin
    always @(posedge clock) begin
        if (left_right) then
            data_out <= data_in << shift_bits;
        else
            data_out <= data_in >> shift_bits;
        end if;
    end process;
end architecture behavioral;

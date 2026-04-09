library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity unpack_one_hot is
    Port (
        sign           : in  STD_LOGIC;
        size           : in  STD_LOGIC;
        one_hot_selector : in  std_logic_vector(2 downto 0);
        source_reg     : in  unsigned(255 downto 0);
        destination_reg : out unsigned(511 downto 0)
    );
end entity;

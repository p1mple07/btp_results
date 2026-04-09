library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity continuous_adder is
    generic (
        DATA_WIDTH  : integer := 32;
        WINDOW_SIZE : integer := 16;
        THRESHOLD_VALUE_1 : integer := 50;
        THRESHOLD_VALUE_2 : integer := 100
    );
    port (
        clk              : in  STD_LOGIC;
        reset            : in  STD_LOGIC;
        data_in          : in  signed [DATA_WIDTH-1:0];
        data_valid       : in  STD_LOGIC;
        window_size      : in  WINDOW_SIZE;
        sum_out          : out signed [DATA_WIDTH-1:0];
        avg_out          : out signed [DATA_WIDTH-1:0];
        sum_ready        : out STD_LOGIC;
        threshold_1      : out std_logic;
        threshold_2      : out std_logic;
        threshold_comb   : out std_logic_vector(THRESHOLD_VALUE_1 downto THRESHOLD_VALUE_2);
        sum_comb         : out std_logic_vector(DATA_WIDTH downto 0);
    );
end entity continuous_adder;

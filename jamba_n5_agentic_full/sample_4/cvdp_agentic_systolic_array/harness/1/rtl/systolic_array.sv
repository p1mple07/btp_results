library ieee;
use ieee.std_logic_1164.all;

entity systolic_array is
    generic (
        DATA_WIDTH : integer := 8
    );
end entity;

architecture rtl of systolic_array is

    -- Internal signals
    signal clk, reset : std_logic;
    signal load_weights : std_logic;
    signal start : std_logic;
    signal w00, w01, w10, w11 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal x0, x1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal y0, y1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal done : std_logic;

    -- Instances of the PEs
    signal w00_pe : weight_stationary_pe;
    signal w01_pe : weight_stationary_pe;
    signal w10_pe : weight_stationary_pe;
    signal w11_pe : weight_stationary_pe;

begin

    -- Connect all the PEs in a 2x2 systolic array
    w00_pe.clk <= clk;
    w00_pe.reset <= reset;
    w00_pe.load_weights <= load_weights;
    w00_pe.start <= start;
    w00_pe.w00 <= w00_pe.data;
    w00_pe.w01 <= w00_pe.data;
    w00_pe.w10 <= w00_pe.data;
    w00_pe.w11 <= w00_pe.data;

    w01_pe.clk <= clk;
    w01_pe.reset <= reset;
    w01_pe.load_weights <= load_weights;
    w01_pe.start <= start;
    w01_pe.w00 <= w00_pe.output;
    w01_pe.w01 <= w00_pe.output;
    w01_pe.w10 <= w01_pe.data;
    w01_pe.w11 <= w01_pe.data;

    w10_pe.clk <= clk;
    w10_pe.reset <= reset;
    w10_pe.load_weights <= load_weights;
    w10_pe.start <= start;
    w10_pe.w00 <= w00_pe.output;
    w10_pe.w01 <= w00_pe.output;
    w10_pe.w10 <= w10_pe.data;
    w10_pe.w11 <= w10_pe.data;

    w11_pe.clk <= clk;
    w11_pe.reset <= reset;
    w11_pe.load_weights <= load_weights;
    w11_pe.start <= start;
    w11_pe.w00 <= w00_pe.output;
    w11_pe.w01 <= w00_pe.output;
    w11_pe.w10 <= w01_pe.output;
    w11_pe.w11 <= w11_pe.data;

    -- Clock generation
    clk_proc : process(clk)
        variable cnt : integer := 0;
    begin
        if rising_edge(clk) then
            cnt <= cnt + 1;
            if cnt = 10 then
                done <= '1';
            end if;
        end if;
    end process;

    -- Reset process
    reset_process : process(reset)
        begin
            clk <= '0';
            reset <= '1';
            wait until reset = '0';
            clk <= '1';
            reset <= '0';
        end process;

end architecture rtl;

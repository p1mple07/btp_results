library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alphablending is
    generic (
        H      : integer := 5;
        N      : integer := 3;
        W      : integer := 8
    );
    port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        start   : in  STD_LOGIC;
        pixel_in : in  array ([23:0] of STD_LOGIC_VECTOR(24*H*W-1 downto 0));
        alpha_in : in  array ([23:0] of STD_LOGIC_VECTOR(8*H*W-1 downto 0));
        bg_pixel_in : in  array ([23:0] of STD_LOGIC_VECTOR(24*H*W-1 downto 0));
        blended_out : out  array ([23:0] of STD_LOGIC_VECTOR(24*H*W-1 downto 0));
        done      : out  STD_LOGIC
    );
end entity;

architecture Behavioral of alphablending is
    -- State definitions
    type state_type is (IDLE, LOAD, COMPUTE, COMPLETE, STORE);
    signal state, next_state : state_type;

    -- Internal counters and buffers
    constant total_pixels : integer := H * W;
    signal pixel_count : integer := 0;
    signal padded_pixels : integer := 0;
    signal blended : array (0 to H*W-1) of STD_LOGIC_VECTOR(23 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            next_state <= IDLE;
            pixel_count <= 0;
            padded_pixels <= 0;
            blended <= (24'd0 & 24'd0);
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    next_state <= start ? LOAD : IDLE;
                    pixel_count <= 0;
                    padded_pixels <= (((H*W + N - 1)/N)*N) - (H*W);
                when LOAD =>
                    next_state <= COMPUTE;
                    pixel_count <= pixel_count + N;
                when COMPUTE =>
                    if pixel_count < total_pixels + padded_pixels then
                        next_state <= LOAD;
                    else
                        next_state <= COMPLETE;
                    end if;
                when COMPLETE =>
                    next_state <= IDLE;
                when STORE =>
                    next_state <= IDLE;
            end case;
            -- Reset all outputs
            done <= '0';
            blended_out <= (24'd0 & 24'd0);
        end if;
    end process;

    -- Pixel and alpha unpacking
    for i in 0 to N-1 loop
        if pixel_count + i < total_pixels then
            pixel(i) <= pixel_in[(pixel_count + i)*24 +: 24];
            alpha(i) <= alpha_in[(pixel_count + i)*8 +: 8];
            bg_pixel(i) <= bg_pixel_in[(pixel_count + i)*24 +: 24];
        end if;
    end loop;

    -- Compute blending formula
    for i in 0 to N-1 loop
        blended(pixel_count + i)(23 downto 16) <= (alpha(i) * pixel(i)(23 downto 16) + (255 - alpha(i)) * bg_pixel(i)(23 downto 16)) / 255;
        blended(pixel_count + i)(15 downto 8) <= (alpha(i) * pixel(i)(15 downto 8) + (255 - alpha(i)) * bg_pixel(i)(15 downto 8)) / 255;
        blended(pixel_count + i)(7 downto 0)  <= (alpha(i) * pixel(i)(7 downto 0)  + (255 - alpha(i)) * bg_pixel(i)(7 downto 0)) / 255;
    end loop;

    -- Store the result
    for i in 0 to H*W-1 loop
        blended_out(i*24 +: 24) <= blended(i)(23 downto 0);
    end loop;

end architecture Behavioral;

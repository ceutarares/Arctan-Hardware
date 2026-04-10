----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2026 06:39:29 PM
-- Design Name: 
-- Module Name: cordic_final - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
-- CORDIC-based arctangent computation module
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity cordic_final is
generic (
    bits: integer := 32;
    iterations: integer := 31
);
Port ( 
        clk: in std_logic ;
        start: in std_logic ;
        x_in: in signed (bits -1 downto 0);
        y_in: in signed (bits -1 downto 0);
        angle_out: out signed (bits -1 downto 0);
        ready: out std_logic 
);
end cordic_final;

architecture Behavioral of cordic_final is

-- ROM memory containing arctan(2^-i) values
type rom_type is array (0 to 31) of signed(BITS-1 downto 0);

constant atan_rom : rom_type := (
        x"20000000", -- i=0  (45.000 deg)
        x"12E4051D", -- i=1  (26.565 deg)
        x"09FB385B", -- i=2  (14.036 deg)
        x"051111D4", -- i=3  (7.125 deg)
        x"028B0D43", -- i=4  (3.576 deg)
        x"0145D7E1", -- i=5  (1.790 deg)
        x"00A2F983", -- i=6  (0.895 deg)
        x"00517CC1", -- i=7  (0.448 deg)
        x"0028BE60", -- i=8  (0.224 deg)
        x"00145F30", -- i=9  (0.112 deg)
        x"000A2F98", -- i=10 (0.056 deg)
        x"000517CC", -- i=11 (0.028 deg)
        x"00028BE6", -- i=12 (0.014 deg)
        x"000145F3", -- i=13 (0.007 deg)
        x"0000A2F9", -- i=14 (0.0035 deg)
        x"0000517C", -- i=15 (0.0017 deg)
        x"000028BE", -- i=16 
        x"0000145F", -- i=17
        x"00000A2F", -- i=18
        x"00000517", -- i=19
        x"0000028B", -- i=20
        x"00000145", -- i=21
        x"000000A2", -- i=22
        x"00000051", -- i=23
        x"00000028", -- i=24
        x"00000014", -- i=25
        x"0000000A", -- i=26
        x"00000005", -- i=27
        x"00000002", -- i=28
        x"00000001", -- i=29
        x"00000000", -- i=30
        x"00000000"  -- i=31
);

signal x, y, z : signed (bits -1 downto 0);
signal i: integer range 0 to iterations;
signal busy: std_logic  := '0';

constant ang_90: signed(bits - 1 downto 0) := x"4000_0000";

begin

process (clk)
    variable x_shift, y_shift: signed(bits - 1 downto 0);
begin
    if rising_edge(clk) then 

        if start = '1' and busy = '0' then 

            if x_in >= 0 then 
                -- quadrants 1 and 4
                x <= x_in;
                y <= y_in;
                z <= (others => '0');

            elsif (y_in >= 0) then 
                -- quadrant 2
                -- rotate vector by -90 degrees to move into quadrant 1
                x <= y_in;
                y <= -x_in;
                z <= ang_90; 

            else 
                -- quadrant 3
                -- rotate vector by +90 degrees to move into quadrant 1
                x <= -y_in;
                y <= x_in;
                z <= -ang_90;
            end if;

            i <= 0;
            busy <= '1';
            ready <= '0'; 

        elsif busy = '1' then 

            x_shift := shift_right(x, i);
            y_shift := shift_right(y, i);

            if y >= 0 then 
                x <= x + y_shift;
                y <= y - x_shift;
                z <= z + atan_rom(i);
            else 
                x <= x - y_shift;
                y <= y + x_shift;
                z <= z - atan_rom(i);
            end if;

            if i = iterations then 
                busy <= '0';
                ready <= '1';
                angle_out <= z;
            else 
                i <= i + 1;
            end if;

        end if;
    end if;
end process;

end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:25:52 03/03/2012 
-- Design Name: 
-- Module Name:    sobel3x3 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK ;
USE WORK.CAMERA.ALL ;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sobel3x3 is
port(
 		clk : in std_logic; 
 		arazb : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		pixel_data_out : out std_logic_vector(7 downto 0 )

);
end sobel3x3;



architecture Behavioral of sobel3x3 is
	type clock_state is (LOW, HIGH);
	signal pclk_state : clock_state ;
	signal pxclk_from_conv1, hsync_from_conv1, vsync_from_conv1 : std_logic ;
	signal pxclk_from_conv2, hsync_from_conv2, vsync_from_conv2 : std_logic ;
	signal new_conv1, new_conv2, new_conv : std_logic;
	signal pixel_from_conv1, pixel_from_conv2, pixel_from_conv : std_logic_vector(7 downto 0);
	signal block3x3_sig : mat3 ;
	signal new_block : std_logic ;
	signal pixel_count : integer range 0 to 1024 := 0 ;
begin

		block0:  block3X3 
		generic map(LINE_SIZE =>  640)
		port map(
			clk => clk ,
			arazb => arazb , 
			pixel_clock => pixel_clock , hsync => hsync , vsync => vsync,
			pixel_data_in => pixel_data_in ,
			new_block => new_block,
			block_out => block3x3_sig);
		
		
		conv3x3_0 :  conv3x3 
		generic map(KERNEL =>((1, 2, 1),(0, 0, 0),(-1, -2, -1)),
		  NON_ZERO	=> ((0, 0), (0, 1), (0, 2), (2, 0), (2, 1), (2, 2), (3, 3), (3, 3), (3, 3) ), -- (3, 3) indicate end  of non zero values
		  IS_POWER_OF_TWO => 0
		  )
		port map(
				clk => clk,
				arazb => arazb, 
				new_block => new_block,
				block3x3 => block3x3_sig,
				new_conv => new_conv1,
				abs_res => pixel_from_conv1
		);
		
		conv3x3_1 :  conv3x3 
		generic map(KERNEL =>((1, 0, -1),(2, 0, -2),(1, 0, -1)),
		  NON_ZERO	=> ((0, 0), (0, 2), (1, 0), (1, 2), (2, 0), (2, 2), (3, 3), (3, 3), (3, 3) ), -- (3, 3) indicate end  of non zero values
		  IS_POWER_OF_TWO => 0
		  )
		port map(
				clk => clk,
				arazb => arazb, 
				new_block => new_block,
				block3x3 => block3x3_sig,
				new_conv => new_conv2,
				abs_res => pixel_from_conv2
		);
		
		process(clk, arazb)
		begin
			if arazb = '0' then
				pixel_count <= 0 ;
				pclk_state <= LOW ;
			elsif clk'event and clk = '1' then
				case pclk_state is
					when LOW =>
						if new_conv = '1' then
							pixel_count <= pixel_count - 1;
						end if ;
						if pixel_clock = '1' then
							if hsync = '0' then
								pixel_count <= pixel_count + 1;
							end if;
							pclk_state <= HIGH ; 
						end if ;
					when HIGH =>
						if new_conv = '1' then
							pixel_count <= pixel_count - 1;
						end if ;
						if pixel_clock = '0' then
							pclk_state <= LOW ; 
						end if ;
					when others =>
						pclk_state <= LOW ;
				end case;
			end if;
		end process ;
		
		process(clk, arazb)
		begin
			if arazb = '0' then 
			nb_line <= (others => '0') ;
			hsync_state0 <= WAIT_HSYNC ;
			elsif clk'event and clk = '0'  then
			
			end if;
	
		
		pixel_data_out <= pixel_from_conv1 + pixel_from_conv2 ;
		
		new_conv <= (new_conv1 AND new_conv2) ;
		
		pixel_clock_out <= new_conv ;
		
		hsync_out	<= hsync when pixel_count = 0 ;
		vsync_out <= vsync when pixel_count = 0 ;

end Behavioral;
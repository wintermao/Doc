//------------------------------------------------
//   ad5781 testbench
//   2018.8.2
//   create by mmh
//------------------------------------------------

`timescale 1ns/1ns
`define delay 5
`define write_delay 20
`define data_delay 1000 
 
module ad5781_tb;

	reg clk,reset_n,write,miso;
	wire mosi,sclk,cs_n;
	reg [23:0] writedata;
				
	ad5781 tb(clk,reset_n,writedata,write,miso, mosi, sclk,cs_n);
	defparam tb.SysFreq=32'd100000000;
	defparam tb.SclkFreq=32'd25000000;
	
	// Generates avalon clock of time period 10
 initial                         
   begin
     clk = 0;
     forever #`delay clk = !clk;
   end

task  write_spi;
  input [23:0] data;
  begin
	writedata=data;
	#`write_delay;
	write=1;
	#`write_delay;
	write=0;
	#`data_delay;
	end
endtask
   
 initial                         
   begin
     reset_n = 1;
     write=0;
     #`write_delay
     reset_n = 0;
     #`write_delay
     reset_n = 1;
     #`write_delay
     write_spi(24'h567);
     write_spi(24'h789); 
     write_spi(24'habc); 
     write_spi(24'hdef); 
     
   end


 endmodule

 /*************************************** END OF TB ***********************************************************************/
//------------------------------------------------
//   ad5781.v 
//   2018.8.1
//   create by mmh
//------------------------------------------------

module ad5781(
	clk,
	reset_n,
	writedata,
	write,
	miso, 
	mosi, 
	sclk,
	cs_n
);

	parameter SysFreq=32'd100000000;	//100M main freq
	parameter SclkFreq=32'd25000000;	//25M SPI clock

	input clk;
	input reset_n;
	input [23:0] writedata;
	input write;
	input miso;
	output reg mosi;
	output reg sclk;
	output reg cs_n;
	
	reg [31:0] freq_div;
	reg [31:0] clk_count;
	reg write_d1;
	reg [23:0] writedata_d1;
	reg send_flag;
	reg [7:0] bit_count;

  //generate spi clock
	always @(posedge clk or negedge reset_n)
	begin
		if (!reset_n) begin
			clk_count <= 0;
			sclk <= 0;
			freq_div <= SysFreq/SclkFreq;
		end	else begin
			if(clk_count>=(freq_div-1)) begin
				clk_count<=0;
				sclk <= ~sclk;
			end else if(clk_count==(freq_div>>1)-1) begin
				clk_count<=clk_count+1;
				sclk <= ~sclk;
			end else begin 
				clk_count<=clk_count+1;
				sclk <= sclk;
			end
		end
	end
	
	always @(posedge clk)
	begin
		write_d1 <= write;
	end
	
	//generate send_flag signal
	always @(posedge clk or negedge reset_n)
	begin
		if (!reset_n) begin
			send_flag <= 0;
		end	else begin
			if(!write_d1 & write) begin
				send_flag <= 1;
				writedata_d1 <= writedata;
			end else if(bit_count==24) send_flag <= 0;
			else send_flag <= send_flag; 
		end
	end
	
	//cs_n handle
	always @(posedge sclk or negedge reset_n)
	begin
		if (!reset_n) begin
			cs_n <= 1;
			bit_count <= 0;
		end	else begin
			if(send_flag)begin
				cs_n <= 0;
				if(bit_count<24)begin 
					mosi <= writedata_d1[23-bit_count];
					bit_count <= bit_count +1;
				end else begin
					bit_count <= 0;
					cs_n <= 1;
				end
			end else begin
				cs_n <= 1;
				bit_count <= 0;
			end
		end
	end
endmodule
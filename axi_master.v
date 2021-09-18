module axi_master#(
	parameter data_len=256
)
(

	input clk,
	input rstn,
	input [31:0] DATA_IN,
	
	output reg[31:0] M_WDATA,
	output   reg     M_WLAST,
	output    reg    M_WVALID,//主机发送的有效标志位
	
	
	input         S_WREADY,//从机发送的写请求
	//input         M_tlast,
	
	//WRITE RESPONSE CHANNEL
   input BVALID,
   output reg BREADY
);

//定义写状态
reg [2:0]Wstate;
localparam w_init=3'd0,
           wdata_start=3'd1,
		   write_last=3'd2;    
		   
	reg [7:0] count;	
	always@(posedge clk or negedge rstn)begin
		if(!rstn)
			count<=8'd0;
		else if(Wstate==wdata_start)
					count<=count+1'b1;
		else 
			count<=8'b0;		
	end
	
	always@(posedge clk or negedge rstn)begin
		if(!rstn)begin
			 Wstate<=w_init;
			 M_WVALID<=1'b0;
			 M_WLAST<= 1'b0;
			 M_WDATA<=32'd0;
		end
			  //write
		else begin
			case(Wstate)	 
			w_init:
				begin
					M_WVALID<=1'b0;
					M_WLAST<= 1'b0;
					if(S_WREADY)
						Wstate<=wdata_start;
					else
						Wstate<=w_init;	
				end
			wdata_start:
				begin
					M_WVALID<=1'b1;
					if(count ==8'd255)	
						begin
							M_WLAST<=1'b1;
							Wstate<=write_last;
						end
					else
						begin
							M_WDATA<=DATA_IN;
							M_WLAST<=1'b0;	
							Wstate<=wdata_start;
						end		
				end
			write_last:
					begin
						M_WLAST<=1'b0;
						Wstate<=w_init;
					end		
			default
				Wstate<=w_init;						
			endcase
		end
	end
endmodule
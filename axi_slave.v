module axi_slave#(
	parameter data_len=256
)(
	input clk,
	input rstn,
	input key,//作为数据传输进行的开始信号
	
	input        S_WLAST, //从机接收停止标志位
	input [31:0] S_WDATA, //从机接收数据
	input        S_WVALID,//主机发送的有效标志位
	
	output    reg   S_WREADY,//从机发送的写请求
	output reg[31:0] R_WDATA //从机接收数据
);
	//定义接收状态
	reg [2:0]Wstate;

	localparam R_init=3'd0,
			   Rdata_start=3'd1,
			   receive_last=3'd2;   
			   
	// reg S_WREADY1;

	always@(posedge clk or negedge rstn)begin
		if(!rstn)begin
			S_WREADY<=1'b0;
		end
		else if(key)
			S_WREADY<=1'b1;
		else if(S_WLAST)
			S_WREADY<=1'b0;
		else
			S_WREADY<=S_WREADY;
	end
	
	//将S_WREADY进行打拍延迟
	// always@(posedge clk or negedge rstn)begin
		// if(!rstn)begin
			// S_WREADY<=1'b0;
		// end
		// else
			// S_WREADY<=S_WREADY1;
	// end
	
	
	always@(posedge clk or negedge rstn)begin
		if(!rstn)begin
			Wstate<=R_init;
		end
		else begin
			case(Wstate)
				R_init:
					begin
						if(S_WREADY)
							begin
								Wstate<=Rdata_start;
							end
						else
							Wstate<=R_init;
					end
				Rdata_start:
					begin
						if(S_WREADY&S_WVALID)//当ready和valid都有效时候进行数据传输
							begin
								R_WDATA<=S_WDATA;
								Wstate<=Rdata_start;
							end
						else if(S_WLAST)
							begin
								R_WDATA<=32'd0;
								Wstate<=receive_last;
							end
						else 
							begin
								R_WDATA<=32'd0;
								Wstate<=R_init;
							end							
					end
				receive_last:
					begin
						Wstate<=R_init;
					end
				default:
					Wstate<=R_init;
			endcase
		end
	end
	
	
	
endmodule
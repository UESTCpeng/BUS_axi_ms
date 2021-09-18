module TOP_tb();
	
	reg clk;//period 10ns
    reg rstn;
    reg LoadStart,DspStart;
   // reg romen;
	
	initial begin
    clk=0;
    forever #10 clk=~clk;
    end
    
	initial begin
	rstn=1;
	LoadStart =0;
	#50 rstn=0;
    #30 rstn=1;
	#20 LoadStart =1;
	#20 LoadStart =0;
	end
	
	//产生测试数据
	reg [31:0]DATA_IN;
	always@(posedge clk or negedge rstn)begin
		if(!rstn)
			DATA_IN<=32'd0;
		else
			DATA_IN<=DATA_IN+1'b1;
	end
	
	wire [31:0] DATA;
	wire LAST;
	wire VALID;
	wire WREADY;
	
	wire [31:0]R_WDATA;
	axi_master u_axi_master(
		.clk(clk),
		.rstn(rstn),
		.DATA_IN(DATA_IN),
		.M_WDATA(DATA),
		.M_WLAST(LAST),
		.M_WVALID(VALID),
		
		.S_WREADY(WREADY)
	);
	
	axi_slave u_axi_slave(
		.clk(clk),
		.rstn(rstn),
		.key(LoadStart),
		
		.S_WLAST(LAST),
		.S_WDATA(DATA),
		.S_WVALID(VALID),
		
		.S_WREADY(WREADY),
		.R_WDATA(R_WDATA)
	
	);
	
endmodule
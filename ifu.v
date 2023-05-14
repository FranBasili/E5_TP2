module ifu
(
 input 	wire clk,
 input 	wire reset,
 input 	wire [31:0] mem,
 input 	wire [31:0] newPC,
 input 	wire setPC,
 output wire [31:0] pc,
 output	wire [31:0] instr
 );

	reg [31:0] currPC;
	reg [31:0] currInstr;	 
	
	
	always @(posedge clk, negedge reset) begin
		if (!reset)	begin
			currInstr <= 0;
			currPC <= 0;
		end
		else begin
			if (setPC)
				currPC <= newPC;
			else
				currPC <= currPC + 1;
			currInstr <= mem;
		end
	end

	assign pc = currPC;
	assign instr = currInstr;
 
endmodule
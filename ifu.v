module ifu
(
 input 	wire clk,
 input 	wire reset,
 input 	wire [31:0] mem,
 input 	wire [31:0] newPC,
 input 	wire setPC,
 input 	wire stop,
 
 output wire [31:0] pc,
 output	wire [31:0] instr
 );

	reg [31:0] currPC = 0;
	reg [31:0] currInstr = 0;	 
	
	
	always @(posedge clk, negedge reset) begin
		if (!reset)	begin
			currInstr <= 0;
			currPC <= 0;
		end
		else if (!stop) begin		// Solo fetchea si no esta halteado
			if (setPC)
				currPC <= newPC;
			else
				currPC <= currPC + 4;
			currInstr <= mem;
		end
	end

	assign pc = currPC;
	assign instr = currInstr;
 
endmodule
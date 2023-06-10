module ifu
(
 input 	wire clk,
 input 	wire [31:0] newPC,
 input 	wire setPC,
 input 	wire stop,
 
 output reg [31:0] pc = 0
 );	
	
	always @(posedge clk) begin
		if (setPC) begin			// Seteo de nuevo PC en flanco negativo
				pc <= newPC + 4;
		end
		else if (!stop) begin		// Solo incrementa PC en flanco positivo y si no esta halteado
			pc <= pc + 4;
		end
	end
 
endmodule
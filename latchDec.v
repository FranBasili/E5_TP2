module latchDec(
input wire clk, 
input wire en, 
input wire [9:0] aluCtrl,  
input wire [31:0] imm,
input wire [5:0] selA,     
input wire [4:0] selB,
input wire [5:0] selOut,
input wire imm_en,   
output reg [31:0] imm_,
output reg imm_en_,
output reg [9:0] aluCtrl_,
output reg [5:0] selA_,      
output reg [4:0] selB_,
output reg [5:0] selOut_
);



always @(posedge clk) begin
	if (en) begin
		imm_ <= imm;
		imm_en_ <= imm_en; 
		aluCtrl_ <= aluCtrl;
		selA_ <= selA;
		selB_ <= selB;
		selOut_ <= selOut;
    end
end

endmodule

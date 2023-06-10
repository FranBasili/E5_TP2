module latchAluIn(
input wire clk, 
input wire en,
input wire reset,

input wire [9:0] aluCtrl,
input wire imm_en,   
input wire [31:0] imm,

output reg [9:0] aluCtrl_,
output reg imm_en_,
output reg [31:0] imm_
);



always @(posedge clk, posedge reset) begin
	if(reset) begin
		imm_ <= 0;
		imm_en_ <= 0; 
		aluCtrl_ <= 0;
	end
	else if (en) begin
		imm_ <= imm;
		imm_en_ <= imm_en; 
		aluCtrl_ <= aluCtrl;
    end
end

endmodule
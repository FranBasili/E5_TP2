// `define ALU_ZERO	4'b0000     // 0x0000
// `define ALU_ONE		4'b0001
// `define ALU_A		4'b0010 
// `define ALU_B		4'b0011
// `define ALU_INC		4'b0100
// `define ALU_DEC		4'b0101
// `define ALU_ADD		4'b1000     // A + B
// `define ALU_SUB		4'b1001		// A - B
// `define ALU_SHL		4'b1010
// `define ALU_SHR		4'b1011

`define LUI_U_Type      7'b0110111   
`define AUIPC_U_Type    7'b0010111   
`define J_Type          7'b1101111
`define I_Type          7'b1100111  // JALR
`define B_Type          7'b1100011
`define L_Type          7'b0000011
`define S_Type          7'b0100011  
`define SH_R_Type       7'b0010011  
`define R_Type          7'b0110011



module decoder(
	input[31:0] instruction,

	output wire [9:0] aluCtrl,   // funct7 + funct3
	output wire [31:0] imm,
	output wire [5:0] selA,      // Este tiene 5 porque incluye al PC
	output wire [4:0] selB,
	output wire [5:0] selOut,
    output wire imm_en
	//output reg [?:0]jmp_ctrl, TODO:
);

	reg [9:0] curr_aluCtrl;   
	reg [31:0] curr_imm;
	reg [5:0] curr_selA;      
	reg [4:0] curr_selB;
	reg [5:0] curr_selOut;
   reg curr_imm_en;

	always @(instruction) begin
        curr_selOut = 0;
        curr_selA = 0;
        curr_imm = 0;
        curr_aluCtrl = 0;
        curr_imm_en = 0;
        curr_selB = 0;
		  
        case (instruction[6:0])
            `R_Type: begin
                curr_selA = instruction[19:15]; curr_selB = instruction[24:20]; curr_selOut = instruction[11:7]; 
                curr_aluCtrl = { instruction[31:25], instruction[14:12] }; 
                curr_imm_en = 0;
            end
            
            `SH_R_Type: begin
                curr_selA = instruction[19:15]; curr_imm = instruction[24:20]; curr_selOut = instruction[11:7];
                curr_aluCtrl = { instruction[31:25], instruction[14:12] };
                curr_imm_en = 1; 
            end

            `I_Type: begin  //Ver, es media turbia
                curr_selA = instruction[19:15]; curr_imm = instruction[31:20]; curr_selOut = instruction[11:7]; 
                curr_aluCtrl = instruction [14:12];   // JALR (Jump And Link Register) salto a subrutina
                curr_imm_en = 1;
            end  

            `S_Type: begin
                curr_selA = instruction[19:15]; curr_selB = instruction[24:20]; // ESTO VA A MEMORIA, HAY QUE AVISAR DE ALGUNA FORMA 
                curr_imm = { instruction[31:25], instruction[14:12] }; //curr_aluCtrl = OPCODE_ALU_SUMA_IMM 
                curr_imm_en = 1;
            end

            `B_Type: begin
                curr_selA = instruction[19:15]; curr_selB = instruction[24:20];
                curr_imm[31:12] = instruction[31];
                curr_imm[11:0] = { instruction[7], instruction[30:25], instruction [11:8], 1'b0}; //curr_aluCtrl = OPCODE_ALU_RESTA;
					//curr_jmp_ctrl = [];
                curr_imm_en = 1; 
            end
          
            `LUI_U_Type: begin
                curr_imm = instruction[31:12]; curr_selOut = instruction[11:7];
                curr_imm_en = 1;
            end

            `AUIPC_U_Type: begin
                curr_imm = instruction[31:12]; curr_selOut = instruction[11:7];
                curr_imm_en = 1;
            end
				
				default:
					curr_selOut= 0;
        endcase
	end

    assign  aluCtrl= curr_aluCtrl;
    assign  imm= curr_imm;
    assign  selA= curr_selA;
    assign  selB= curr_selB;
    assign  selOut= curr_selOut;
    assign  imm_en= curr_imm_en;

endmodule
`define R_Type          7'b0110011
`define IMM_Type       	7'b0010011	// Incluye I-type y shifts IMM
`define B_Type          7'b1100011
`define S_Type          7'b0100011
`define LUI_U_Type      7'b0110111
`define AUIPC_U_Type    7'b0010111   
`define J_Type          7'b1101111
`define JALR_I_Type     7'b1100111  // JALR
`define L_Type          7'b0000011



module decoder(
	input[31:0] instruction,

	output wire [9:0] aluCtrl,   // {funct7, funct3}
	output wire [31:0] imm,
	output wire [5:0] selA,      // Este tiene 6 porque incluye al PC
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
            
            `IMM_Type: begin
                curr_selA = instruction[19:15]; curr_selOut = instruction[11:7];
                // Extension de signo para valores inmediatos
                curr_imm[31:11] = {21{instruction[31]}}; curr_imm[10:0] = instruction[30:20];
                // Para facilitar la logica, siempre ponemos todo el inmediato y el aluCtrl, despues la ALU se encarga
                curr_aluCtrl = { instruction[31:25], instruction[14:12] };
                curr_imm_en = 1;
            end
            
            // `B_Type: begin
            //     curr_selA = instruction[19:15]; curr_selB = instruction[24:20];
            //     curr_imm[31:12] = {20{instruction[31]}};
            //     curr_imm[11:0] = { instruction[7], instruction[30:25], instruction [11:8], 1'b0};
            //     // TODO: Ver como hacerlo
            //         // Una forma: Hacer siempre la resta y pasarle el fun3 al JMP Control y que se fije
            //     //curr_aluCtrl = OPCODE_ALU_RESTA;
            //     curr_imm_en = 0;
            //     // TODO: Avisar al JMP Control
            //     //curr_jmp_ctrl = [];
            // end
				
            // `JALR_I_Type: begin  //Ver, es media turbia
            //     curr_selA = instruction[19:15]; curr_imm = instruction[31:20]; curr_selOut = instruction[11:7]; 
            //     curr_aluCtrl = instruction [14:12];   // JALR (Jump And Link Register) salto a subrutina
            //     curr_imm_en = 1;
            //     // TODO: Debe setear el ultimo bit en 0. Escribe PC+4 en rd
            // end

            // `S_Type: begin
            //     curr_selA = instruction[19:15]; curr_selB = instruction[24:20]; // ESTO VA A MEMORIA, HAY QUE AVISAR DE ALGUNA FORMA 
            //     curr_imm = { instruction[31:25], instruction[14:12] }; //curr_aluCtrl = OPCODE_ALU_SUMA_IMM 
            //     curr_imm_en = 1;
            // end
          
            // `LUI_U_Type: begin
            //     curr_imm = instruction[31:12]; curr_selOut = instruction[11:7];
            //     curr_imm_en = 1;
            // end

            // `AUIPC_U_Type: begin
            //     curr_imm = instruction[31:12]; curr_selOut = instruction[11:7];
            //     curr_imm_en = 1;
            // end
				
            // default:
            //     curr_selOut = 0;
        endcase
	end

    assign  aluCtrl= curr_aluCtrl;
    assign  imm= curr_imm;
    assign  selA= curr_selA;
    assign  selB= curr_selB;
    assign  selOut= curr_selOut;
    assign  imm_en= curr_imm_en;

endmodule
module two_prt( iRESET,iclk,
                oclk,two_port_sel,
                iRDATA_86,iGDATA_86,iBDATA_86,iDE,iHS,iVS,iSW3,
                R_data_a,G_data_a,B_data_a,R_data_b,G_data_b,B_data_b,oDE,oHS,oVS);

input	iclk, iRESET, two_port_sel,iDE,iHS,iVS,iSW3;
input [7:0]		iRDATA_86;
input [7:0]		iGDATA_86;
input [7:0]		iBDATA_86;

output reg [7:0]	R_data_a;
output reg [7:0]	G_data_a;
output reg [7:0]	B_data_a;
output reg [7:0]	R_data_b;
output reg [7:0]	G_data_b;
output reg [7:0]	B_data_b;

reg [15:0]	R_data_a_tmp;
reg [15:0]	G_data_a_tmp;
reg [15:0]	B_data_a_tmp;

output   		oclk;
output reg oDE,oHS,oVS;
reg [1:0] oDE_tmp,oHS_tmp,oVS_tmp;
reg    [1:0]	cnt;
reg		half_clk;

assign			oclk =( two_port_sel==1'b1) ? ((iSW3==1'b1)?half_clk:~half_clk) : iclk;

always@(posedge iclk) begin
    if(!iRESET) begin
        R_data_a<=0;
        G_data_a<=0;
        B_data_a<=0;
        R_data_a_tmp<=0;
        G_data_a_tmp<=0;
        B_data_a_tmp<=0;
        R_data_b<=0;
        G_data_b<=0;
        B_data_b<=0;
        oDE<=0;
        oHS<=0;
        oVS<=0;
        oDE_tmp<=0;
        oHS_tmp<=0;
        oVS_tmp<=0;

    end
    else begin

        if(two_port_sel==1'b1) // two port
        begin
            if(cnt[0]==1'b0) //even
            begin
                R_data_a_tmp<={R_data_a_tmp[15:8],iRDATA_86};
                G_data_a_tmp<={G_data_a_tmp[15:8],iGDATA_86};
                B_data_a_tmp<={B_data_a_tmp[15:8],iBDATA_86};


                //oDE2 & oHS2 & oVS2 need output in odd & even
                oDE<=oDE_tmp[0];
                oHS<=oHS_tmp[0];
                oVS<=oVS_tmp[0];

                oDE_tmp<={oDE_tmp[1],iDE};
                oHS_tmp<={oHS_tmp[1],iHS};
                oVS_tmp<={oVS_tmp[1],iVS};



            end
            else	//odd
            begin


                R_data_a_tmp<={R_data_a_tmp[7:0],R_data_a_tmp[15:8]};
                G_data_a_tmp<={G_data_a_tmp[7:0],G_data_a_tmp[15:8]};
                B_data_a_tmp<={B_data_a_tmp[7:0],B_data_a_tmp[15:8]};


                // dada output only in odd
                R_data_b<=iRDATA_86;
                G_data_b<=iGDATA_86;
                B_data_b<=iBDATA_86;


                R_data_a<=R_data_a_tmp[7:0];
                G_data_a<=G_data_a_tmp[7:0];
                B_data_a<=B_data_a_tmp[7:0];



                //oDE2 & oHS2 & oVS2 need output in odd & even
                oDE<=oDE_tmp[0];
                oHS<=oHS_tmp[0];
                oVS<=oVS_tmp[0];

                oDE_tmp<={iDE,oDE_tmp[1]};
                oHS_tmp<={iHS,oHS_tmp[1]};
                oVS_tmp<={iVS,oVS_tmp[1]};

            end
        end
        else //one port
        begin
            R_data_a<=iRDATA_86;
            G_data_a<=iGDATA_86;
            B_data_a<=iBDATA_86;
            R_data_b<=iRDATA_86;
            G_data_b<=iGDATA_86;
            B_data_b<=iBDATA_86;
            oDE<=iDE;
            oHS<=iHS;
            oVS<=iVS;
        end
    end
end

always@(posedge iclk) begin
    if(!iRESET)
        cnt<=0;
    else begin
        if(iDE==1'b1)
            cnt<=cnt+1;
        else
            cnt<=0;
    end
end


assign 	iiclk=(iSW3==1'b1)?~iclk:iclk;
always@(posedge iiclk) begin
    if(!iRESET)
        half_clk<=0;
    else
        half_clk<=~half_clk;
end


endmodule

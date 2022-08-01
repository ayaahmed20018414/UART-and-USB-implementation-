fname='config.json';
fconf=fopen(fname);
raw=fread(fconf);
str=char(raw');
fclose(fconf);
val=jsondecode(str);
ff1=strcmp(val(1).protocol_name,'UART');
ff2=strcmp(val(2).protocol_name,'UART');
ff3=strcmp(val(1).protocol_name,'USB');
ff4=strcmp(val(2).protocol_name,'USB');
if(ff1||ff2)
    if(ff1)
        b1=struct(val(1).protocol_name,val(1).parameters);
        [v1,v2,v3]=UART(b1);
    elseif(ff2)
        b2=struct(val(2).protocol_name,val(2).parameters);
        [v1,v2,v3]=UART(b2);
    end
else
        fprintf("UART protocol doesn't exist\n");
        v1=0; v2=0; v3=0;
end
         
 
if(ff3||ff4)
    if(ff3)
        b3=struct(val(1).protocol_name,val(1).parameters);
        [l1,l2,l3]=USB(b3);
    elseif(ff4)
        b4=struct(val(2).protocol_name,val(2).parameters);
        [l1,l2,l3]=USB(b4);
    end
else
        fprintf("USB protocol doesn't exist\n");
        l1=0; l2=0; l3=0;         
end
if((ff1==0)&&(ff2==0)&&(ff3==0)&&(ff4==0))
    fprint("Please Enter UART or USB Protocol in conf file\n");
end
output_1(v1,v2,v3,l1,l2,l3);
function [total_time,over_head_percentage,efficiency]=UART(pro_uart)
%read input data file
f1=fopen('inputdata.txt');
f2=fread(f1,inf);
f3=logical(dec2bin(f2)-'0');
f3_1=logical(dec2bin(f2,8)-'0');
data_INPUT_flipped= fliplr(f3);
data_INPUT_flipped_1= fliplr(f3_1);
data_INPUT_transposed= transpose(data_INPUT_flipped);
data_INPUT_transposed_1= transpose(data_INPUT_flipped_1);
fclose(f1);
data_size=length(f2);
    if (pro_uart.UART.data_bits==7)
        data_INPUT_reshaped= reshape(data_INPUT_transposed,7,data_size);
        if(strcmp('odd',pro_uart.UART.parity))
        for i=1:data_size
            B= sum(data_INPUT_reshaped(:,i));
            if(mod(B,2)==0)
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 1];
            else
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 0];
            end  
        end   
    elseif (strcmp('even',pro_uart.UART.parity))
        for i=1:data_size
            B= sum(data_INPUT_reshaped(:,i));
            if (mod(B,2)==0)
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 0];
            else
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 1];
            end    
        end
        elseif(strcmp('none',pro_uart.UART.parity))
             for i=1:data_size
                 data_with_parity(:,i)=data_INPUT_reshaped(:,i);
             end 
        else
        fprintf('ERROR!!! you must write "even" or "odd" or "none" in conf file\n','%s');
        return;
        end    
    if (pro_uart.UART.stop_bits==1)
        for n=1:data_size
            data_with_stopbits(:,n)= [data_with_parity(:,n) ; 1];
            UART_DATA_PACKETS(:,n)= [0 ;data_with_stopbits(:,n)];
        end
    elseif (pro_uart.UART.stop_bits==2)
        for n=1:data_size
            data_with_stopbits(:,n)= [data_with_parity(:,n) ; 1 ; 1];
            UART_DATA_PACKETS(:,n)= [0 ;data_with_stopbits(:,n)];
        end    
    else
         fprintf ('ERROR!!! you must write 1 or 2 in conf file\n','%s');
         return;
    end
    disp(pro_uart.UART.data_bits);
    elseif (pro_uart.UART.data_bits==8)
        data_INPUT_reshaped= reshape(data_INPUT_transposed_1,8,data_size);
    if (strcmp('odd',pro_uart.UART.parity))
        for i=1:data_size
            B= sum(data_INPUT_reshaped(:,i));
            if (mod(B,2)==0)
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 1];
            else
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 0];
            end  
        end   
    elseif (strcmp('even',pro_uart.UART.parity))
        for i=1:data_size
            B= sum(data_INPUT_reshaped(:,i));
            if (mod(B,2)==0)
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 0];
            else
                data_with_parity(:,i)= [data_INPUT_reshaped(:,i) ; 1];
            end    
        end
        elseif(strcmp('none',pro_uart.UART.parity))
             for i=1:data_size
                 data_with_parity(:,i)=data_INPUT_reshaped(:,i);
             end 
    else
        fprintf ('ERROR!!! you must write "even" or "odd" or "none" in conf file\n','%s');
         return;
    end    
    if(pro_uart.UART.stop_bits==1)
        for n=1:data_size
            data_with_stopbits(:,n)= [data_with_parity(:,n) ; 1];
            UART_DATA_PACKETS(:,n)= [0 ;data_with_stopbits(:,n)];
        end
    elseif(pro_uart.UART.stop_bits==2)
        for n=1:data_size
            data_with_stopbits(:,n)= [data_with_parity(:,n) ; 1 ; 1];
            UART_DATA_PACKETS(:,n)= [0 ;data_with_stopbits(:,n)];
        end
    else
         fprintf ('ERROR!!! you must write 1 or 2 in conf file\n','%s');
         return;   
    end     
    else
        fprintf ('ERROR!!! you must write 7 or 8 in conf file\n','%s');
        return;
    end
 
figure (1);
bit_duration=pro_uart.UART.bit_duration;
first_2_packages=[UART_DATA_PACKETS(:,1); UART_DATA_PACKETS(:,2);1];
time =linspace(0,length(first_2_packages)*bit_duration,length(first_2_packages));
stairs(time,first_2_packages,'linewidth',3);
axis([0 0.0021 0 2]);
title ('Sending data with UART');
A= size(UART_DATA_PACKETS);
total_time = A(1)*A(2)*bit_duration;
if (pro_uart.UART.data_bits==7)&&(pro_uart.UART.stop_bits==1)&&(strcmp(pro_uart.UART.parity,'odd')||strcmp(pro_uart.UART.parity,'even'))
    over_head_bits_num=3;
    over_head_percentage=(over_head_bits_num/10)*100;
elseif (pro_uart.UART.data_bits==7)&&(pro_uart.UART.stop_bits==2)&&(strcmp(pro_uart.UART.parity,'odd')||strcmp(pro_uart.UART.parity,'even'))
    over_head_bits_num=4;
    over_head_percentage=(over_head_bits_num/11)*100;
elseif (pro_uart.UART.data_bits==8)&&(pro_uart.UART.stop_bits==2)&&(strcmp(pro_uart.UART.parity,'odd')||strcmp(pro_uart.UART.parity,'even'))
    over_head_bits_num=4;
    over_head_percentage= (over_head_bits_num/12)*100;
elseif (pro_uart.UART.data_bits==8)&&(pro_uart.UART.stop_bits==1)&&(strcmp(pro_uart.UART.parity,'odd')||strcmp(pro_uart.UART.parity,'even'))
    over_head_bits_num=3;
    over_head_percentage= (over_head_bits_num/11)*100; 
elseif(pro_uart.UART.data_bits==8)&&(pro_uart.UART.stop_bits==1)&&(strcmp(pro_uart.UART.parity,'none'))
    over_head_bits_num=2;
    over_head_percentage= (over_head_bits_num/10)*100;
elseif(pro_uart.UART.data_bits==8)&&(pro_uart.UART.stop_bits==2)&&(strcmp(pro_uart.UART.parity,'none'))
    over_head_bits_num=3;
    over_head_percentage= (over_head_bits_num/11)*100;
elseif(pro_uart.UART.data_bits==7)&&(pro_uart.UART.stop_bits==1)&&(strcmp(pro_uart.UART.parity,'none'))
   over_head_bits_num=2;
    over_head_percentage= (over_head_bits_num/9)*100;
elseif(pro_uart.UART.data_bits==7)&&(pro_uart.UART.stop_bits==2)&&(strcmp(pro_uart.UART.parity,'none'))
    over_head_bits_num=3; 
    over_head_percentage= (over_head_bits_num/10)*100;
end
efficiency= 100-over_head_percentage;
fprintf('The time to transmit this data using UART= %d',total_time);
fprintf('\nAnd the percentage overhead is %d',over_head_percentage);
fprintf('\n,Then the efficiency is= %d\n\n',efficiency); 

SIZE_OF_PACKETS=pro_uart.UART.data_bits;
Datalarge=1:1:2000;
Z_1= ceil(Datalarge./SIZE_OF_PACKETS);
O=(over_head_bits_num*Z_1)./(Datalarge+over_head_bits_num*Z_1)*100;        %percentage overhead=(overhead data ) no of packets / total data length
transtime= pro_uart.UART.bit_duration*(Datalarge+over_head_bits_num*Z_1);
figure (2);
plot (Datalarge,transtime); %The transmit time of the data
xlabel('Data size');
ylabel('transmission time');
grid on;
figure (3);
plot (Datalarge,O);     %Percentage overhead vs file size    
xlabel('Data size');
ylabel('Percentage overhead');
axis([0 2000 0 30]);
grid on;
end


function [Total_Timeall,overhead,efficiencyall]= USB(pro_USB)
%read data
f=fopen("inputdata.txt");
Data = fread(f);
fclose(f);
Data=dec2bin(Data,8);
Data=Data-'0';
Data=Data.';
Data=flip(Data);
Data=reshape(Data,pro_USB.USB.payload*8,[]);
Datal=reshape(Data,[],1);
%sync
Sync =pro_USB.USB.sync_pattern - [48; 48; 48 ; 48 ; 48 ;48 ;48 ;48; 48; 48;];
Sync=Sync.';
%address
Address= pro_USB.USB.dest_address-'0'; %to convert to decimal
Address=Address.';
Address=flip(Address);
Address=repmat(Address,[1,10]);
% PID 
pid=[1;2;3;4;5;6;7;8;9;10;];
pid=dec2bin(pid,4);
pid=pid-'0';
pid=pid.';
pid=flip(pid);
pid2=~pid;
PID=[pid;pid2];
%for packets
packets=[Sync; PID; Address; Data;];
[nn,mm]=size(packets);
EOP=[0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0];
P=[Sync; PID; Address; Data; EOP];
Dataline=reshape(packets,[],1);
PT=reshape(P,[],1);
% bit stuffing and NRZI
Dtota1p=1;
DtotalI=1;
Stuff_num=0;
D=1;
i=0;
k=0;
for k= 1:10
    O_P=packets(:,k);
    nn=length(O_P);
    count=0;
    for i=1:nn
        if(O_P(i)== 1) %%% COUNTER of 6 ones
         count =count+1;
      else
         count=0;
      end
    if (count == 6)
          O_P=[O_P(1:i,1) ; 0 ; O_P(i+1 : end , 1)];           
          count = 0;
          nn=nn+1;
          Stuff_num=Stuff_num+1;
    end 
 % NRZI
 if (O_P(i)==0)
        D=~D;
    end
    Dtota1p=[Dtota1p; D];
    DtotalI=[DtotalI;~D];
 
end
Dtota1p=[Dtota1p;0;0];
DtotalI=[DtotalI;0;0];
end
 %plotting data'sample of the bit sequence USB'for 2 packets
figure(4);
stairs(Dtota1p);
xlabel('time*10^-4');
ylabel('sending Data D+');
axis ([2090  2110 0  2]);
grid on;
figure(5);
stairs(DtotalI);
xlabel('time*10^-4');
ylabel('sending Data D-');
axis ([2090 2110 0  2]);
hold on;
disp('total time required to transmit the input data file'); %%% TOtal transmission time
Total_Timeall = length(Dtota1p)*pro_USB.USB.bit_duration;
disp(Total_Timeall);
ActualData=length(PT);
disp('Eff %:');
efficiencyall= (length(Datal)./length(Dtota1p)*100);
disp(efficiencyall);
disp('Overhead :');
overhead=100-efficiencyall;
disp(overhead);
Datalarge=1:1:2000;%size of ver. data in byte
Z= ceil(Datalarge*8./1024);
O=(29*Z)./(Datalarge*8+29*Z)*100;        %percentage overhead=(overhead data ) no of packets / total data length
transtime= pro_USB.USB.bit_duration*(Datalarge*8+29*Z);
figure (6);
plot (Datalarge,transtime); %The transmit time of the data
xlabel('Data size in byte');
ylabel('transmission time');
grid on;
figure (7);
plot (Datalarge,O);     %Percentage overhead vs file size    
xlabel('Data size in byte');
ylabel('Percentage overhead');
grid on;
end

function output_1(v1,v2,v3,l1,l2,l3)
out_struct1=struct('protocol_name','UART','outputs',struct('total_tx_time',v1,'overhead',v2,'efficiency',v3));
out_struct2=struct('protocol_name','USB','outputs',struct('total_tx_time',l1 , 'overhead',l2,'efficiency',l3));
out_struct={out_struct1;out_struct2};
out_1=jsonencode(out_struct);
output='output.json';
o_f=fopen(output,'w');
fprintf(o_f,out_1);
end
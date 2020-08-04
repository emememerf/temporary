clear all
close all
clc
%function output=cc1t2_decode(num,data,state_init)
%num为编码后的比特数
fbaud=600;%基带信号波特率，1s发送600个码元 %则一个码元持续时间TB=1/600s
T_total=5;%总的采样时间是5s
i=fbaud*T_total;%基带信号码元数
num=2*i;
state_init=0;
data_in=round(rand(1,i));%产生数字基带信号
data=cc12_encodefinal(data_in,i,state_init);
state0=0;
state1=1;
state2=2;
state3=3;
curstate0=0;
curstate1=0;
curstate2=0;
curstate3=0;
data_trans=zeros(num/2,2);
temp1=1:2;
for k=1:num/2
    data_trans(k,:)=data(2*(k-1)+temp1);
end
temp=[];%存储最短路径
d00=0;%汉明距离
d01=0;
d10=0;
d11=0;
d20=0;
d21=0;
d30=0;
d31=0;
d=zeros(4,1);
data_est10=0;
data_est11=0;
data_est20=0;
data_est21=0;
data_est30=0;
data_est31=0;
data_est00=0;
data_est01=0;
data_est0=[];
data_est1=[];
data_est2=[];
data_est3=[];
data_output=[];
%先在0,1,2三个时刻计算出每个状态的幸存路径（因为从第三个时刻开始每个状态节点才具有两条路径）
%s0状态  假设初始状态为00
s00=[0 0 0 0];
%s01=[1 1 1 0 1 1];
s10=[1 1 1 0];
%s11=[1 1 0 1 0 1];
s20=[0 0 1 1];
%s21=[1 1 1 0 0 0];
s30=[1 1 0 1];
%s31=[1 1 0 1 1 0];
for index=1:4
    if(data(index)~=s00(index))
        d00=d00+1;
    end
    if(data(index)~=s10(index))
        d10=d10+1;
    end
    if(data(index)~=s20(index))
        d20=d20+1;
    end
    if(data(index)~=s30(index))
        d30=d30+1;
    end
end
d(1)=d00;
data_est0=[data_est0,0,0];
d(2)=d10;
data_est1=[data_est1,1,0];
d(3)=d20;
data_est2=[data_est2,0,1];
d(4)=d30;
data_est3=[data_est3,1,1];

s00=[0 0];
s01=[1 1];
s10=[1 1];
s11=[0 0];
s20=[1 0];
s21=[0 1];
s30=[0 1];
s31=[1 0];

curstate00=state0;
curstate01=state2;
curstate20=state1;
curstate21=state3;
for index=3:num/2
    d00=0;%汉明距离
    d01=0;
    d10=0;
    d11=0;
    d20=0;
    d21=0;
    d30=0;
    d31=0;
    
    temp0=data_est0;
    temp1=data_est1;
    temp2=data_est2;
    temp3=data_est3;
    %cur_state=nextstate;
    if curstate00==state0 || curstate10==state0
        for k=1:2
            if(data_trans(index,k)~=s00(k))
                d00=d00+1; %求汉明距离
            else d00=d00;
            end
            
            if(data_trans(index,k)~=s01(k))
                d20=d20+1;
            else d20=d20;
            end
        end
        
    end
    
    if curstate20==state1 || curstate30==state1
        for k=1:2
            if(data_trans(index,k)~=s10(k))
                d01=d01+1;
            else d01=d01;
            end
            if(data_trans(index,k)~=s11(k))
                d21=d21+1;
            else d21=d21;
            end
        end
        
    end
    
    
    if curstate01==state2 || curstate11==state2
        for k=1:2
            if(data_trans(index,k)~=s20(k))
                d10=d10+1;
            else d10=d10;
            end
            if(data_trans(index,k)~=s21(k))
                d30=d30+1;
            else d30=d30;
            end
        end
        
    end
    
    
    if curstate21==state3 || curstate31==state3
        for k=1:2
            if(data_trans(index,k)~=s30(k))
                d11=d11+1;
            else d11=d11;
            end
            if(data_trans(index,k)~=s31(k))
                d31=d31+1;
            else d31=d31;
            end
        end
        
    end
    
    
    
    if(d00+d(1)<d01+d(2)) d(1)=d00+d(1);
        data_est0=[temp0,0];
        curstate00=state0;
        
    else d(1)=d01+d(2);
        data_est0=[temp1,0];
        curstate10=state0;
        
    end
    
    if(d10+d(2)<d11+d(3)) d(2)=d10+d(2);
        data_est1=[temp2,0];
        curstate20=state1;
        
    else d(2)=d11+d(3);
        data_est1=[temp3,0];
        curstate30=state1;
        
    end
    
    if(d20+d(1)<d21+d(2)) d(3)=d20+d(1);
        data_est2=[temp0,1];
        curstate01=state2;
        
    else d(3)=d21+d(2);
        data_est2=[temp1,1];
        curstate11=state2;
        
    end
    
    if(d30+d(3)<d31+d(4)) d(4)=d30+d(3);
        data_est3=[temp2,1];
        curstate21=state3;
        
    else d(4)=d31+d(4);
        data_est3=[temp3,1];
        curstate31=state3;
        
    end
    
end
[x i]=min(d);
if i==1
    data_est=data_est0;
else if i==2
        data_est=data_est1;
    else if i==3
            data_est=data_est2;
        else if i==4
                data_est=data_est3;
            end
        end
    end
end

ber=0;
for iter=1:num/2
    if data_est(iter)~=data_in(iter)
        ber=ber+1;
    end
end
ber_rate=ber/(num/2);




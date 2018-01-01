%% ESE534 Course project Data processing
%
%   Author: Zhangjie Chen
%   Stony Brook University
%%
%Read raw data file
Raw_data = load('534testdata1.csv');
[a,b] = size(Raw_data);
Frame_N = a/140;

% Data saving matrix initialization
Frame_data=zeros(140, Frame_N);
Grid_EYE_data = zeros(8,8,Frame_N);
Vl53l0x_data = zeros (Frame_N, 4);
Thermistor_data = zeros(Frame_N,1);
N = 4;                             %interpolation cofficient 
Grid_EYE_data_interpo = zeros(8*N,8*N,Frame_N);
Grid_EYE_data_sub = zeros(8*N,8*N,Frame_N);
%Data extraction, each column represents the data of a frame
for i=1:1:Frame_N
    Frame_data(:,i) = Raw_data((140*(i - 1)+1):(140*i),:);
end

%Data extraction, seprate three type of sensor data(Grid-EYE 8x8,
%thermistor, Vl53l0x 4x1)
for i = 1:1:Frame_N
    Thermistor_data(i,1) = (Frame_data (1, i)+256*Frame_data (2, i))*0.0625;
    for j = 1:8
        for k = 1:8
            Grid_EYE_data(j,k,i) = (Frame_data(3+((j-1)*8+k-1)*2,i)+256*Frame_data(3+((j-1)*8+k-1)*2+1,i))/4;
        end
    end
    % Intepolation
    Grid_EYE_data_interpo(:,:,i) = imresize(Grid_EYE_data(:,:,i),N,'bilinear');
    
     Vl53l0x_data(i,1) = Frame_data(131,i)+256*Frame_data(132,i);
     Vl53l0x_data(i,2) = Frame_data(133,i)+256*Frame_data(134,i);
     Vl53l0x_data(i,3) = Frame_data(135,i)+256*Frame_data(136,i);
     Vl53l0x_data(i,4) = Frame_data(137,i)+256*Frame_data(138,i);
end

%% Vl53l0x filter the data 


for i=1:Frame_N 
    for j=1:4
        Vl53l0x_data_filtered(i,j)= Vl53l0x_data(i,j);
    if(Vl53l0x_data(i,j)==8190 || Vl53l0x_data(i,j)<=30) 
        Vl53l0x_data_filtered(i,j)=1200;
        end
    end
end

%%backgroud
f=zeros(8*N,8*N);
for i=1:5
    
f=f+Grid_EYE_data_interpo(:,:,i);

end

f=f/5;

%%subtraction

for i=1:Frame_N 
    
    
    Grid_EYE_data_sub(:,:,i)=Grid_EYE_data_interpo(:,:,i)-f;
    
end  

%%gaussian filter 
for i=1:Frame_N 
    
    Grid_EYE_data_filtered(:,:,i)=imgaussfilt(Grid_EYE_data_sub(:,:,i),0.5);%%sigma
    Grid_EYE_data_threshold(:,:,i)=Grid_EYE_data_filtered(:,:,i);
end

%%set threshold

for i=1:Frame_N 
   for j=1:32
    for k=1:32
        %Thd_b=max(abs(Grid_EYE_data_filtered));
        %Thd_b=sort(Thd_b);
        thre = 3.6;
        if(Grid_EYE_data_filtered(j,k,i)>thre)
            Grid_EYE_data_threshold(j,k,i)=1;
        end
        if(Grid_EYE_data_filtered(j,k,i)<=thre)
            Grid_EYE_data_threshold(j,k,i)=0;
        end
    end
        
  end
end



for i=1:Frame_N
    for j=1:13
        Vl53l0x_data_interpo(i,j)=1201;
    end
end

%% subplot
%{
for i=1:Frame_N 
     figure
     subplot(1,2,1);
    bar_1=[Vl53l0x_data_filtered(i,1)
    Vl53l0x_data_filtered(i,2)
    Vl53l0x_data_filtered(i,3)
    Vl53l0x_data_filtered(i,4)];
    bar(bar_1);


    
    
    
    
    subplot(1,2,2);
   
    image(Grid_EYE_data_threshold(:,:,i),'CDataMapping','scaled');  
    %%surf(Grid_EYE_data_sub(:,:,i),'CDataMapping','scaled');
    colormap('jet');
    %%axis([0 40 0 35 20 30]);3d
    caxis([-1 5]) ;
    
    axis equal
    
    %%saveas(gcf,[num2str(i),'.png'])
  
end
%}
%% the vl53 is used to align the the data, make sure people pass the door


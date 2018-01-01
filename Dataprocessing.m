label_matrix=ones(3,10);
hotspot_center = zeros(10,3,Frame_N);
label_2=[];
label_3=[];
%plot_x=zeros(100,Frame_N); %%num change?       
%plot_y=zeros(100,Frame_N);

%plot_x_t=zeros(100,Frame_N);        
%plot_y_t=zeros(100,Frame_N);

%Label=zeros(100,Frame_N);

hotspot_num = zeros(1,Frame_N);

%distances=zeros(100,Frame_N);




for f=1:Frame_N



% delete small zones

%{
for i=1:height
    for j=1:width
        for t=1:num
            if L(i,j)==t
               zonesSize(1,t)=zonesSize(1,t)+1;%% sum the zoneSize
            end
        end
    end
end
%}


%{
for i=1:height
    for j=1:width
        for t1=1:num
            if (zonesSize(1,t1)<=13 && L(i,j)==t1)
               L(i,j)=0;
            end
        end
        
    end
end
%}

%%set centroid
L1=Grid_EYE_data_threshold(:,:,f);
[L,num]=bwlabel(L1,8);     %%L num
zonesSize = zeros(1,num);
sum_x=zeros(1,num);sum_y=zeros(1,num);area=zeros(1,num);
[height,width]=size(L1);

p=1;

%Calculate heat source center
for t2=1:num
    
    zonesSize(1,t2) =sum(sum(L1==t2));
    
    if (zonesSize < 13)
        L1(L1==t2) = 0;    
    else
         for i=1:height
             for j=1:width
                 if L(i,j)==t2
                     sum_x(1,t2)=sum_x(1,t2)+i;
                     sum_y(1,t2)=sum_y(1,t2)+j;
                     area(1,t2)=area(1,t2)+1;
                 end
             end
         end
         hotspot_center(p,1,f) = fix(sum_x(1,t2)/area(1,t2));
         hotspot_center(p,2,f) = fix(sum_y(1,t2)/area(1,t2));
         p=p+1;
    end
end
Grid_EYE_L(:,:,f)=L1;
hotspot_num(1,f) = p-1;


%labeling
if (f<2 && hotspot_num(1,f)>0)
    for i = 1: hotspot_num(1,f)
       label = max(label_matrix(1,:))+1;
       hotspot_center(i,3,f) = label;
        label_matrix(1,label) = label;
        label_matrix(3,label) = label_matrix(3,label)+1;
    end
    
end

if(f>=2 && hotspot_num(1,f)>0)
    for i = 1: hotspot_num(1,f)
    distance=zeros(1,hotspot_num(1,f-1));
        if (hotspot_num(1,f-1)>0)
             for j=1:hotspot_num(1,f-1)
             distance(1,j)= norm([hotspot_center(i,1,f),hotspot_center(i,2,f)] - [hotspot_center(j,1,f-1),hotspot_center(j,2,f-1)]);
             end
             d_min = min(distance);
             I_dis = find ((distance==d_min));
             [~,k] = size(I_dis);
             if (k==1)
                 label = hotspot_center(I_dis(1,1),3,f-1);
                 hotspot_center(i,3,f) = label;
                 label_matrix(3,label) = label_matrix(3,label)+1;
                if (label ==2)
                   label_2(label_matrix(3,label),2) = hotspot_center(i,1,f);
                   label_2(label_matrix(3,label),1) = hotspot_center(i,2,f);
                end
                 if (label ==3)
                 label_3(label_matrix(3,label),2) = hotspot_center(i,1,f);
                 label_3(label_matrix(3,label),1) = hotspot_center(i,2,f);      
                 end
             else
                 disp(strcat('same distance found at frame: ',int2str(f)));
             end    
        else
            label = max(label_matrix(1,:))+1;
            hotspot_center(i,3,f) = label;
            label_matrix(1,label) = label;
            label_matrix(3,label) = label_matrix(3,label)+1;
            if (label ==2)
            label_2(label_matrix(3,label),2) = hotspot_center(i,1,f);
            label_2(label_matrix(3,label),1) = hotspot_center(i,2,f);
            end
            if (label ==3)
            label_3(label_matrix(3,label),2) = hotspot_center(i,1,f);
            label_3(label_matrix(3,label),1) = hotspot_center(i,2,f);
            end
        end  
    end
    
    
end


if(f >= 2 && hotspot_num(1,f) == 0)
    for q=1:10
        if label_matrix(1,q)>1
            label_matrix(2,q) = 0;
        end
    end
end

%{
for t3=1:num
    
    if(plot_x(t3,f)<=32 && plot_x(t3,f)>=1 && plot_y(t3,f)<=32 && plot_y(t3,f)>=1)
        plot_x_t(p,f)=fix(sum_x(1,t3)/area(1,t3));
        plot_y_t(p,f)=fix(sum_y(1,t3)/area(1,t3));
        
        p=p+1;
        
        if f>1
            for t4=1:number_p(1,f-1)
                distances(t3,f)=norm([plot_x_t(t3,f),plot_y_t(t3,f)]-[plot_x_t(t4,f-1),plot_y_t(t4,f-1)]);
            end
            dismin = min(distances(1:number_p(1,f-1)));
            x= find(distances(1:number_p(1,f-1))==dismin);
        end
    end
    
       
      
end
%}

figure;
subplot(2,2,1)
image(Grid_EYE_data(:,:,f),'CDataMapping','scaled');
caxis([23 30]) ;
colormap('jet');
title('Raw Grid-EYE sensor data');
subplot(2,2,2)
 x=1:1:4;
 x1=1:0.25:4;
 x2=1:1:13;
 x3=1:1:Frame_N;
 Vl53l0x_data_interpo(f,:) = interp1(x,Vl53l0x_data_filtered(f,x),x1,'spline');
 surf(x2,x3,Vl53l0x_data_interpo(1:Frame_N,:));
 set(gca,'ZLim',[0 1200],'Ylim',[0 110])
 view(90,0)
title('VL53l0x sensor data');
 
 
subplot(2,2,4)
image(Grid_EYE_L(:,:,f),'CDataMapping','scaled');
caxis([0 1]) ;
colormap('jet');
hold on
if (label_matrix(1,2)>1 && label_matrix(2,2)>0 && label_matrix(3,2)>1)
    plot(label_2(2:end,1),label_2(2:end,2),'-g','LineWidth',2);    
end
hold on
if (label_matrix(1,3)>1 && label_matrix(2,3)>0 && label_matrix(3,3)>1)
    plot(label_3(2:end,1),label_3(2:end,2),'-r','LineWidth',2);    
end
hold on
if(hotspot_num(1,f)>0)
   for t3=1:hotspot_num(1,f)
 %if plot_x(t3,f)<=32 && plot_x(t3,f)>=1 && plot_y(t3,f)<=32 && plot_y(t3,f)>=1
    plot(hotspot_center(t3,2,f),hotspot_center(t3,1,f), '-*r');
    hold on
% end
   end
end
title('Counting');

subplot(2,2,3)
image(Grid_EYE_data_filtered(:,:,f),'CDataMapping','scaled');
caxis([-1 5]);
colormap('jet');
title('Processed Grid-EYE sensor data');

saveas(gcf,[num2str(f),'.png']);

end


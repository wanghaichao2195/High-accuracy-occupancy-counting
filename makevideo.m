last_ext='.png'; 
mov = VideoWriter('ESE534_final');
mov.FrameRate=10;
open(mov); 
for i=1:Frame_N %frame_rate the picture number 
int2double = double(i); 
double2string = int2str(int2double); 
filename = sprintf('%d.png', i);
img = imread(filename); 
frame2insert = im2frame(img); 
writeVideo(mov,frame2insert); 
end 
close(mov);
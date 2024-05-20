% %Case 1
% p=0.5; %probability
% n=3; %matrix size
% maxt=1; %num of time steps
% maxr=1000; %num of realizaations

%Case 2
p=0.4; %probability
n=24; %matrix size
maxt=10; %num of time steps
maxr=1000; %num of realizaations


%initialze the mean matrix
Mavg=zeros(n,n,maxt);


for k=1:maxr %Looping over all realizations
    
    %initialize matrix and putting it back to its original state
   
    M=zeros(n,n); 
    M(n/2,n/2)=1;
    
    %M(2,2)=1; %Case 1
    
%     M(3:4,3:4)=1; %Case 2
    
    %Looping over the timesteps and adding to the mean matrix: Mavg
    
    for z=1:maxt
        Mnew = propagate_onestep(M,p);
        
        imagesc(Mnew);

        M=Mnew;
        
        Mavg(:,:,z) = Mavg(:,:,z) + M(:,:); %only have to include z for Mavg if its more than 1 timestep
    end
  
end

%normalizing the mean
Mavg = Mavg./maxr;

%initialize vid
vidfile = VideoWriter('movie_mean.mp4','MPEG-4');
open(vidfile);

for k=1:maxt %Looping over all timesteps
  imagesc(Mavg(:,:,k)); % this creates an image of the step k matrix
  F(k) = getframe(gcf);  % this records the image 
  writeVideo(vidfile,F(k));  % this appends it to the video 
  xlabel('Longitude','FontSize',40);
  ylabel('Latitude','FontSize',40);
  set(gca,'FontSize',20)
  colorbar;
end
close(vidfile)

%propagate fire function
function Mnew = propagate_onestep(M,p)
[row,col]=size(M);
Mnew=M;
for i=2:col-1 %loops through all elements of M that are not the edges
    for j=2:row-1
        if M(i,j)==1 %checking if the tile is on fire
            Mnew=update(Mnew,i,j-1,p); %propagate left
            Mnew=update(Mnew,i,j+1,p); %propagate right
            Mnew=update(Mnew,i-1,j,p); %propagate up
            Mnew=update(Mnew,i+1,j,p); %propagate down
            Mnew=update(Mnew,i-1,j-1,p); %propagate up left
            Mnew=update(Mnew,i-1,j+1,p); %propagate up right
            Mnew=update(Mnew,i+1,j-1,p); %propagate down left
            Mnew=update(Mnew,i+1,j+1,p); %propagate down right
        end
    end
end
end

%update function
function M = update(Mnew,i,j,p) 
    if rand(1)<p
        Mnew(i,j)=1;
    end
M=Mnew;
end

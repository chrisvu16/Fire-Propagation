p=0.4; %probability
n=20; %matrix size
maxt=10; %num of iterations

%initialze matrix
M=zeros(n,n);
M(n/2,n/2)=1;

%save initial condition for movie

Mmov(:,:,1)=M;
imagesc(M);
F(1) = getframe(gcf);
writeVideo(vidfile,F(1));

vidfile = VideoWriter('testmovie.mp4','MPEG-4');
open(vidfile);
for k=1:maxt %Looping over all timesteps
  %Mnew=propagate_onestep(M,p);
  imagesc(Mmov(:,:,k)) % this creates an image of the step k matrix
  %imagesc(Mnew);
  F(k) = getframe(gcf);  % this records the image 
  writeVideo(vidfile,F(k));  % this appends it to the video 
end
close(vidfile) 
%propagate fire function
function Mnew = propagate_onestep(M,p);
[row,col]=size(M);
Mnew=M;
for i=2:col-1 %loops through all elements of M that are not the edges
    for i=2:row-1
        if M(i,j)==1 %checking if the tile is on fire
            Mnew=updateM(Mnew,i,j-1,p); %propagate left
            Mnew=updateM(Mnew,i,j+1,p); %propagate right
            Mnew=updateM(Mnew,i-1,j,p); %propagate up
            Mnew=updateM(Mnew,i+1,j,p); %propagate down
            Mnew=updateM(Mnew,i-1,j-1,p); %propagate up left
            Mnew=updateM(Mnew,i-1,j+1,p); %propagate up right
            Mnew=updateM(Mnew,i+1,j-1,p); %propagate down left
            Mnew=updateM(Mnew,i+1,j+1,p); %propagate down right
        end
    end
end
end

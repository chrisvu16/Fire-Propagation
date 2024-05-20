% Parameters
p = 1;       % Base probability; any number
n = 26;        % Matrix size
maxt = 10;     % Num of time steps
maxr = 1000;   % Num of realizations

% % Initialize matrices
Mavg = zeros(n, n, maxt);
% elevate = zeros(n, n);
% 
% %Generate randomized elevation with incremental rule
% for i = 1:n
%     range_start = (i - 1) / n;
%     range_end = i / n;
%     elevate(i, :) = range_start + rand(1,size(elevate, 2)) * (range_end - range_start);
% end
noise_range = 0.05;  % Range for random noise

% Initialize elevation matrix
elevate = zeros(n, n);

% Generate elevation matrix
for i = 1:n
    % Generate a consistent uphill slope for each row
    e_mean = i / n;
    
    for j = 1:n
        % Calculate elevation based on the formula
        elevate(i, j) = e_mean + (rand() * noise_range);
    end
end

for k = 1:maxr
    % Initialize matrix and put it back to its original state
    M = zeros(n, n);
    M(n/2, n/2) = 1;
   
    % Loop over the time steps and add to the mean matrix: Mavg
    for z = 1:maxt
        Mnew = propagate_onestep(M, p, elevate);
        M = Mnew;
        Mavg(:, :, z) = Mavg(:, :, z) + M(:, :);
    end
end

% Normalize the mean
Mavg = Mavg ./ maxr;

%Initialize video
vidfile = VideoWriter('fire_simulation_with_elevation_slope.mp4', 'MPEG-4');
open(vidfile);

%Loop over all time steps
for k = 1:maxt
    % Create a figure
    figure;

%     % Plot the matrix
    imagesc(Mavg(:,:,k));

   
    title(['Fire Simulation with Elevation - Time Step ' num2str(k)]);
    colorbar;

    % Capture the frame
    F(k) = getframe(gcf);
    writeVideo(vidfile, F(k));

    % Close the figure to avoid multiple open figures
    close(gcf);
end
% Close the video file
close(vidfile);

figure;
last=imagesc(Mavg(:,:,maxt));
title(['Fire Simulation with Elevation - Time Step ' num2str(maxt)]);
xlabel('Longitude','FontSize',40);
ylabel('Latitude','FontSize',40);
set(gca,'FontSize',20)
colorbar;
saveas(last,'results.png')

% Propagate fire function with elevation and slope-dependent probabilities
function Mnew = propagate_onestep(M, p, elevate)
    [row, col] = size(M);
    Mnew = M;

    for i = 2:col-1
        for j = 2:row-1
            if M(i, j) == 1
                % Calculate slopes
                slope_right = (elevate(i, j) - elevate(i, j+1)) / 1;
                slope_left = (elevate(i, j) - elevate(i, j-1)) / 1;
                slope_down = (elevate(i, j) - elevate(i+1, j)) / 1;
                slope_up = (elevate(i, j) - elevate(i-1, j)) / 1;
                slope_down_right = (elevate(i, j) - elevate(i+1, j+1)) / sqrt(2);
                slope_down_left = (elevate(i, j) - elevate(i+1, j-1)) / sqrt(2);
                slope_up_right = (elevate(i, j) - elevate(i-1, j+1)) / sqrt(2);
                slope_up_left = (elevate(i, j) - elevate(i-1, j-1)) / sqrt(2);

              

                % Assign probabilities based on slope
                p_right = assign_probability(p, slope_right);
                p_left = assign_probability(p, slope_left);
                p_down = assign_probability(p, slope_down);
                p_up = assign_probability(p, slope_up);
                p_down_right = assign_probability(p, slope_down_right);
                p_down_left = assign_probability(p, slope_down_left);
                p_up_right = assign_probability(p, slope_up_right);
                p_up_left = assign_probability(p, slope_up_left);

                
                % Propagate fire based on adjusted probabilities
                Mnew = update(Mnew, i, j+1, p_right);
                Mnew = update(Mnew, i, j-1, p_left);
                Mnew = update(Mnew, i+1, j, p_down);
                Mnew = update(Mnew, i-1, j, p_up);
                Mnew = update(Mnew, i+1, j+1, p_down_right);
                Mnew = update(Mnew, i+1, j-1, p_down_left);
                Mnew = update(Mnew, i-1, j+1, p_up_right);
                Mnew = update(Mnew, i-1, j-1, p_up_left);
            end
        end
    end
end

% Function to assign probabilities based on slope
function prop = assign_probability(~, slope)
    
    a=1;
    %a=25;
    %a=100;
    prop = 1./(1 + exp(-a*(slope)));
end

% Update function
function M = update(Mnew, i, j, p)
    if rand(1) < p
        Mnew(i, j) = 1;
    end
M = Mnew;
end



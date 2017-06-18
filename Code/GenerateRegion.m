function [ ] = GenerateRegion()
%Function finds distances between plumes and buildings, and 
%defines a region of interest around them. Run this First.

%Calculate distance between plumes and buildings. Any number 
%of buildings and plumes can be added, simply insert x and y 
%coordinates of additional object into appropriate matrix in 
%the form x_cord; y_cord. Ensure both x and y coordinates  
%are given. Results are saved to workspace, then used by the  
%functions "GenerateConcentrationStack" to calculate 
%concentrations in the specified region.

%Ask user to pick a location - Key provided
disp(sprintf(['Please enter a location to view '...
    'concentration \ndata on: 1 = Farm_1, 2 ='...
    'School, 3 = Hospital, 4 = Farm_2']))
%Save user choice as region to investigate
build_choice = input('Building Choice = ');

%Plume positions in format: plume_1_x, plume_1_y; plume_2_x,
%plume_2_y; and so on
Plumes_x_y = [85, 295; 76, 238; 47, 62; 16, 206];

%Building positions in format: building_1_x, building_1_y; 
%building_2_x, building_2_y; and so on. As a key: building_1 
%= Farm 1, building_2 = School, building_3 = Hospital, 
%building_4 = Farm 2
Buildings_x_y = [549, 249; 1053, 203; 1042, 62; 1660, 336];

%Find distances between plumes and buildings
%Matrix to store x_distances - Each row of this matrix is a 
%building, each column is a plume
x_distances=zeros(length(Buildings_x_y),length(Plumes_x_y));
%Matrix to store y_distances - Each row of this matrix is a 
%building, each column is a plume
y_distances=zeros(length(Buildings_x_y),length(Plumes_x_y));

%Statement to work out both x and y distances. First, 
%working out x difference, then y difference
for x_or_y = 1:2
    %x_or_y == 1 means x coordinates are being considered
    if x_or_y == 1
        %Loop through each plume location
        for plume_counter = 1:length(Plumes_x_y)
            %Loop through each building location
            for build_counter = 1:length(Buildings_x_y)
                %Calculate each x distance by doing 
                %building_location - plume_location 
                x_distances(build_counter,plume_counter)...
                    = Buildings_x_y(build_counter,x_or_y)...
                    - Plumes_x_y(plume_counter,x_or_y);            
            %When building has been done for plume, move on
            end
        %Move to next plume
        end
    %After all x distances have been calculated, move on 
    else     
        %Loop through each plume location
        for plume_counter = 1:length(Plumes_x_y)
            %Loop through each building location
            for build_counter = 1:length(Buildings_x_y)
                %Calculate each y distance by doing 
                %building_location - plume_location 
                y_distances(build_counter,plume_counter)... 
                    = Buildings_x_y(build_counter,x_or_y)...
                    - Plumes_x_y(plume_counter,x_or_y); 
            %When building has been done for plume, move on
            end
        %Move to next plume
        end
    %After all y distances have been calculated, finish   
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Dist between buildings and plumes have now been calculated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate an area of interest around each building. Area of 
%interest MUST be a square with given dimensions. NOTE: 
%length is be distance from center of square to center of 
%any side, so total area will be 2*region_length by 
%2*region_length. 71m ==> each side is 142m ==> 
%Area = 5 acres (20164m^2)
region_length = 71;

%Generate matrix to store x limits in for plumes. Each row 
%is a different plume, each column is xmin,xmax
x_lims_region = zeros(length(Plumes_x_y),2);

%Generate matrix to store y limits in for plumes. Each row 
%is a different plume, each column is ymin,ymax
y_lims_region = zeros(length(Plumes_x_y),2);

%Find all plume x and y values for area - how far away is  
%this region from the plume? 
%Loop through x, then preform same calculations for y
for x_or_y = 1:2
    %For the case of the x values
    if x_or_y ==1 
        %Start at plume1, loop through each plume
        for plume_counter = 1:length(Plumes_x_y)
            %Find the max and min x distance of the region.
            %These results are used to find conc values in 
            %each plume's "GenerateConcentrationStack" file
            %1 = min, 2 = max
            for min_or_max = 1:2
                %For the case of a min
                if min_or_max == 1
                    %Update limits matrix with the min_dist
                    x_lims_region(plume_counter,1) = ...
                        x_distances(build_choice,...
                        plume_counter) - region_length;
                %If the min has already been found                 
                else
                    %Update limits matrix with the max_dist
                    x_lims_region(plume_counter,2) = ...
                        x_distances(build_choice,...
                        plume_counter) + region_length;
                %After min or max found, move on
                end
            %After both min and max found move on
            end
        %When all information for plume is found, move on     
        end
    %After all x values found, move on to y
    else
        %Start at plume 1, loop to the max number of plumes
        for plume_counter = 1:length(Plumes_x_y)
            %Find the max and min x distance of the region.
            %These results are used to find conc values in 
            %each plume's "GenerateConcentrationStack" file
            %1 = min, 2 = max
            for min_or_max = 1:2
                %For the case of a min
                if min_or_max == 1
                    %Update limits matrix with the min_dist
                    y_lims_region(plume_counter,1) = ...
                        y_distances(build_choice,...
                        plume_counter) - region_length;
                %If the min has already been found                 
                else
                    %Update limits matrix with the max_dist 
                    y_lims_region(plume_counter,2) = ...
                        y_distances(build_choice,...
                        plume_counter) + region_length;
                %After min or max found, move on
                end
            %After both min and max found move on
            end
        %When all information for plume is found, move on
        end
    %After all y values found, move on   
    end
%After all x and y values for all plumes found, end
end

%Save x and y limit matrices to matlab workspace, to then 
%be used to calcualte concentration in region
assignin('base', ['x_lims_region'], x_lims_region)
assignin('base', ['y_lims_region'], y_lims_region)

%Ask user to run "GeneratePlots" file to generate results 
disp(sprintf(['Region accepted. Now run GeneratePlots',...
    '\n to get results']))
end
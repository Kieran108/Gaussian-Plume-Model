function [] = GenerateConcentrations(x,y,stab_cond,stack_num)
%Generates a matrix with the concentration levels of
%pollutant for specified region, stability condition, stack

%stab_cond determines meterological conditions. Must be  
%a number from 1 to 6. 1=stability class A (very unstable), 
%6 represents=stability class F (stable). x & y should be 
%vectors determined by "GenerateRegion" function. 3 outputs  
%x = downwind distance vector, y=crosswind distance vector,  
%Conc_Stack_?=concentration values. Concentration is  
%calculated using the Gaussian Plume model.

%Generate required x and y limits based on region defined 
%in GenereateRegion mfile. First arg is x_min for region, 
%second is x_max for region, third ensures each point in 
%matrix is 1 meter in length. 
%Downwind distances (m)
x_local = linspace(x(1,1),x(1,2),(x(1,2)-x(1,1)+1));

%Crosswind distances (m)
y_local = linspace(y(1,1),y(1,2),(y(1,2)-y(1,1)+1));

%Initial Conditions
%WindSpeed (m/s)
if stab_cond == 1  
    %Typical for stab cond A 
    Windspeed = 1.75;
elseif stab_cond == 2
    %Typical for stab cond B
    Windspeed = 3;
elseif stab_cond == 3
    %Typical for stab cond C
    Windspeed = 4;
elseif stab_cond == 4
    %Typical for stab cond D
    Windspeed = 6;
elseif stab_cond == 5
    %Typical for stab cond E
    Windspeed = 3.5;
elseif stab_cond == 6
    %Typical for stab cond F
    Windspeed = 2.5; 
end

%Concentration from source (g/s) - Values from scenario
if stack_num == 1
    Conc_source = 0.067;
elseif stack_num == 2
    Conc_source = 0.21;
elseif stack_num == 3
    Conc_source = 0.082;
else
    Conc_source = 0.097;
end

%Height (m) - Values from scenario
if stack_num == 1
    Height = 16;
elseif stack_num == 2
    Height = 70;
elseif stack_num == 3
    Height = 30;
else
    Height = 20;
end

%Height of the boundary layer (m), used for reflection in 
%concentration formula. Not used for conditions E or F
if stab_cond == 1
    %Typical BL height for Stab Cond A
    Height_BL = 1300;
elseif stab_cond == 2
    %Typical BL height for Stab Cond B
    Height_BL = 900;
elseif stab_cond == 3
    %Typical BL height for Stab Cond C
    Height_BL = 850;
else
    %Typical BL height for Stab Cond D
    Height_BL = 800;
end

%Vertical height z (m) - 0 = Ground Level
zGL = 0;

%Stability conditions to loop through order A-F of stability
%Horizontal Stability conditions
SDy = [0.22.*x_local.*((1 + 0.0001*x_local).^(-0.5)); ...
0.16.*x_local.*((1 + 0.0001*x_local).^(-0.5));...
0.11.*x_local.*((1 + 0.0001*x_local).^(-0.5));...
0.08.*x_local.*((1 + 0.0001*x_local).^(-0.5));...
0.06.*x_local.*((1 + 0.0001*x_local).^(-0.5));...
0.04.*x_local.*((1 + 0.0001*x_local).^(-0.5))];
%Vertical Stability conditions
SDz = [0.2.*x_local; 0.12.*x_local; ...
0.08.*x_local.*((1 + 0.0002*x_local).^(-0.5)); ...
0.06.*x_local.*((1 + 0.0015*x_local).^(-0.5)); ...
0.03.*x_local.*((1 + 0.0003*x_local).^(-1)); ...
0.016.*x_local.*((1 + 0.0003*x_local).^(-1))];

%Get the size of the stability matrices into a vector with 
%[num rows, num columns]. Used to know how long to loop for
size_stab_mat = size(SDy);

%Declare matrix to store concentrations in. 1 row for each 
%y value, one column for each x value
Conc_value = zeros(length(y_local),length(x_local));

%Counter used to loop through each value of y
y_var = 1;

%Loops until every row in Conc_value matrix is filled
while y_var <= length(y_local)
    %Set counter to 1 - the column index to use each time  
    %a new row (y value) is considered
    col_index=1;
        while col_index<=size_stab_mat(2)
            %Calculate concentration for Ground Level, 
            %all x values for a single y value per loop
            if stab_cond < 5
                Conc_value(y_var,col_index) = ...
            (Conc_source./(2.*pi.*Windspeed.*...
            SDy(stab_cond,col_index)...
            .*SDz(stab_cond,col_index)))...
            .*exp(-(y_local(1,y_var).^2)./...
            (2.*SDy(stab_cond,col_index).^2)).*...   
            (exp(-((zGL-Height).^2)./...
            (2*SDz(stab_cond,col_index).^2)) ...
            + exp(-((zGL+Height).^2)./...
            (2*SDz(stab_cond,col_index).^2))...
            + exp(-((zGL + (2*Height_BL) - Height).^2)./...
            (2*SDz(stab_cond,col_index).^2))...
            + exp(-((zGL - (2*Height_BL) + Height).^2)./...
            (2*SDz(stab_cond,col_index).^2))...
            + exp(-((zGL - (2*Height_BL) - Height).^2)./...
            (2*SDz(stab_cond,col_index).^2)));
            %If stab cond = E or F, no reflection from 
            %boundary layer
            else
               Conc_value(y_var,col_index) = ...
            (Conc_source./(2.*pi.*Windspeed.*...
            SDy(stab_cond,col_index)...
            .*SDz(stab_cond,col_index)))...
            .*exp(-(y_local(1,y_var).^2)./...
            (2.*SDy(stab_cond,col_index).^2)).*...   
            (exp(-((zGL-Height).^2)./...
            (2*SDz(stab_cond,col_index).^2)) ...
            + exp(-((zGL+Height).^2)./...
            (2*SDz(stab_cond,col_index).^2))); 
            end
            %Update counter to move to next (x) calculation
            col_index = col_index + 1;
        end
   %When all x values are known for selected y, move on
   y_var = y_var + 1;
end

%Save concentration matrix to the workspace for use
%in "GeneratePlots"
assignin('base', ['Conc_Stack_' num2str(stack_num)]...
    , Conc_value)

%Save x and y to workspace to use for plotting 
%in "GeneratePlots"
assignin('base', 'Downwind_Distance', x_local)
assignin('base', 'Crosswind_Distance', y_local)   
end
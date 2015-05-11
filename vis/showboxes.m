function showboxes(im, boxes, out)
% Draw bounding boxes on top of an image.
%   showboxes(im, boxes, out)
%
%   If out is given, a pdf of the image is generated (requires export_fig).

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% Copyright (C) 2007 Pedro Felzenszwalb, Deva Ramanan
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

if nargin > 2
  % different settings for producing pdfs
  print = true;
  %wwidth = 2.25;
  %cwidth = 1.25;
  cwidth = 1.4;
  wwidth = cwidth + 1.1;
  imsz = size(im);
  % resize so that the image is 300 pixels per inch
  % and 1.2 inches tall
  scale = 1.2 / (imsz(1)/300);
  im = imresize(im, scale, 'method', 'cubic');
  %f = fspecial('gaussian', [3 3], 0.5);
  %im = imfilter(im, f);
  boxes = (boxes-1)*scale+1;
else
  print = false;
  cwidth = 2;
end

image(im); 
if print
  truesize(gcf);
end
axis image;
axis off;
% axis([0 640 0 360]);
set(gcf, 'Color', 'white');

if ~isempty(boxes)
  numfilters = floor(size(boxes, 2)/4);
  if print
    % if printing, increase the contrast around the boxes
    % by printing a white box under each color box
    for i = 1:numfilters
      x1 = boxes(:,1+(i-1)*4);
      y1 = boxes(:,2+(i-1)*4);
      x2 = boxes(:,3+(i-1)*4);
      y2 = boxes(:,4+(i-1)*4);
      
      
      % remove unused filters
      del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
      x1(del) = [];
      x2(del) = [];
      y1(del) = [];
      y2(del) = [];
      if i == 1
        w = wwidth;
      else
        w = wwidth;
      end

%      if i ==  13+1 || i == 14+1
%        c = 'k';
%        w = cwidth + 0.5;
%      else
        c = 'w';
%      end

      line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', w);
    end
  end
  % draw the boxes with the detection window on top (reverse order)
  for i = numfilters:-1:1
    x1 = boxes(:,1+(i-1)*4);
    y1 = boxes(:,2+(i-1)*4);
    x2 = boxes(:,3+(i-1)*4);
    y2 = boxes(:,4+(i-1)*4);
    % remove unused filters
    
    %here is where the text file it's being created 
    %it will be extracted in the folder below (where the fileID refers to
    %The steps are like this: 
    % 1) create the 10 x 10 matrix 
    % 2) assign the one's (1) and zero's (0) where the person is found 
    % 3) convert the matrix when all zero's and one's has been assigned, to
    % a vector.
    % 4) export the vector to a text file together with the 1 value
    % indicating that a person has been found, the score is appended later
    % to the text file by the rcnn.m function.
    
    
    % write the coordinates in a text file 
    fileID = fopen('/home/michael/CUT_Drone/matlab_features/matlab_out','w');
    z=1; %its ok from python to read the file
    fprintf(fileID,'%d\n',z);
    % X and Y are the target's coordinates 
    x = (x1 + x2)/2 ;
    y = (y1 + y2)/2 ;
    
    %            STEP 1
    %initialize the matrix with zeros
    matrix_img = zeros(10);
    
    %            STEP 2
    for k = x1:x2
        for j = y1:y2
%             fprintf('K has the value %f\n',x);
%             fprintf('J has the value %f\n',y);
            %find the x pos
            if (k>=0 && k<=64)
                x_pos=1;
            elseif (k>64 && k<=128)
                x_pos=2;
            elseif (k>128 && k<=192)
                x_pos=3;
            elseif (k>192 && k<=256)
                x_pos=4;
            elseif (k>256 && k<=320)
                x_pos=5;
            elseif (k>320 && k<=384)
                x_pos=6;
            elseif (k>384 && k<=448)
                x_pos=7;
            elseif (k>448 && k<=512)
                x_pos=8;
            elseif (k>512 && k<=576)
                x_pos=9;
            else
                x_pos=10;
            end
            
             %find the y pos
            if(j>=0 && j<=36)
                y_pos=1;
            elseif (j>36 && j<=72)
                y_pos=2;
            elseif (j>72 && j<=108)
                y_pos=3;
            elseif (j>108 && j<=144)
                y_pos=4;
            elseif (j>144 && j<=180)
                y_pos=5;
            elseif (j>180 && j<=216)
                y_pos=6;
            elseif (j>216 && j<=252)
                y_pos=7;
            elseif (j>252 && j<=288)
                y_pos=8;
            elseif (j>288 && j<=324)
                y_pos=9;
            else
                y_pos=10;
            end
            
            %assign the 1
            matrix_img(x_pos,y_pos)=1;
        end
    end
   
    %            STEP 3
    %convert the matrix to a vector
    img_vector=reshape(matrix_img,1,[]);
    
    %            STEP 4
    %output the result to the text file exp.txt
    for n = 1:100
        fprintf(fileID,'%d,',img_vector(n));
    end
%     
%     for n = 1:100
%         if n % 10
%             fprintf('\n');
%         end
%         fprintf('%d ',img_vector(n));
%     end
    
    
% we used to print in the text file the coorndinates of 
% center of the object we were looking for 
%     fprintf(fileID,'\n\n\n');
%     fprintf(fileID,'%f;%f;0;0\n',x,y);
    fclose(fileID);
    del = find(((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0)) == 1);
    x1(del) = [];
    x2(del) = [];
    y1(del) = [];
    y2(del) = [];
    if i == 1
      c = 'r'; %[160/255 0 0];
      s = '-';
%    elseif i ==  13+1 || i == 14+1
%      c = 'c';
%      s = '--';
    else
      c = 'b';
      s = '-';
    end
    %draws the bounding box
    line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', cwidth, 'linestyle', s);
    
    %draw an X in the center of the target
    line([x-10 x+10]', [y-10 y+10]', 'color', c, 'linewidth', cwidth, 'linestyle', s);
    line([x+10 x-10]', [y-10 y+10]', 'color', c, 'linewidth', cwidth, 'linestyle', s);
  end
end

% save to pdf
if print
  % requires export_fig from http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig
  export_fig([out]);
end

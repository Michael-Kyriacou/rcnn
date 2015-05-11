function rcnn(dataset_choice, use_gpu)
% rcnn(dataset_choice, use_gpu)
%   Run the R-CNN for human detection only on a test image. Set use_gpu = false to run
%   in CPU mode. (GPU mode is the default.)
%   dataset_choice selects between fine-tuned R-CNN models trained on 
%   'PASCAL' or 'ILSVRC13' 

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

clf;

thresh = -1;

if ~exist('dataset_choice', 'var') || isempty(dataset_choice)
  dataset_choice = 'PASCAL';
end

switch dataset_choice
  case 'PASCAL'
    % PASCAL VOC 2007 fine-tuned detectors (20 classes)
    rcnn_model_file = './data/rcnn_models/voc_2012/rcnn_model_finetuned.mat';
    im = imread('/home/michael/CUT_Drone/raw_data/raw_image.jpg');
  case 'ILSVRC13'
    % ILSVRC13 fine-tuned detectors (200 classes)
    rcnn_model_file = './data/rcnn_models/ilsvrc2013/rcnn_model.mat';
    im = imread('/home/michael/CUT_Drone/raw_data/raw_image.jpg');
  otherwise
    error('unknown dataset ''%s'' [valid options: ''PASCAL'' or ''ILSVRC13'']', dataset_choice);
end

if ~exist(rcnn_model_file, 'file')
  error('You need to download the R-CNN precomputed models. See README.md for details.');
end

if ~exist('use_gpu', 'var') || isempty(use_gpu)
  use_gpu = true;
end

modes = {'CPU', 'GPU'};
fprintf('~~~~~~~~~~~~~~~~~~~\n');
fprintf('Welcome to the %s\n', dataset_choice);
fprintf('Running in %s mode\n', modes{use_gpu+1});

% Initialization only needs to happen once (so this time isn't counted
% when timing detection).
fprintf('Initializing R-CNN model (this might take a little while)\n');
rcnn_model = rcnn_load_model(rcnn_model_file, use_gpu);
fprintf('done\n');

th = tic;
dets = rcnn_detect(im, rcnn_model, thresh);
fprintf('Total %d-class detection time: %.3fs\n', ...
    length(rcnn_model.classes), toc(th));

all_dets = [];
for i = 1:length(dets)
  all_dets = cat(1, all_dets, ...
      [i * ones(size(dets{i}, 1), 1) dets{i}]);
end
%This is the score of the person
%it is initialized to 0.0, in case 
%R-CNN can't detect a human figure,
%the score will stay like this  
person_score = 0.0;

[~, ord] = sort(all_dets(:,end), 'descend');
 %fprintf('%s\n',all_dets(ord(i), 2:5));
check_flag=true;
for i = 1:length(ord)
  score = all_dets(ord(i), end);
  if (score < 0)
    break;
  end
  %here the models has been detected 
  %and are parsed inside the cls object
  cls = rcnn_model.classes{all_dets(ord(i), 1)};
  %here it will check if the class that has
  %been detected, it's the person class
  %becasue we are inside a for loop here,
  %it will continue only if the class is 'person'
  %otherwise the next loop will execute until all
  %loops are done.
  if ~strcmp(cls,'person')
    continue;
   end
  fprintf('cls is : %s\n',cls);
  check_flag=false;
  showboxes(im, all_dets(ord(i), 2:5));
  title(sprintf('det #%d: %s score = %.3f', ...
      i, cls, score));
  person_score = score;
  drawnow;
  pause;
end
%here we use the check_flag bool variable to check
%when the for loop is done, if R-CNN detected a person
%if it did, it will continue to write the 0  
%value inside the text file that has been changed 
%indicating that nothing has been found (humans specifically) 
if check_flag
    fprintf('Nothing found\n');
    % indicate that nothing is found in the text file 
    fileID = fopen('/home/michael/CUT_Drone/matlab_features/matlab_out','w');
    x=0; %it is the null value
    fprintf(fileID,'%d\n',x);
    fclose(fileID);
end
%the score is then printed to the file 
%it will be 0.0 if nothing is found 
%something positive if it has detected 
%a human figure
fprintf('No more detection with score >= 0\n');
fileID = fopen('/home/michael/CUT_Drone/matlab_features/matlab_out','at');
fprintf(fileID,'\n%f',person_score);
fclose(fileID);

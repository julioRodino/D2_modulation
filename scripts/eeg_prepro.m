cd%% RUN EEGLAB
addpath('/home/julio/Documents/eeglab')
run eeglab;

%% Global variables
ch_loc_path = {'/home/julio/Documents/D2_modulation/data/raw/GraceHope.locs','filetype','autodetect'};
ch_elp_path = '/home/julio/Documents/eeglab/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp';
save_path = 'C:/Users/J-RC/Documents/D2_modulation/data/preprocessed/';
data_path = '/home/julio/Documents/D2_modulation/data/raw/';
data_list = dir(append(data_path,'*D2_resting.vhdr'));

%get list of subject numbers
sj_list = zeros(1,length(data_list)); 
for i = 1:length(data_list)
    sj_list(1,i) = str2double(data_list(i,1).name(1:2));
end
sj_list = unique(sj_list);

%% 1.Load to EEGLAB
parfor i = 1:size(data_list,1)
    file = data_list(i,1).name;
    folder = data_list(i,1).folder;
    EEG = pop_loadbv(folder, file);
    EEG = eeg_checkset( EEG );
    EEG.setname = append(file(1:16),'_raw');
    EEG = pop_select( EEG, 'nochannel',{'ECG'});
%% Load Channel loc
    EEG=pop_chanedit(EEG, 'lookup',ch_elp_path,'load',ch_loc_path);

%% Filter
    EEG = pop_eegfiltnew(EEG, 'locutoff',1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',150);
%% Clean Line
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:63] ,'computepower',1,'linefreqs',50,'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
%% Resample
    EEG = pop_resample( EEG, 500);
%% Save
    EEG.setname=append(file(1:16),'_loc_filter.set');
    EEG = pop_saveset( EEG, 'filename',append(file(1:16),'_loc_filter.set'),'filepath',append(save_path,'load_loc_filter'));

end

%% Inspect/Reject data by eye (manual)
run eeglab

%% Reject bad Channels (manual)
run eeglab

%% Interpolate deleted Channles
file_list = dir('/home/julio/Documents/D2_modulation/data/preprocessed/removeCh/*.set');

% Make sure template dataset is dataset 1 in ALLEEG.
template_folder = '/home/julio/Documents/D2_modulation/data/preprocessed/load_loc_filter';
template_file = '01_01_D2_resting_loc_filter.set';
EEG = pop_loadset('filename',template_file, 'filepath', template_folder);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

for i = 1:size(file_list,1)
    file = file_list(i,1).name;
    folder = file_list(i,1).folder;
    EEG = pop_loadset('filepath',folder,'filename',file);
    EEG = eeg_checkset( EEG );
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    % Interpolate based on template dataset
    EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');
    
    % save
    EEG.setname=append(file(1:9),'interpolate_ch.set');
    EEG = pop_saveset( EEG, 'filename',append(file(1:9),'interpolate_ch.set'),'filepath',append(save_path,'interpolated'));


end

%% Re-reference

file_list = dir('/home/julio/Documents/D2_modulation/data/preprocessed/interpolated/*.set');

for i = 1:size(file_list,1)
    file = file_list(i,1).name;
    folder = file_list(i,1).folder;
    EEG = pop_loadset('filepath',folder,'filename',file);
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, []);
    
    % save
    EEG.setname=append(file(1:9),'re_referenced.set');
    EEG = pop_saveset( EEG, 'filename',append(file(1:9),'re_referenced.set'),'filepath',append(save_path,'re_reference'));
end

%% Select epoch

%% RUN ICA

file_list = dir('/home/julio/Documents/D2_modulation/data/preprocessed/interpolated/*.set');

parfor i = 1:size(file_list,1)
    file = file_list(i,1).name;
    folder = file_list(i,1).folder;
    EEG = pop_loadset('filepath',folder,'filename',file);
    EEG = eeg_checkset( EEG );
    
    % 1Hz highpass filtering previous to ICA
    fchp = 1; 
    orderhp = 20000;
    EEG1HZ = pop_eegfiltnew(EEG, [], fchp, orderhp, true, [], 0);
    
    % ICA DECOMPOSITION: ICA N INDEPENDENT COMPONENTS
    n_pca_components = 30;
    EEGfICA = pop_runica(EEG1HZ, 'icatype', 'runica', 'extended', 1, 'pca', n_pca_components);
    %% REPLACE EARLY EEG SET ICA MATRICES WITH THE CALCUATED (1HZ)
    EEG.icaact        = EEGfICA.icaact;
    EEG.icachansind   = EEGfICA.icachansind;
    EEG.icasphere     = EEGfICA.icasphere;
    EEG.icasplinefile = EEGfICA.icasplinefile;
    EEG.icaweights    = EEGfICA.icaweights;
    EEG.icawinv       = EEGfICA.icawinv;
    EEG.setname = append(file(1:9),'ICA.set');
    data_file_name = append(file(1:9),'ICA.set');
    [something, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    EEG = pop_saveset( EEG, 'filename',append(file(1:9),'ICA.set'),'filepath',append(save_path,'ICA'));
    EEG = eeg_checkset(EEG);

   
end

%% Reject components

%% Epoch data
% I changed computers
file_list = dir('C:\Users\J-RC\Documents\D2_modulation\data\preprocessed\rejected_components\*.set');

for i = 1:size(file_list,1)
    file = file_list(i,1).name;
    folder = file_list(i,1).folder;
    EEG = pop_loadset('filepath',folder,'filename',file);
    EEG = eeg_checkset( EEG );
    % Remove boundary elements. No data will be rejected before epoching
    EEG = rm_rejectedDataEvents(EEG);
    % EPOCH
    [EEG, n_noTrigger] = epoch_subject(EEG);
    EEG = eeg_checkset( EEG );
    % Save
    EEG.setname=append(file(1:9),'epoched.set');
    EEG = pop_saveset( EEG, 'filename',append(file(1:9),'epoched.set'),'filepath',append(save_path,'epoched'));
end

%% Custom Function statements
function [EEG,n_noTrigger]=epoch_subject(EEG)
% Epoching for Dopamine modulation experiment
    n_noTrigger = [];
    n_events = size({EEG.event.type},2);
    for n = 1:n_events

       event_type = EEG.event(1,n).type;

       % Describe what happens in each trigger case
       if strcmp(event_type, 'S 64')
           % epoch [0 600]
           EEG = pop_rmdat( EEG, {'S 64'},[0 400] ,0);
           break
       elseif strcmp(event_type, 'S 32')
           % epoch [-600 0]
           EEG = pop_rmdat( EEG, {'S 32'},[-400 0] ,0);
           break
       elseif strcmp(event_type, 'S 96')
           % epoch [-730 -130]
           EEG = pop_rmdat( EEG, {'S 96'},[-530 -130] ,0);
           break
         
       n_noTrigger(end+1) = EEG.setname     %#ok<UNRCH>
       end
    
    end
end

function EEG = rm_rejectedDataEvents(EEG)
    event_types = string({EEG.event.type});
    boundary_logical = find(event_types == "boundary");
    boundary_list = boundary_logical(2:end);
    EEG.event(boundary_list) = [];
end



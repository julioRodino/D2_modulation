% EEGLAB history file generated on the 20-Aug-2021
% ------------------------------------------------

EEG.etc.eeglabvers = '2020.0'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadbv('/home/julio/Documents/D2_modulation/data/raw/', 'D2_01_01_resting.vhdr', [1 887120], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
EEG.setname='01_01';
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/home/julio/Documents/eeglab/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp','load',{'/home/julio/Documents/D2_modulation/data/D2_resting_corrected/GraceHope.locs','filetype','autodetect'});
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'nochannel',{'ECG'});
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/home/julio/Documents/eeglab/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp','load',{'/home/julio/Documents/D2_modulation/data/D2_resting_corrected/GraceHope.locs','filetype','autodetect'});
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',150);
EEG.setname='01_01_loc_filter';
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','0.set','filepath','/home/julio/Documents/D2_modulation/data/preprocessed/');
EEG = eeg_checkset( EEG );

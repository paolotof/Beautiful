function db_filename = expe_to_sql()

addpath('./mksqlite');

options = expe_options();

lst = dir(fullfile(options.result_path, [options.result_prefix, '*.mat']));
files = { lst.name };

db_filename = fullfile(options.result_path, [options.result_prefix, 'db.sqlite']);

db = mksqlite('open', db_filename);

mksqlite('PRAGMA journal_mode=OFF');

%-- Tables creation

mksqlite('DROP TABLE IF EXISTS thr');
mksqlite(['CREATE TABLE IF NOT EXISTS thr '...
          '('...
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
          'subject TEXT, '...
          'ref_f0 REAL, '...
          'dir_f0 REAL, '...
          'ref_ser REAL, '...
          'dir_ser REAL, '...
          'ref_voice TEXT, '...
          'dir_voice TEXT, '...
          'vocoder INTEGER, '...
          'vocoder_name TEXT, '...
          'vocoder_description TEXT, '...
          'threshold FLOAT, '...
          'threshold_f0 FLOAT, '...
          'threshold_ser FLOAT, '...
          'sd FLOAT, '....
          'response_datetime TEXT, '...
          'i INTEGER'...
          ')']);
     
%-----------------------

% which_threshold = 'last_3_tp';
which_threshold = 'all';

%-- Fill the tables
for i=1:length(files)
    
    disp(sprintf('=====> Processing %s...', files{i}));
    
    load(fullfile(options.result_path, files{i}));
    
    phase = 'test';

    for ic=1:length(results.(phase).conditions)
        
        c = results.(phase).conditions(ic);
            
        a = c.att(end);
        
        if isfield(a, 'threshold') && ~isnan(a.threshold)
            
            t = a.responses(1).trial;
            
            r = struct();

            r.subject = options.subject_name;

            r.ref_f0 = options.(phase).voices(t.ref_voice).f0;
            r.dir_f0 = options.(phase).voices(t.dir_voice).f0;
            r.ref_ser = options.(phase).voices(t.ref_voice).ser;
            r.dir_ser = options.(phase).voices(t.dir_voice).ser;
            r.ref_voice = options.(phase).voices(t.ref_voice).label;
            r.dir_voice = options.(phase).voices(t.dir_voice).label;
            
            r.vocoder = t.vocoder;
            if r.vocoder>0
                r.vocoder_name = options.vocoder(r.vocoder).label;
                r.vocoder_description = options.vocoder(r.vocoder).description;
            end    
            
            switch which_threshold
                case 'last_3_tp'
                    i_nz = find(a.steps~=0);
                    i_d  = find(diff(sign(a.steps(i_nz)))~=0);
                    i_tp = i_nz(i_d)+1;
                    i_tp = [i_tp, length(a.differences)];
                    i_tp = i_tp(end-2:end);

                    r.threshold = mean(a.differences(i_tp));

                case 'last_2_tp'
                    i_nz = find(a.steps~=0);
                    i_d  = find(diff(sign(a.steps(i_nz)))~=0);
                    i_tp = i_nz(i_d)+1;
                    i_tp = [i_tp, length(a.differences)];
                    i_tp = i_tp(end-1:end);

                    r.threshold = mean(a.differences(i_tp));

                otherwise
                    i_tp = a.diff_i_tp;
                    r.threshold = a.threshold;
            end
            
            u_f0  = 12*log2(options.(phase).voices(t.dir_voice).f0 / options.(phase).voices(t.ref_voice).f0);
            u_ser = 12*log2(options.(phase).voices(t.dir_voice).ser / options.(phase).voices(t.ref_voice).ser);
            u = [u_f0, u_ser];
            u = u / sqrt(sum(u.^2));
            
            r.threshold_f0 = r.threshold*u(1);
            r.threshold_ser = r.threshold*u(2);
            
            r.response_datetime = datestr(a.responses(1).timestamp, 'yyyy-mm-dd HH:MM:SS');
            r.sd = a.sd;
            r.i = ic;

            mksqlite_insert(db, 'thr', r);
        end
        
    end

end




mksqlite(db, 'close');

expe_sql_add_individual_data();

rmpath('./mksqlite');

%==========================================================================
function md = md5(msg)

MD = java.security.MessageDigest.getInstance('md5');
md = typecast(MD.digest(uint8(msg)), 'uint8');
md = lower(reshape(dec2hex(md)', 1, []));

%==========================================================================
function md = md5_file(filename)

fid = fopen(filename, 'r');
md = md5(fread(fid));
fclose(fid);


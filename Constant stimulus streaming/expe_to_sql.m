function db_filename = expe_to_sql()

addpath('./mksqlite');

options = expe_options();

lst = dir(fullfile(options.result_path, [options.result_prefix, '*.mat']));
files = { lst.name };

db_filename = fullfile(options.result_path, [options.result_prefix, 'db.sqlite']);

db = mksqlite('open', db_filename);

mksqlite('PRAGMA journal_mode=OFF');

%-- Tables creation
mksqlite('DROP TABLE IF EXISTS subject');
mksqlite(['CREATE TABLE IF NOT EXISTS subject '...
          '('...
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
          'name TEXT, '...
          'birthdate TEXT, '...
          'result_file TEXT, '...
          'result_file_hash TEXT, '...
          'feeding_date TEXT,'...
          'subject_group INT, '...
          'matched_pair INT' ...
          ')']);

mksqlite('DROP TABLE IF EXISTS block');
mksqlite(['CREATE TABLE IF NOT EXISTS block '...
          '('...
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
          'id_subject INT, '...
          'type TEXT, '...
          'block_date TEXT'...
          ')']);

mksqlite('DROP TABLE IF EXISTS response');
mksqlite(['CREATE TABLE IF NOT EXISTS response '...
          '('...
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
          'id_block INTEGER, '...
          'subject TEXT, '...
          'subject_group INT, '...
          'matched_pair INT, '...
          'block_type TEXT, '...
          'target_speaker TEXT, '...
          'target_colour TEXT, '...
          'target_number INTEGER, '...
          'target_call_sign TEXT, '...
          'masker_type TEXT, '...
          'masker_speaker TEXT, '...
          'masker_colour TEXT, '...
          'masker_number INTEGER, '...
          'masker_call_sign TEXT, '...
          'tmr FLOAT, '...
          'attenuation FLOAT, '...
          'correct FLOAT, '...
          'error_type TEXT, '...
          'error_type_num INT, '...
          'response_colour TEXT, '...
          'response_number INT, '...
          'visual_feedback INT, '...
          'audio_feedback INT, '...
          'pause_when_wrong INT, '...
          'response_time FLOAT, '...
          'response_datetime TEXT, '...
          'i_repeat INT, '...
          'i INT'...
          ')']);
     
%-----------------------

expe_group();

%-- Fill the tables
for i=1:length(files)
    
    disp(sprintf('=====> Processing %s...', files{i}));
    
    name = strrep(strrep(strrep(strrep(files{i}, options.result_prefix, ''), '.mat', ''), 'pre', ''), '.1', '');
    
    switch name
        case group1
            group = 1;
        case group0
            group = 0;
        otherwise
            error('%s isn''t in any group!', files{i});
    end
    
    for k=1:length(group1)
        if strcmp(name, subject_pairs{k, 2-group})
            mpair_number = k;
            break
        end
    end
    
    hash = md5_file(fullfile(options.result_path, files{i}));
    %res = mksqlite(db, sprintf('SELECT id FROM subject WHERE  result_file="%s" AND result_file_hash="%s"', files{i}, hash));
    mksqlite(db, sprintf('INSERT INTO subject (name, result_file, result_file_hash, feeding_date, subject_group, matched_pair) VALUES ("%s", "%s", "%s", DATETIME(), %d, %d)', name, files{i}, hash, group, mpair_number));
    res = mksqlite(db, 'SELECT LAST_INSERT_ROWID() AS id_subject');
    id_subject = res.id_subject;
    % mksqlite(db, sprintf('UPDATE subject SET name="%s", feeding_date=DATETIME() WHERE id=%d', name, res.id));
    
    load(fullfile(options.result_path, files{i}));
    
    %{
    if ~strcmp(name, options.subject_name)
        warning(sprintf('The result file is named "%s" while the subject name in the file is "%s". The name of the file was used.', name, options.subject_name));
    end
    %}
    
    % Test & psych
    phases = fieldnames(results);
    
    for ip=1:length(phases)
        phase = phases{ip};
        
        mksqlite(db, sprintf('INSERT INTO block (id_subject, type) VALUES (%d, "%s")', id_subject, phase));
        res = mksqlite(db, 'SELECT LAST_INSERT_ROWID() AS id_block');
        id_block = res.id_block;

        for j=1:length(results.(phase).responses)
            resp = results.(phase).responses(j);

            r = struct();
            r.id_block = id_block;
            r.subject = name;
            r.subject_group = group;
            r.matched_pair = mpair_number;
            r.block_type = phase;

            % Filling target and masker info
            if resp.trial.tmr<Inf
                tms = {'target', 'masker'};
                r.masker_type = resp.trial.masker.type;
            else
                % There's no masker
                tms = {'target'};
                r.masker_type = 'none';
            end
            for tm=tms
                r.(sprintf('%s_colour', tm{1})) = resp.(sprintf('info_%s', tm{1})).color;
                r.(sprintf('%s_number', tm{1})) = resp.(sprintf('info_%s', tm{1})).number;
                r.(sprintf('%s_call_sign', tm{1})) = resp.(sprintf('info_%s', tm{1})).call_sign;
                r.(sprintf('%s_speaker', tm{1})) = resp.(sprintf('info_%s', tm{1})).talker;
            end
            
            % Other general information
            for k={'visual_feedback', 'audio_feedback', 'i_repeat', 'pause_when_wrong'}
                r.(k{1}) = resp.trial.(k{1});
            end
            
            if ~isinf(resp.trial.tmr)
                r.tmr = resp.trial.tmr;
            else
                if resp.trial.tmr==Inf
                    r.tmr = '+Inf';
                elseif resp.trial.tmr==-Inf
                    r.tmr = '-Inf';
                end
            end
            r.attenuation = options.attenuation_dB;
            
            r.response_colour = resp.color;
            r.response_number = resp.number;
            r.correct = resp.correct;
            r.response_time = resp.response_time;
            r.response_datetime = datestr(resp.timestamp, 31);
            
            r.i = j;
            
            %--- Error types
            
            if strcmp(r.masker_type, 'speech')
                % Dropped both
                if ((resp.color_index~=resp.info_target.color_index) && (resp.number~=resp.info_target.number)) && (resp.color_index~=resp.info_masker.color_index) && (resp.number~=resp.info_masker.number)
                    r.error_type_num = 0;
                    r.error_type = 'dropped both';
                % Dropped one
                elseif ((resp.color_index~=resp.info_target.color_index) || (resp.number~=resp.info_target.number)) && ((resp.color_index~=resp.info_masker.color_index) && (resp.number~=resp.info_masker.number))
                    r.error_type_num = 1;
                    r.error_type = 'dropped one';
                % All masker
                elseif (resp.color_index==resp.info_masker.color_index) && (resp.number==resp.info_masker.number)
                    r.error_type_num = 2;
                    r.error_type = 'masker';
                % Mix
                elseif (resp.color_index==resp.info_masker.color_index) || (resp.number==resp.info_masker.number)
                    r.error_type_num = 3;
                    r.error_type = 'mixed';
                % Correct
                elseif resp.correct==1
                    r.error_type_num = 4;
                    r.error_type = 'correct';
                else
                    warning('Shouldn''t see that...');
                    resp
                    resp.info_masker
                    resp.info_target
                end
            else
                r.error_type_num = NaN;
                r.error_type = NaN;
            end
           
            mksqlite_insert(db, 'response', r);
        end
    end

end

%-------------------------------------
% Create and fill summary table

mksqlite('DROP TABLE IF EXISTS summary');
sql = ['CREATE TABLE IF NOT EXISTS summary '...
          '('...
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
          'subject TEXT, subject_group INT, '];

res = mksqlite(db, 'SELECT tmr FROM response WHERE block_type=''test'' AND masker_type=''speech-shape-noise'' GROUP BY tmr');
tmrs = [res.tmr];
for tmr = tmrs
    sql = [sql, strrep(sprintf('`ssn_tmr%d` FLOAT, ', tmr), '-', '_')];
end

res_et = mksqlite(db, 'SELECT error_type FROM response WHERE block_type=''test'' AND masker_type=''speech'' GROUP BY error_type');
for i=1:length(res_et)
    sql = [sql, sprintf('`error_%s` FLOAT, ', strrep(res_et(i).error_type, ' ', '_'))];
end
sql = [sql, 'speech FLOAT, p_sp_re_tmr1 FLOAT, p_sp_re_tmr2 FLOAT)'];

mksqlite(db, sql);

res_block = mksqlite(db, 'SELECT block.id, name, subject_group FROM block, subject WHERE type=''test'' AND subject.id=block.id_subject');

for i=1:length(res_block)
    
    id_block = res_block(i).id;
    name = res_block(i).name;
    
    r = struct();
    r.subject = name;
    r.subject_group = res_block(i).subject_group;
    for i_tmr=1:length(tmrs)
        res = mksqlite(db, sprintf('SELECT AVG(correct=1) AS score FROM response WHERE id_block=%d AND masker_type=''speech-shape-noise'' AND tmr=%d', id_block, tmrs(i_tmr)));
        r.(strrep(sprintf('ssn_tmr%d', tmrs(i_tmr)), '-', '_')) = res.score;
    end
    
    res = mksqlite(db, sprintf('SELECT AVG(correct=1) AS score FROM response WHERE id_block=%d AND masker_type=''speech''', id_block));
    r.speech = res.score;
    
    for i_et=1:length(res_et)
        et = res_et(i_et).error_type;
        res = mksqlite(db, sprintf('SELECT AVG(error_type=''%s'') AS prop FROM response WHERE id_block=%d AND masker_type=''speech''', et, id_block));
        r.(sprintf('error_%s', strrep(et, ' ', '_'))) = res.prop;
    end
    
    mksqlite_insert(db, 'summary', r);
end

% Comparisons to TMR1 and TMR2
res = mksqlite(db, 'SELECT id, ssn_tmr_12, ssn_tmr_4, speech FROM summary');

for i=1:length(res)
    [~, p1] = ttest(abs([res.ssn_tmr_12]-res(i).speech), abs([res.ssn_tmr_4]-res(i).speech), 0.05, 'right'); % Sp closer to T2
    [~, p2] = ttest(abs([res.ssn_tmr_12]-res(i).speech), abs([res.ssn_tmr_4]-res(i).speech), 0.05, 'left'); % Sp closer to T1
    mksqlite(db, sprintf('UPDATE summary SET p_sp_re_tmr1=%f, p_sp_re_tmr2=%f WHERE id=%d', p1, p2, res(i).id));
end


mksqlite(db, 'close');

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


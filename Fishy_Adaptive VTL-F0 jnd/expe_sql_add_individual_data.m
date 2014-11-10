function db_filename = expe_sql_add_individual_data()

%addpath('./mksqlite');

options = expe_options();

db_filename = fullfile(options.result_path, [options.result_prefix, 'db.sqlite']);
db = mksqlite('open', db_filename);
mksqlite('PRAGMA journal_mode=OFF');

%-- Tables creation

mksqlite('DROP TABLE IF EXISTS subject');
mksqlite(['CREATE TABLE IF NOT EXISTS subject '...
          '('...
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
          'subject TEXT, '...
          'date_of_birth DATE, '...
          'age REAL, '...
          'sex TEXT, '...
          'date_of_implantation DATE, '...
          'brand TEXT, '...
          'device TEXT, '...
          'implant TEXT, '...
          'processor TEXT, '...
          'strategy TEXT, '...
          'ear TEXT,'...
          'stimulation_rate REAL, '...
          'missing_electrodes INTEGER'...
          ')']);

d = struct();
i = 0;

i = i+1;
d(i).subject = 'S01';
d(i).date_of_birth = '1966-12-13';
d(i).sex = 'm';
d(i).date_of_implantation = '';
d(i).brand = 'AB';
d(i).device = '';
d(i).implant = '';
d(i).strategy = '';
d(i).processor = '';
d(i).stimulation_rate = 0;
d(i).missing_electrodes = 0;
d(i).ear = '';

i = i+1;
d(i).subject = 'S02';
d(i).date_of_birth = '1958-03-24';
d(i).sex = 'm';
d(i).date_of_implantation = '2009-02-12';
d(i).brand = 'AB';
d(i).device = 'HR90K';
d(i).implant = 'HiRes 90K HiFocus 1J';
d(i).strategy = 'HiRes-S';
d(i).processor = 'Harmony';
d(i).stimulation_rate = 1160;
d(i).missing_electrodes = 0;
d(i).ear = 'R';

i = i+1;
d(i).subject = 'S03';
d(i).date_of_birth = '1957-04-09';
d(i).sex = 'm';
d(i).date_of_implantation = '2001-04-12';
d(i).brand = 'Cochlear';
d(i).device = 'CI24M';
d(i).implant = 'CI24R k';
d(i).strategy = 'ACE';
d(i).processor = 'CP810';
d(i).stimulation_rate = 1200;
d(i).missing_electrodes = 0;
d(i).ear = 'L';

i = i+1;
d(i).subject = 'S04';
d(i).date_of_birth = '1951-04-08';
d(i).sex = 'm';
d(i).date_of_implantation = '2001-10-23';
d(i).brand = 'Cochlear';
d(i).device = 'CI422';
d(i).implant = 'CI24R CS';
d(i).strategy = 'MP3000';
d(i).processor = 'CP900';
d(i).stimulation_rate = 900;
d(i).missing_electrodes = 0;
d(i).ear = 'L';

i = i+1;
d(i).subject = 'S05';
d(i).date_of_birth = '1951-02-14';
d(i).sex = 'f';
d(i).date_of_implantation = '2002-06-25';
d(i).brand = 'Cochlear';
d(i).device = 'CI24RE';
d(i).implant = 'CI24RE CA';
d(i).strategy = 'ACE';
d(i).processor = 'CP810';
d(i).stimulation_rate = 900;
d(i).missing_electrodes = 0;
d(i).ear = 'L';

i = i+1;
d(i).subject = 'S06';
d(i).date_of_birth = '1945-05-25';
d(i).sex = 'f';
d(i).date_of_implantation = '2008-09-18';
d(i).brand = 'Cochlear';
d(i).device = 'CI24RE';
d(i).implant = 'CI24RE CA';
d(i).strategy = 'ACE';
d(i).processor = 'Freedom';
d(i).stimulation_rate = 900;
d(i).missing_electrodes = 0;
d(i).ear = 'L';

i = i+1;
d(i).subject = 'S07';
d(i).date_of_birth = '1964-02-26';
d(i).sex = 'f';
d(i).date_of_implantation = '2010-11-05';
d(i).brand = 'Cochlear';
d(i).device = 'CI24RE';
d(i).implant = 'CI24RE CA';
d(i).strategy = 'MP3000';
d(i).processor = 'CP810';
d(i).stimulation_rate = 900;
d(i).missing_electrodes = 0;
d(i).ear = 'R';

i = i+1;
d(i).subject = 'S08';
d(i).date_of_birth = '1940-04-24';
d(i).sex = 'm';
d(i).date_of_implantation = '2007-01-11';
d(i).brand = 'AB';
d(i).device = 'HR90K';
d(i).implant = 'HiRes 90K Helix';
d(i).strategy = 'HiRes-S';
d(i).processor = 'Naida CI Q70';
d(i).stimulation_rate = 2900;
d(i).missing_electrodes = 0;
d(i).ear = 'R';


i = i+1;
d(i).subject = 'S09';
d(i).date_of_birth = '1942-03-10';
d(i).sex = 'm';
d(i).date_of_implantation = '2006-11-28';
d(i).brand = 'AB';
d(i).device = 'HR90K';
d(i).implant = 'HiRes 90K Helix';
d(i).strategy = 'HiRes-S';
d(i).processor = 'Naida Q70';
d(i).stimulation_rate = 2900;
d(i).missing_electrodes = 0;
d(i).ear = 'R';

i = i+1;
d(i).subject = 'S10';
d(i).date_of_birth = '1964-05-11';
d(i).sex = 'f';
d(i).date_of_implantation = '2002-03-21';
d(i).brand = 'Cochlear';
d(i).device = 'CI24R';
d(i).implant = 'CI24R CS';
d(i).strategy = 'ACE';
d(i).processor = 'CP810';
d(i).stimulation_rate = 1800;
d(i).missing_electrodes = 2;
d(i).ear = 'R';

i = i+1;
d(i).subject = 'S11';
d(i).date_of_birth = '1958-07-10';
d(i).sex = 'f';
d(i).date_of_implantation = '2001-06-19';
d(i).brand = 'Cochlear';
d(i).device = 'CI24M';
d(i).implant = 'CI24R k';
d(i).strategy = 'ACE';
d(i).processor = 'CP810';
d(i).stimulation_rate = 1200;
d(i).missing_electrodes = 0;
d(i).ear = 'R';

%{
i = i+1;
d(i).subject = '';
d(i).date_of_birth = '';
d(i).sex = '';
d(i).date_of_implantation = '';
d(i).brand = '';
d(i).device = '';
d(i).implant = '';
d(i).strategy = '';
d(i).processor = '';
d(i).stimulation_rate = ;
d(i).missing_electrodes = ;
d(i).ear = '';
%}


for i=1:length(d)
    mksqlite_insert(db, 'subject', d(i));
end

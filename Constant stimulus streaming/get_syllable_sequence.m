function [sylls, proposed_sylls] = get_syllable_sequence(syll_list, n_syll, rep_min_index, rep_max_index, n_proposed)

v = randperm(length(syll_list));
v = v(1:n_syll-1);
iRep = randi([rep_min_index, rep_max_index]);
v = [v(1:iRep), v(iRep), v(iRep+1:end)];
sylls = syll_list(v);

vp = v(rep_min_index:rep_max_index+1);
vp = vp(vp~=v(iRep));
vp = vp(randperm(length(vp)));
vp = [v(iRep), vp(1:n_proposed-1)];
proposed_sylls = syll_list(vp);


function tr_lst = tr_syllables(lst)

tr_lst = {};
for i=1:length(lst)
    ts_lst{i} = tr(lst{i});
end

%----------------------------------
function ns = tr(s)


ns = s;

#!/usr/bin/env python
# -*- coding: utf-8 -*-

from numpy import *
from scipy import *
from matplotlib import pylab
from sqlShort import sqlShort

db = sqlShort(host='results/jvo_db.sqlite', type='sqlite')

ref_voices, ref_f0s, ref_sers = db.query("""
	SELECT ref_voice, ref_f0, ref_ser
	FROM thr GROUP BY ref_voice
	ORDER BY ref_voice DESC
	""")

subject_clause = ' '

voices = dict()
for ref_voice, ref_f0, ref_ser in zip(ref_voices, ref_f0s, ref_sers):
	voices[ref_voice] = (ref_f0, ref_ser)

#subject_clause = " AND subject='S01b' "

cm = array([[207, 82, 10], [237, 186, 70], [78, 164, 38], [25, 112, 176], [149, 38, 138], [250, 90, 0], [200, 0, 0], [0, 150, 255], [158, 204, 59], [54, 102, 255]])/255.

cols = {'female': cm[0], 'male': cm[3], 'child': cm[2]}
lw = 2

fig = pylab.figure()
ax  = fig.add_axes((.12, .1, .8, .8))

dashes = (6,3,2,3)

for ref_voice in ref_voices:
	
	col = cols[ref_voice]
	
	ref_f0, ref_ser, dir_f0, dir_ser, thr_f0, thr_ser, thr, se_thr = db.query("""
		SELECT ref_f0, ref_ser, dir_f0, dir_ser,
			AVG(threshold_f0) AS thr_f0, AVG(threshold_ser) AS thr_ser, AVG(threshold) AS thr,
			STD(threshold)/SQRT(COUNT(*)) AS se_thr
		FROM thr
		WHERE ref_voice='%s' %s
		GROUP BY dir_f0, dir_ser
		""" % (ref_voice, subject_clause),
		array=True)
	
	u = log2(dir_f0 / ref_f0) + 1j * log2(dir_ser / ref_ser)
	a = angle(u)
	a[a>=pi] += -2*pi
	u = u/abs(u)

	ix = argsort(a)

	dir_f0 = 12*log2(dir_f0[ix]/ref_f0[ix])
	dir_ser = 12*log2(dir_ser[ix]/ref_ser[ix])
	thr_f0 = thr_f0[ix]
	thr_ser = thr_ser[ix]
	se = se_thr[ix]
	thr = thr[ix]
	u = u[ix]
	
	dx = 12*log2(ref_f0[0]  / voices['female'][0])
	dy = 12*log2(ref_ser[0] / voices['female'][1])
	
	ax.axhline(y=dy, dashes=dashes, color=col*.3+.7, lw=.75, zorder=-1)
	ax.axvline(x=dx, dashes=dashes, color=col*.3+.7, lw=.75, zorder=-1)
    
	for j in range(len(dir_f0)):
		ax.plot(thr_f0[j]+se[j]*array([-1, 1])*real(u[j])+dx, thr_ser[j]+se[j]*array([-1, 1])*imag(u[j])+dy, '-o', color=col, ms=4, mfc='none', mec=col*.7)

	s = ((dir_f0==0) & (dir_ser>0)) | ((dir_f0<0) & (dir_ser==0))
	ax.plot(thr_f0[s]+dx, thr_ser[s]+dy, '-', color=col*.5+.5, lw=lw, dashes=(2,2))

	s = ((dir_f0==0) & (dir_ser<0)) | ((dir_f0>0) & (dir_ser==0))
	ax.plot(thr_f0[s]+dx, thr_ser[s]+dy, '-', color=col*.5+.5, lw=lw, dashes=(2,2))

	s = (dir_f0>=0) & (dir_ser>=0)
	ax.plot(thr_f0[s]+dx, thr_ser[s]+dy, '-o', color=col, lw=lw, mec=col*.5, ms=7)

	s = (dir_f0<=0) & (dir_ser<=0)
	ax.plot(thr_f0[s]+dx, thr_ser[s]+dy, '-o', color=col, lw=lw, mec=col*.5, ms=7, label=ref_voice)
    


ax.legend(loc='upper left', prop={'size': 11})
ax.set_ylabel("1/VTL (semitones re. reference)")
ax.set_xlabel("F0 (semitones re. reference)")

#ax.set_yticks(range(-14, 10, 2))
#ax.set_xticks(range(-8, 9, 2))

ax.set_xlim([-13, 6])
xlim = ax.get_xlim()
ylim = ax.get_ylim()
dx = xlim[1]-xlim[0]
dy = ylim[1]-ylim[0]
s = .4
fig.set_size_inches(dx*s, dy*s)
fig.savefig("Results_ref.png", dpi=200, format="png")
fig.savefig("Results_ref.eps", format="eps")



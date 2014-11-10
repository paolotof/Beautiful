#!/usr/bin/env python
# -*- coding: utf-8 -*-

from numpy import *
from scipy import *
from matplotlib import pylab
from sqlShort import sqlShort

cm = array([[207, 82, 10], [237, 186, 70], [78, 164, 38], [25, 112, 176], [149, 38, 138], [250, 90, 0], [200, 0, 0], [0, 150, 255], [158, 204, 59], [54, 102, 255]])/255.

#cols = {'female': cm[0], 'male': cm[3], 'child': cm[2]}
cols = {'NH': cm[2], 'CI': cm[3], 'AB': cm[3], 'Cochlear': cm[1]}
lw = 2

dbd = dict()
dbd['CI'] = sqlShort(host='results/jvo_db.sqlite', type='sqlite')
dbd['NH'] = sqlShort(host='/Users/egaudrain/Experiments/2013-J-VO GPR-VTL jnd/2013-05-07 - Exp.1 - Resolution/results/jvo_db.sqlite', type='sqlite')

fig = pylab.figure()
ax  = fig.add_axes((.12, .1, .8, .8))

xTickLabel = list()
ciVal = list()

for k in dbd.keys():
	
	print k
	
	db = dbd[k]

	ref_voices, ref_f0s, ref_sers = db.query("""
		SELECT ref_voice, ref_f0, ref_ser
		FROM thr
		WHERE ref_voice='female' 
		GROUP BY ref_voice
		ORDER BY ref_voice DESC
		""")
	
	if k=='NH':
		subject_clause = ' AND vocoder=0 '
	else:
		subject_clause = '  '

	#subject_clause = " AND subject='S01b' "

	dashes = (6,3,2,3)
	#ax.axhline(y=0, dashes=dashes, color=ones(3)*.7, lw=.75)
	#ax.axvline(x=0, dashes=dashes, color=ones(3)*.7, lw=.75)

	for ref_voice in ref_voices:
	
		col = cols[k]
	
		if k=='NH':
		
			subject_clause = "  AND vocoder=0  AND thr.subject!='S13' "
			
			ref_f0, ref_ser, dir_f0, dir_ser, thr_f0, thr_ser, thr, se_thr = db.query("""
				SELECT ref_f0, ref_ser, dir_f0, dir_ser,
					AVG(threshold_f0) AS thr_f0, AVG(threshold_ser) AS thr_ser, AVG(threshold) AS thr,
					STD(threshold)/SQRT(COUNT(*)) AS se_thr
				FROM thr
				WHERE ref_voice='%s' %s
					AND (dir_voice='male-gpr' OR dir_voice='child-gpr')
				-- GROUP BY dir_f0, dir_ser
				""" % (ref_voice, subject_clause),
				array=True)
		
			ax.bar([0-.4], thr, yerr=se_thr, color=cols[k], edgecolor=cols[k]/2., ecolor=cols[k]/2.)
			xTickLabel.append('NH')
			
		else:
			
			subj, = db.query("SELECT subject FROM subject ORDER BY brand")
			for i_subj, subj in enumerate(subj):
				subject_clause = ' AND subject="%s" ' % subj
				
				ref_f0, ref_ser, dir_f0, dir_ser, thr_f0, thr_ser, thr, se_thr = db.query("""
					SELECT ref_f0, ref_ser, dir_f0, dir_ser,
						AVG(threshold_f0) AS thr_f0, AVG(threshold_ser) AS thr_ser, AVG(threshold) AS thr,
						STD(threshold)/SQRT(COUNT(*)) AS se_thr
					FROM thr
					WHERE ref_voice='%s' %s
						AND (dir_voice='male-gpr' OR dir_voice='child-gpr')
					-- GROUP BY dir_f0, dir_ser
					""" % (ref_voice, subject_clause),
					array=True)
				
				brand, = db.query("SELECT brand FROM subject WHERE subject='%s'" % subj)
				k = brand[0]
		
				ax.bar([i_subj+1-.4], thr, color=cols[k], edgecolor=cols[k]/2., ecolor=cols[k]/2.)
				xTickLabel.append('CI%d' % (int(subj[1:])))
				ciVal.extend(thr)
	

ax.plot([1-.4, len(xTickLabel)-1+.4], ones(2)*mean(ciVal), '--', color=cols['CI']/2.)
ax.axhline(12, ls='-', color=ones(3)*.8, zorder=-1)

#ax.legend(loc='upper left', prop={'size': 11})
ax.set_ylabel("F0 jnd (st)")
#ax.set_xlabel("F0 (semitones re. reference)")
ax.set_xticks(range(0,len(xTickLabel)))
ax.set_xticklabels(xTickLabel)
ax.set_xlim([-.75, len(xTickLabel)-.25])

ylim = ax.get_ylim()
ax.set_ylim([ylim[0], ylim[1]+1])

#ax.set_yticks(range(-14, 10, 2))
#ax.set_xticks(range(-8, 9, 2))

#ax.set_xlim([-6.5, 6.5])
#xlim = ax.get_xlim()
#ylim = ax.get_ylim()
#dx = xlim[1]-xlim[0]
#dy = ylim[1]-ylim[0]
#s = .4

s = 2

fig.set_size_inches(8.5/2.54*s, 8.5/2.54*.67*s)
fig.savefig("Results_bar_f0.png", dpi=300, format="png")
fig.savefig("Results_bar_f0.pdf", format="pdf")



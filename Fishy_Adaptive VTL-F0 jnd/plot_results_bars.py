#!/usr/bin/env python
# -*- coding: utf-8 -*-

from numpy import *
from scipy import *
from matplotlib import pylab
from sqlShort import sqlShort

cm = array([[207, 82, 10], [237, 186, 70], [78, 164, 38], [25, 112, 176], [149, 38, 138], [250, 90, 0], [200, 0, 0], [0, 150, 255], [158, 204, 59], [54, 102, 255]])/255.

#cols = {'female': cm[0], 'male': cm[3], 'child': cm[2]}
#cols = {'NH': cm[2], 'CI': cm[3], 'AB': cm[3], 'Cochlear': cm[1]}
cols = {'NH': cm[2], 'CI': cm[3], 'AB': cm[3], 'Cochlear': cm[3]}
lw = 2

dbd = dict()
dbd['CI'] = sqlShort(host='results/jvo_db.sqlite', type='sqlite')
dbd['NH'] = sqlShort(host='/Users/egaudrain/Experiments/2013-J-VO GPR-VTL jnd/2013-05-07 - Exp.1 - Resolution/results/jvo_db.sqlite', type='sqlite')

dirs = [('male-vtl', 'child-vtl'), ('male',), ('male-gpr', 'child-gpr')]

fig = pylab.figure()


for i_dir, dir in enumerate(dirs):

	ax  = fig.add_axes((.12, .1+.8*(1-(i_dir+1.)/len(dirs)), .8, .8/len(dirs)))
	xTickLabels = list()
	xTicks = list()
	ciVal = list()

	for k in dbd.keys():
	
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
			
			for i_idir, idir in enumerate(dir):
				
				print k, idir, ref_voice
				
				sw = 1.
				w = .8/len(dir)
			
				if k=='NH':
		
					subject_clause = "  AND vocoder=0  AND thr.subject!='S13' "
			
					thr, = db.query("""
						SELECT AVG(threshold)
						FROM thr
						WHERE ref_voice='%s' %s
							AND (dir_voice='%s')
						GROUP BY subject
						""" % (ref_voice, subject_clause, idir),
						array=True)
		
					ax.bar([(i_idir-len(dir)/2.)*w], mean(thr), yerr=std(thr)/sqrt(len(thr)), width=w, color=cols[k], edgecolor=cols[k]/2., ecolor=cols[k]/2.)
					if i_idir==0:
						xTicks.append(0)
						xTickLabels.append('NH')
					
					print k, dir, mean(thr)
					print thr
			
				else:
			
					subj, = db.query("SELECT subject FROM thr WHERE dir_voice='male-vtl' GROUP BY subject ORDER BY AVG(threshold)")
					for i_subj, subj in enumerate(subj):
						subject_clause = ' AND subject="%s" ' % subj
				
						thr, = db.query("""
							SELECT threshold
							FROM thr
							WHERE ref_voice='%s' %s
								AND (dir_voice='%s')
							-- GROUP BY dir_f0, dir_ser
							""" % (ref_voice, subject_clause, idir),
							array=True)
				
						#brand, = db.query("SELECT brand FROM subject WHERE subject='%s'" % subj)
						#k = brand[0]
		
						ax.bar([(i_subj+1)*sw+(i_idir-len(dir)/2.)*w], mean(thr), width=w,  color=cols[k], edgecolor=cols[k]/2., ecolor=cols[k]/2.)
						ax.plot(ones(len(thr))*((i_subj+1)*sw+(i_idir-len(dir)/2.)*w)+w/2., thr, 'o', color=(1,1,1), mec=cols[k]/2., ms=3, zorder=10)
						ciVal.extend(thr)
						
						if i_idir==0:
							xTicks.append((i_subj+1)*sw)
							xTickLabels.append('CI%d' % (int(subj[1:])))
				
	
	title = dir[0].split('-')[-1].replace('gpr', 'f0')
	if title=='male':
		title = 'Man'
	else:
		title = title.upper()
	
	#ax.text(0, 5, title)

	ax.plot([min(xTicks[1:])-sw/2., max(xTicks[1:])+sw/2.], ones(2)*mean(ciVal), '--', color=cols['CI']/2.)
	if title=='VTL':
		ax.axhline(3.6, ls='-', color=ones(3)*.8, zorder=-1)
	elif title=='F0':
		ax.axhline(12, ls='-', color=ones(3)*.8, zorder=-1)
	elif title=='Man':
		ax.axhline(sqrt(12**2+3.6**2)/2., ls='-', color=ones(3)*.8, zorder=-1)
	
	print 'CI', dir, mean(ciVal)

	#ax.legend(loc='upper left', prop={'size': 11})
	ax.set_ylabel("%s JND (st)" % title)
	#ax.set_xlabel("F0 (semitones re. reference)")
	ax.set_xticks(xTicks)
	ax.set_xticklabels(xTickLabels)
	ax.set_xlim([min(xTicks)-.8, max(xTicks)+.8])
	ylim = ax.get_ylim()
	if i_dir>0:
				ax.set_ylim([ylim[0], ylim[1]-.1])

#ax.set_yticks(range(-14, 10, 2))
#ax.set_xticks(range(-8, 9, 2))

#ax.set_xlim([-6.5, 6.5])
#xlim = ax.get_xlim()
#ylim = ax.get_ylim()
#dx = xlim[1]-xlim[0]
#dy = ylim[1]-ylim[0]
#s = .4

s = 2.3

fig.set_size_inches(8.5/2.54*s, 8.5/2.54*1.4*s)
fig.savefig("Results_bars.png", dpi=300, format="png")
fig.savefig("Results_bars.pdf", format="pdf")



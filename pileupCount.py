import os,sys,csv

def writecsv(fname,matrix):
    with open(fname,"wb") as fileOut:
        writer=csv.writer(fileOut)
        writer.writerows(matrix)

#thqual = 20
#thmapqMax = 60
#args = [0,patho,fin,fOut,thqual,thmapqMax]

args=sys.argv
fin=os.path.join(args[1],args[2])
thqual = int(args[3])
thmapqMax = int(args[4])

for thmapq in range(0,thmapqMax+10,10): 
    fpileup=open(fin,"r")
    fOut=os.path.join(args[1],args[2][:-7]+"_"+args[3]+"_"+str(thmapq)+".csv")
    stats = [["seq","pos","cov","afterFilt","ref","A","C","G","T","First","Second","Third","Forth"]]
    for line in fpileup:
        stat = [0]*10
        line=line.strip().split("\t")
        seq=line[0]
        pos=line[1]
        ref=line[2]
        cov = int(line[3])
        bases = list(line[4][1:]); #print (line)
        for i in range(len(bases)): 
            if bases[i]=="." or bases[i]==",":
                bases[i]=ref
        qual = map(ord,list(line[5][1:]))
        qual = [x-33 for x in qual]; #print (qual)
        mapq = map(ord,list(line[6][1:]))
        mapq = [x-33 for x in mapq]; #print (mapq)
        basesFin = [bases[i] for i in range(len(bases)) if qual[i]>thqual and mapq[i]>thmapq]; #print (basesFin)
        acgt = map(basesFin.count,["A","C","G","T"])
        totalIn = sum([acgt[0],acgt[1],acgt[2],acgt[3]]) 
        acgtsort=sorted([acgt[0],acgt[1],acgt[2],acgt[3]])
        acgtsort = acgtsort[::-1]
        if totalIn>0:
            acgtsort=[round(float(x)/totalIn,2) for x in acgtsort]
        stat = [seq,pos,len(bases),totalIn,ref,acgt[0],acgt[1],acgt[2],acgt[3]]+acgtsort
        stats = stats + [stat]
        
    writecsv(fOut,stats)
    cmd = "Rscript ~/MyScripts/MinorVar/codePlot.r" + " " + fOut + " " + args[3] + " " + str(thmapq)
    print cmd
    os.system(cmd)	

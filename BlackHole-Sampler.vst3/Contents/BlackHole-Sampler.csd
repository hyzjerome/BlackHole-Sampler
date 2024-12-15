<Cabbage> bounds(0, 0, 0, 0)
form caption("Untitled") size(800, 300), guiMode("queue"), pluginId("def1"), colour(0,0,0)

soundfiler bounds(254, 14, 503, 222), channel("soundfiler1")
image bounds(16, 20, 237, 200) channel("sampleSlot1") file("BH.JPG")
button bounds(138, 250, 38, 35) channel("sampleSlotPlay1"), text("PAD", "PAD")
checkbox   bounds(14, 242, 116, 52), channel("PlayStop"), text("Play/Stop"), , fontColour:0(255, 162, 8, 255) fontColour:1(255, 162, 8, 255) colour:1(156, 88, 0, 255)
label bounds(20, 194, 229, 20), text("DND to the blackhole") channel("sampleSlotLabel1") fontColour(255, 162, 8, 255)

rslider bounds(612, 238, 60, 60) channel("Reverb") range(0, 5, 0, 0.5, 0.001), text("Reverb") textColour(46, 46, 238, 255) trackerColour(46, 46, 238, 255)
rslider bounds(188, 234, 60, 60) channel("Level") range(0, 5, 1, 0.5, 0.001), text("Level") textColour(255, 162, 8, 255) trackerColour(255, 162, 8, 255)

combobox bounds(324, 256, 130, 25), populate("*.snaps"), channelType("string") automatable(0) channel("combo104") value("1") 
filebutton bounds(260, 256, 60, 25), text("Save", "Save"), populate("*.snaps", "test"), mode("named preset") channel("filebutton105")
filebutton bounds(458, 256, 60, 25), text("Remove", "Remove"), populate("*.snaps", "test"), mode("remove preset") channel("filebutton106")

vmeter bounds(764, 50, 10, 160) channel("vu1")  outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0, 255) meterColour:1(255, 255, 0, 255) meterColour:2(0, 255, 0, 255)
vmeter bounds(782, 50, 10, 160) channel("vu2")  outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0, 255) meterColour:1(255, 255, 0, 255) meterColour:2(0, 255, 0, 255)


</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 --midi-key=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
ksmps = 32
nchnls = 2
0dbfs = 1

garvbL init 0
garvbR init 0


instr SampleSlot
 iSlotNumber = p4
 SChannel sprintf "sampleSlot%d", iSlotNumber
 kBounds[] cabbageGet SChannel, "bounds"
 kX chnget "MOUSE_X"
 kY chnget "MOUSE_Y"
 
 SFile, kFileChanged cabbageGet "LAST_FILE_DROPPED"
 SCurrentWidget, kWidgetChanged cabbageGet "CURRENT_WIDGET"
 
 if kFileChanged == 1 then
    if kX > kBounds[0] && kX < kBounds[0]+kBounds[2] && kY > kBounds[1] && kY < kBounds[1]+kBounds[3] then
cabbageSet kFileChanged, "soundfiler1", "file", SFile
chnset SFile, "sampleSlot1_file"

endif
endif


kPlayStop cabbageGetValue "PlayStop"
if changed(kPlayStop) == 1 then
if kPlayStop == 1 then
 event "i", 1, 0, 10000000000, 60+iSlotNumber-1
 elseif kPlayStop == 0 then
 turnoff2 1, 0, 1
endif
endif

kButton, kButtonTrig cabbageGetValue "sampleSlotPlay1"
if changed(kButtonTrig) == 1 then
if kButtonTrig == 1 then
event "i", 1, 0, 10000000000, 60+iSlotNumber-1
endif
endif

endin


instr 1

   
 print p4
 
 gklevel    chnget    "Level"
 
 SFile sprintf "sampleSlot%d_file", (p4-60)+1 
 
 aL,aR diskin2 chnget:S(SFile), 1, 0, 1

outs aL*gklevel, aR*gklevel
    
    k1 rms aL*gklevel, 20
    k2 rms aR*gklevel, 20
    
    cabbageSetValue "vu1", portk(k1*10, .25), metro(10)
    cabbageSetValue "vu2", portk(k2*10, .25), metro(10)	

krvb chnget "Reverb"

vincr garvbL, aL*krvb
vincr garvbR, aR*krvb
endin

instr verb
	denorm garvbL, garvbR
aLmix, aRmix freeverb garvbL, garvbR, 0.9, 0.4, sr, 0
	outs aLmix, aRmix
	clear garvbL, garvbR
endin
</CsInstruments>
<CsScore>
i"SampleSlot" 0 z 1 8
i "verb" 0 1000000000
;causes Csound to run for about 7000 years...
f0 z
</CsScore>
</CsoundSynthesizer>

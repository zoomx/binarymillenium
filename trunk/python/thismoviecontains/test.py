# binarymillenium 
# september 2009
# GNU GPL 3.0
#
# generate an MPAA warning logo
import Image, ImageFont, ImageDraw

def getlinepts(x1,y1, x2, y2):
    # don't understand how draw.line tuples work at all, just experimented
    # until I was able to draw a box
    linepts = [
                (x1,y1), (x2,y1),
                (x2,y2), 
                
                (x2,y2), (x1,y2),
                (x2,y2), (x1,y2),
                
                #(x2,y1), (x2,y2),
                
                (x1,y2), (x1,y1),

              ]
    return linepts

def addText(xoff,yoff,txt,font,fgcolor):
    draw.text((xoff+2,yoff+3), txt, fill="#000000", font=font)
    draw.text((xoff,yoff), txt, fill=fgcolor, font=font)


def addTextBold(xoff,yoff,txt,font,fgcolor):
    draw.text((xoff +2 + 0,yoff+3+0), txt, fill="#000000", font=font)
    draw.text((xoff +2 + 0,yoff+3+1), txt, fill="#000000", font=font)
    draw.text((xoff +2 + 1,yoff+3+0), txt, fill="#000000", font=font)
    draw.text((xoff +2 + 1,yoff+3+1), txt, fill="#000000", font=font)
    
    draw.text((xoff + 0,yoff+0), txt, fill=fgcolor, font=font)
    draw.text((xoff + 0,yoff+1), txt, fill=fgcolor, font=font)
    draw.text((xoff + 1,yoff+0), txt, fill=fgcolor, font=font)
    draw.text((xoff + 1,yoff+1), txt, fill=fgcolor, font=font)

ht = 360 #720

ht = 360 #720
wd = 640 #1280

bgcolor = "#089931"  #standard green
image  = Image.new("RGB", (wd,ht), bgcolor)
draw = ImageDraw.Draw(image)

fgcolor = "#f4fdf6"

fontFile = "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf"
font = ImageFont.truetype(fontFile,16)
fontBig = ImageFont.truetype(fontFile,20)

txt1 = "THE FOLLOWING" 
txt2 = " PREVIEW "
txt3 = "HAS BEEN APPROVED FOR"
(x1,y1) = font.getsize(txt1)
(x2,y2) = fontBig.getsize(txt2)
(x3,y3) = font.getsize(txt3)

addText(    wd/2-(x1+x2+x3)/2,30,txt1,font,fgcolor)
addTextBold(wd/2-(x1+x2+x3)/2+x1,30-4,txt2,fontBig,fgcolor)
addText(    wd/2-(x1+x2+x3)/2+x1+x2,30,txt3,font,fgcolor)

txt = "ALL AUDIENCES"
(x,y) = fontBig.getsize(txt)
addTextBold(wd/2-x/2,58,txt,fontBig,fgcolor)

txt = "BY THE MOTION PICTURE ASSOCIATION OF AMERICA"
(x,y) = font.getsize(txt)
addText(wd/2-x/2,90,txt,font,fgcolor)

txt = "THE FILM ADVERTISED HAS BEEN RATED"
(x,y) = font.getsize(txt)
addText(wd/2-x/2,ht/2-25,txt,font,fgcolor)

ulx = wd/2-wd/3*0.9 
uly = ht/2
lrx = wd/2+wd/3*0.9
lry = ht/2+90

# pg 13
txt = "PARENTS STRONGLY CAUTIONED"
(x,y) = font.getsize(txt)
addText(ulx+64,uly+4,txt,font,fgcolor)

fontSmall = ImageFont.truetype(fontFile,13)

# TBD text for R film
txt = "TROMA-INSPIRED GROTESQUENESS,"
(x,y) = font.getsize(txt)
addText(wd/2-x/2,uly+43,txt,font,fgcolor)

txt = "AND SPASTIC HUMOR"
(x,y) = font.getsize(txt)
addText(wd/2-x/2,uly+63,txt,font,fgcolor)



# shadows
draw.line( getlinepts(ulx+2,uly+2,lrx+2,lry+2) , width=2, fill="#000000")
# rating box
draw.line( getlinepts(ulx+2,uly+2,ulx+60+2,uly+26+2) , width=2, fill="#000000")
# parents cautioned box
draw.line( getlinepts(ulx+60+2,uly+2,lrx+2,uly+26+2) , width=2, fill="#000000")
# some material box
draw.line( getlinepts(ulx+2,uly+26+2,lrx+2,uly+42+2) , width=2, fill="#000000")

# center at 
lgx = lrx-23
lgy = uly+12
draw.ellipse( ((lgx-18, lgy-8),(lgx+18,lgy+8)), outline=fgcolor)
draw.ellipse( ((lgx-14, lgy-8),(lgx+14,lgy+8)), outline=fgcolor)
draw.line(    ((lgx-18, lgy),  (lgx+18,lgy)), fill=fgcolor)
draw.ellipse( ((lgx-8, lgy-8),(lgx+8,lgy+8)), fill=fgcolor,outline=fgcolor)

draw.ellipse( ((lgx, lgy),(lgx+7,lgy+7)), fill="#000000") #,outline=fgcolor)
draw.ellipse( ((lgx-7, lgy),(lgx,lgy+7)), fill="#000000") #,outline=fgcolor)
draw.ellipse( ((lgx-7, lgy-7),(lgx,lgy)), fill="#000000") #,outline=fgcolor)
draw.ellipse( ((lgx, lgy-7),(lgx,lgy)), fill="#000000") #,outline=fgcolor)

txt = "Some Material May Be Inappropriate for Children Under 13"
(x,y) = fontSmall.getsize(txt)
addText(wd/2-x/2,uly+26,txt,fontSmall,fgcolor)

# Rating- century schoolboy?
fontFileRating = "/var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType/DejaVuSerif-Bold.ttf"
#fontFileRating = "/var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType/FreeSerifBold.ttf"
fontRating = ImageFont.truetype(fontFileRating,16)

txt = "PG-13"
(x,y) = fontRating.getsize(txt)
addTextBold(ulx+3,uly+2,txt,fontRating,fgcolor)


# white lines
draw.line( getlinepts(ulx,uly,ulx+60,uly+26) , width=2, fill=fgcolor)
draw.line( getlinepts(ulx+60,uly,lrx,uly+26) , width=2, fill=fgcolor)
draw.line( getlinepts(ulx,uly+26,lrx,uly+42) , width=2, fill=fgcolor)
draw.line( getlinepts(ulx,uly,lrx,lry) , width=2, fill=fgcolor)


image.save("out.png","PNG")

#!/usr/bin/env python3
"""Menu de Dungeon Shop en pixel art HD (480x270) v4. Rework segun critica artistica:
profundidad (suelo en perspectiva + props distribuidos y escalados), iluminacion por
zonas (base oscura + focos), objeto ICONICO (balanza antigua sobre pedestal bajo haz),
techo con vigas/lamparas/banderas, e historia de la abuela (retrato, reloj parado,
silla gastada, carta, planta, herramientas)."""
from PIL import Image, ImageDraw
import os
REPO = "/workspace/dungeonshop"; UI = os.path.join(REPO, "assets", "ui")
W, H = 480, 270

WALL=[(38,26,17),(50,34,22),(64,44,28),(80,56,35)]
FLOOR=[(58,38,22),(80,52,30),(104,68,38),(134,90,52)]
CWOOD=[(38,25,14),(56,36,20),(78,50,28)]
DWOOD=[(24,16,10),(38,26,16),(54,36,22)]
STONE=[(56,52,47),(80,75,68),(108,102,93),(146,139,127)]
METAL=[(66,76,88),(116,128,142),(174,186,198),(226,234,242)]
GOLD=[(112,84,24),(170,128,38),(220,176,62),(248,224,140)]
BLUE=[(24,64,120),(40,110,180),(96,168,230),(176,220,252)]
GRN=[(20,80,40),(40,130,66),(90,180,110),(170,230,190)]
FIRE=[(120,26,10),(210,64,20),(255,130,36),(255,196,80),(255,244,170)]
SKY=[(22,30,52),(34,46,72),(50,68,98),(70,92,122)]
LEAF=[(28,58,30),(52,104,52),(84,150,78),(122,190,108)]
RUG=[(70,24,32),(112,40,52),(150,58,70),(184,96,110)]
REDB=(150,58,58); BLUEB=(70,90,150); K=(20,13,9)

def new(w,h): return Image.new("RGBA",(w,h),(0,0,0,0))
def F(d,x,y,w,h,c): d.rectangle([x,y,x+w-1,y+h-1],fill=c)
def dither_v(d,x,y,w,h,r):
    n=len(r); b=max(1,h//n)
    for i in range(n):
        F(d,x,y+i*b,w,b+(h-b*n if i==n-1 else 0),r[i])
        if i<n-1:
            yy=y+(i+1)*b
            for xx in range(x,x+w):
                if (xx+yy)%2==0: d.point((xx,yy-1),fill=r[i+1])
def panel(d,x,y,w,h,r,outline=True,ao=True):
    m=len(r)//2; F(d,x,y,w,h,r[m]); F(d,x,y,w,2,r[-1]); F(d,x,y,2,h,r[min(len(r)-1,m+1)])
    F(d,x,y+h-2,w,2,r[0]); F(d,x+w-2,y,2,h,r[max(0,1)])
    if outline: d.rectangle([x,y,x+w-1,y+h-1],outline=K)
    if ao: F(d,x,y+h,w,1,(0,0,0,80))
def grain(d,x,y,w,h,r,step=6):
    for yy in range(y+2,y+h-1,step):
        for xx in range(x+1,x+w-1):
            if (xx+yy)%7<2: d.point((xx,yy),fill=r[0])
def glow(img,cx,cy,rx,ry,col):
    g=new(W,H); ImageDraw.Draw(g).ellipse([cx-rx,cy-ry,cx+rx,cy+ry],fill=col); img.alpha_composite(g)

def potion(d,x,y,r):
    F(d,x+2,y,3,2,DWOOD[1]); panel(d,x,y+2,7,9,r,ao=False); F(d,x+1,y+5,5,2,(255,255,255,40))
def helmet(d,x,y):
    d.pieslice([x,y,x+12,y+14],180,360,fill=METAL[1]); d.pieslice([x+1,y+1,x+11,y+13],180,360,fill=METAL[2])
    F(d,x,y+7,13,3,METAL[1]); F(d,x+3,y+8,7,2,K); F(d,x+5,y,3,4,METAL[3])
def ore(d,x,y,c):
    d.polygon([(x,y+8),(x+4,y+2),(x+9,y+3),(x+12,y+9),(x+7,y+13),(x+2,y+12)],fill=c); d.polygon([(x+4,y+2),(x+7,y+7),(x+2,y+8)],fill=METAL[3])
def ring(d,x,y):
    d.ellipse([x,y+3,x+7,y+10],outline=GOLD[2]); d.ellipse([x+1,y+4,x+6,y+9],outline=GOLD[1]); F(d,x+2,y,3,3,(79,208,200))
def barrel(d,x,y,w,h):
    panel(d,x,y,w,h,[(56,36,20),(94,60,32),(128,84,46)])
    F(d,x,y+2,w,3,METAL[1]); F(d,x,y+h-6,w,3,METAL[1])
    for xx in range(x+3,x+w-1,5): F(d,xx,y,1,h,(56,36,20))
    d.ellipse([x,y-3,x+w-1,y+5],fill=(108,72,40)); d.ellipse([x+2,y-2,x+w-3,y+3],fill=(78,50,28))
def chest(d,x,y,w,h):
    panel(d,x,y+h//3,w,h-h//3,[(58,38,20),(96,62,32),(128,84,46)])
    d.pieslice([x,y,x+w-1,y+2*(h//3)],180,360,fill=(84,54,28)); d.pieslice([x+1,y+1,x+w-2,y+2*(h//3)-1],180,360,fill=(112,74,40))
    F(d,x,y+h//3,w,3,METAL[0]); F(d,x+w//2-3,y+h//3-2,6,8,GOLD[1]); d.point((x+w//2,y+h//3+2),fill=GOLD[3])
def crate(d,x,y,s):
    panel(d,x,y,s,s,[(58,38,20),(98,66,36),(132,90,50)])
    d.line([x+2,y+2,x+s-3,y+s-3],fill=(58,38,20)); d.line([x+s-3,y+2,x+2,y+s-3],fill=(58,38,20))
def armor_stand(d,x,y):
    F(d,x+7,y+34,4,10,DWOOD[0]); d.ellipse([x+2,y+42,x+16,y+48],fill=DWOOD[1])
    panel(d,x,y+12,18,22,METAL,ao=False)
    d.polygon([(x,y+12),(x+9,y+8),(x+18,y+12),(x+18,y+18),(x,y+18)],fill=METAL[2])
    F(d,x+8,y+16,2,14,METAL[0]); helmet(d,x+3,y-2)
def portrait(d,x,y):
    panel(d,x,y,20,24,GOLD); F(d,x+3,y+3,14,18,(58,44,60))
    d.ellipse([x+6,y+7,x+14,y+16],fill=(214,186,150)); d.pieslice([x+5,y+4,x+15,y+13],180,360,fill=(210,210,214))
    F(d,x+6,y+15,8,5,(120,80,90))
def clock(d,x,y):
    d.ellipse([x,y,x+18,y+18],fill=DWOOD[1]); d.ellipse([x+2,y+2,x+16,y+16],fill=(224,214,190))
    d.line([x+9,y+9,x+9,y+4],fill=K); d.line([x+9,y+9,x+13,y+11],fill=K); d.point((x+9,y+9),fill=K)
def chair(d,x,y):
    panel(d,x,y+10,16,4,[(48,32,18),(78,52,28),(100,68,38)])
    F(d,x+1,y+14,3,10,DWOOD[1]); F(d,x+12,y+14,3,10,DWOOD[1])
    F(d,x+1,y-6,3,16,DWOOD[1]); F(d,x+4,y-4,9,3,DWOOD[2]); F(d,x+4,y+1,9,3,DWOOD[2])
def plant(d,x,y):
    panel(d,x,y,14,12,[(120,72,40),(150,92,52),(180,116,66)])
    for lx,ly,r,c in ((x+7,y-9,8,LEAF[1]),(x+1,y-5,6,LEAF[0]),(x+13,y-5,6,LEAF[2]),(x+7,y-15,6,LEAF[2])):
        d.ellipse([lx-r,ly-r,lx+r,ly+r],fill=c)
    d.ellipse([x+3,y-12,x+11,y-4],fill=LEAF[3])
def balance(d,img,cx,y):
    F(d,cx-3,y,6,50,GOLD[1]); F(d,cx-3,y,2,50,GOLD[2]); F(d,cx-2,y+2,4,2,GOLD[3])
    d.polygon([(cx,y-8),(cx+5,y-1),(cx-5,y-1)],fill=GOLD[2]); d.ellipse([cx-3,y-14,cx+3,y-8],fill=(79,208,200))
    F(d,cx-30,y+4,60,3,GOLD[2]); F(d,cx-30,y+4,60,1,GOLD[3]); d.ellipse([cx-2,y+3,cx+2,y+7],fill=GOLD[3])
    for sx in (cx-28,cx+28):
        for cyy in range(y+7,y+18,3): d.point((sx+2,cyy),fill=GOLD[0]); d.point((sx-2,cyy),fill=GOLD[0])
        d.pieslice([sx-8,y+16,sx+8,y+26],0,180,fill=GOLD[1]); d.pieslice([sx-8,y+15,sx+8,y+24],0,180,fill=GOLD[2])
        d.arc([sx-8,y+16,sx+8,y+26],0,180,fill=GOLD[3])
    glow(img,cx,y+8,26,30,(255,224,140,26))
def pedestal(d,x,y,w,h):
    panel(d,x-4,y+h-6,w+8,8,STONE); panel(d,x,y,w,h,STONE)
    for yy in range(y+3,y+h-3,5): F(d,x+2,yy,w-4,1,STONE[0])
    panel(d,x-3,y-5,w+6,6,STONE,ao=False)
def exterior(d,img,x,y,w,h):
    dither_v(d,x,y,w,h,SKY); d.ellipse([x+w-14,y+5,x+w-6,y+13],fill=(214,222,236))
    for i in range(x+2,x+w,3):
        if (i*7)%11==0: d.point((i,y+4+(i%5)),fill=(200,210,230))
    base=y+h-9
    for hx,hh,c in ((x+3,14,SKY[2]),(x+13,20,(46,60,92)),(x+26,16,SKY[2]),(x+38,22,(42,56,88)),(x+50,15,SKY[2])):
        if hx+11>x+w: continue
        F(d,hx,base-hh,11,hh,c); d.polygon([(hx-1,base-hh),(hx+5,base-hh-6),(hx+11,base-hh)],fill=(58,48,64))
        F(d,hx+3,base-hh+4,3,3,(255,204,120))
    F(d,x+22,base-14,2,10,(40,30,26)); d.ellipse([x+17,base-24,x+29,base-10],fill=(36,64,46))
    lx=x+w-12; F(d,lx,base-16,2,14,(44,44,52)); d.ellipse([lx-3,base-20,lx+5,base-12],fill=(255,200,110))
    glow(img,lx+1,base-16,13,13,(255,200,110,46))
    for yy in range(base,y+h,3):
        for xx in range(x,x+w,5): F(d,xx+(yy%2)*2,yy,3,2,(56,56,64))
    F(d,x+w//2,y,1,h,DWOOD[0]); F(d,x,y+h//2,w,1,DWOOD[0])
def apply_lighting(img, lights, base=118, tint=(10,7,14)):
    mask=Image.new('L',(W,H),base); mpx=mask.load()
    for (cx,cy,rad,strength,ry) in lights:
        y0=max(0,int(cy-rad*ry)); y1=min(H,int(cy+rad*ry)); x0=max(0,cx-rad); x1=min(W,cx+rad)
        for yy in range(y0,y1):
            for xx in range(x0,x1):
                dx=(xx-cx)/rad; dy=(yy-cy)/(rad*ry); dsq=dx*dx+dy*dy
                if dsq<1.0:
                    red=int(strength*(1.0-dsq))
                    if red>0:
                        v=mpx[xx,yy]; mpx[xx,yy]=0 if red>v else v-red
    ov=Image.new('RGBA',(W,H),(*tint,0)); ov.putalpha(mask); img.alpha_composite(ov)

def scene():
    img=new(W,H); d=ImageDraw.Draw(img)
    F(d,0,0,W,30,(26,18,12))
    for bx in range(0,W,64): F(d,bx,0,10,30,DWOOD[1]); F(d,bx,0,10,2,DWOOD[2])
    F(d,0,26,W,4,DWOOD[0])
    dither_v(d,0,30,W,92,WALL)
    for yy in range(30,122,12):
        F(d,0,yy,W,1,WALL[0])
        for xx in range(0,W):
            if (xx+yy)%9<1: d.point((xx,yy+1),fill=WALL[3])
    panel(d,0,118,W,6,DWOOD,outline=False,ao=False)
    dither_v(d,0,124,W,146,FLOOR)
    vp=(240,120)
    for fx in range(-40,W+40,26): d.line([fx,270,vp[0]+(fx-vp[0])//6,126],fill=FLOOR[0])
    yy=132
    while yy<270: F(d,0,yy,W,1,FLOOR[1]); yy+=int((yy-118)*0.14)+3
    F(d,70,150,26,2,FLOOR[0]); F(d,70,150,2,10,FLOOR[0]); F(d,300,146,22,2,FLOOR[0])
    dw,dh=94,124; dx=W//2-dw//2; dy=32
    panel(d,dx-8,dy-8,dw+16,dh+12,DWOOD); d.pieslice([dx-8,dy-26,dx+dw+8,dy+26],180,360,fill=DWOOD[1]); F(d,dx,dy,dw,dh,(48,32,17))
    gx,gy,gw,gh=dx+8,dy+6,dw-16,80
    exterior(d,img,gx,gy,gw,gh); d=ImageDraw.Draw(img)
    F(d,gx+6,gy+gh-14,12,6,(34,30,40)); d.ellipse([gx+6,gy+gh-10,gx+11,gy+gh-5],fill=(24,22,30)); d.ellipse([gx+13,gy+gh-10,gx+18,gy+gh-5],fill=(24,22,30))
    d.rectangle([gx,gy,gx+gw-1,gy+gh-1],outline=DWOOD[0])
    panel(d,dx+8,dy+92,dw-16,dh-98,CWOOD); d.ellipse([dx+dw-18,dy+108,dx+dw-11,dy+115],fill=GOLD[2])
    bx=dx+dw//2; F(d,bx-1,dy-26,2,6,DWOOD[0]); d.pieslice([bx-6,dy-23,bx+6,dy-12],180,360,fill=GOLD[1]); F(d,bx-6,dy-13,12,2,GOLD[2])
    for wx in (30,384):
        panel(d,wx-5,25,66,42,DWOOD); exterior(d,img,wx,30,56,32); d=ImageDraw.Draw(img); panel(d,wx-8,68,72,6,DWOOD,ao=False)
    # Estanterias DEBAJO de la ventana izquierda (sin solaparla), bien surtidas.
    for sy in (86,106):
        panel(d,14,sy,80,4,[(58,38,20),(92,60,30),(124,84,44)],ao=False); F(d,14,sy+4,80,2,DWOOD[0])
    for i,px in enumerate((18,28,38,48)): potion(d,px,75,[BLUE,GRN][i%2])
    helmet(d,60,72); ore(d,78,74,GOLD[2])
    for i,bx2 in enumerate((18,22,26,30,34,38,42,46,50,54)): F(d,bx2,98,3,7,[REDB,(40,130,66),BLUEB,(150,120,60)][i%4])
    ring(d,68,99)
    portrait(d,136,44)         # retrato de la abuela (zona libre a la izq de la puerta)
    clock(d,384,82)            # reloj parado (junto a la chimenea, sin tocar la ventana)
    for wx in (300,312): F(d,wx,44,3,22,METAL[1]); F(d,wx-3,64,9,3,GOLD[2])
    fx,fy,fw,fh=406,120,70,150
    panel(d,fx,fy-46,fw,fh,STONE)
    for yy in range(fy-46,fy+90,10):
        for xx in range(fx,fx+fw,16): F(d,xx+((yy//10)%2)*8,yy,15,9,STONE[1]); d.rectangle([xx+((yy//10)%2)*8,yy,xx+((yy//10)%2)*8+15,yy+9],outline=STONE[0])
    panel(d,fx-7,fy-54,fw+14,10,STONE,ao=False)
    F(d,fx+14,fy-24,fw-28,80,(16,11,8)); panel(d,fx+18,fy+40,fw-36,8,DWOOD,ao=False)
    cxp=fx+fw//2
    for j,col in enumerate(FIRE[1:]): d.polygon([(cxp-14+3*j,fy+46),(cxp,fy-14+7*j),(cxp+14-3*j,fy+46)],fill=col)
    barrel(d,148,206,18,30); barrel(d,176,152,12,20); chest(d,364,224,32,26); crate(d,120,152,18)
    armor_stand(d,338,150)
    panel(d,40,224,70,8,[(58,38,20),(98,66,36),(132,90,50)]); F(d,44,232,6,22,DWOOD[1]); F(d,100,232,6,22,DWOOD[1])
    potion(d,48,214,BLUE); helmet(d,64,210); F(d,84,216,14,8,BLUEB); F(d,84,216,14,2,GOLD[2])
    pedestal(d,224,196,32,44); balance(d,img,240,150); d=ImageDraw.Draw(img)
    d.polygon([(206,244),(274,244),(258,150),(222,150)],fill=RUG[1]); d.polygon([(214,240),(266,240),(254,156),(226,156)],fill=RUG[2])
    for yy in range(158,242,10): F(d,222-(242-yy)//6,yy,36+(242-yy)//3,2,GOLD[2])
    for lx in (128,356): F(d,lx,0,2,20,(50,50,56)); panel(d,lx-5,20,12,14,DWOOD,ao=False); F(d,lx-3,23,8,8,(255,200,110))
    for bxx,col in ((160,(120,42,52)),(320,(46,74,120))):   # banderas flanqueando la puerta (zonas libres)
        d.polygon([(bxx,30),(bxx+20,30),(bxx+20,56),(bxx+10,50),(bxx,56)],fill=col)
        d.polygon([(bxx+6,37),(bxx+14,37),(bxx+10,45)],fill=GOLD[2]); d.ellipse([bxx+8,33,bxx+12,37],fill=(79,208,200))
    cy=250
    panel(d,0,cy,W,270-cy,CWOOD,outline=False); F(d,0,cy,W,3,(150,100,52)); F(d,0,cy+3,W,2,(120,78,40))
    grain(d,0,cy+5,W,270-cy-5,CWOOD,step=7)
    for xx in range(0,W,52): F(d,xx,cy+4,1,270-cy-4,DWOOD[0])
    chair(d,20,cy-16); plant(d,120,cy-12)
    F(d,250,cy-8,16,7,(224,214,190)); F(d,252,cy-6,12,1,(150,120,90))   # carta de la abuela
    F(d,300,cy-4,4,4,(90,70,40)); F(d,299,cy-6,6,3,METAL[1])            # herramienta vieja
    F(d,344,cy-9,4,11,(235,225,200)); F(d,345,cy-13,2,4,FIRE[3])        # vela
    lights=[(cxp,fy+10,96,150,1.2),(58,50,64,120,1.0),(412,50,64,120,1.0),(150,30,54,104,1.1),(330,30,54,104,1.1),
            (240,150,64,150,1.6),(240,86,52,80,1.0),(346,270,70,80,1.0),(240,262,150,70,0.7)]
    apply_lighting(img,lights)
    glow(img,cxp,fy+8,44,54,(255,140,50,40)); glow(img,240,150,30,44,(255,224,150,30)); glow(img,346,262,16,20,(255,200,110,44))
    vig=new(W,H); vd=ImageDraw.Draw(vig)
    for i in range(60): vd.rectangle([i,i,W-1-i,H-1-i],outline=(10,6,4,max(0,80-i)))
    img.alpha_composite(vig)
    return img

s=scene(); s.save(os.path.join(UI,"menu_bg.png"))
s.resize((W*3,H*3),Image.NEAREST).save("/tmp/claude-0/-home-user-techprice/0a2fc084-10f8-5400-8cfe-9bcfc6f5e98c/scratchpad/menu_preview.png")
print("OK v4")

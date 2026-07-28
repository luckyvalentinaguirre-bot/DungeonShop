#!/usr/bin/env python3
"""Menu de Dungeon Shop en pixel art HD (480x270), v3 con feedback:
mostrador mas bajo, mas profundidad (mesas, barriles, cajas, vitrina, alfombras),
estanterias repletas, dos ventanas al exterior, chimenea con luz en el suelo,
puerta grande. Las particulas (humo, lluvia, polvo, gente) se animan en Godot."""
from PIL import Image, ImageDraw
import os
REPO="/workspace/dungeonshop"; UI=os.path.join(REPO,"assets","ui"); os.makedirs(UI,exist_ok=True)
W,H=480,270

WALL=[(42,28,18),(56,37,23),(70,47,29),(86,60,38)]
FLOOR=[(74,46,26),(96,60,34),(116,76,42),(146,96,56)]
CWOOD=[(40,26,14),(58,37,20),(80,52,28)]
DWOOD=[(26,17,11),(40,27,17),(58,38,24)]
STONE=[(58,54,49),(84,79,72),(112,106,97),(150,143,131)]
METAL=[(70,80,92),(120,132,146),(176,188,200),(228,236,244)]
GOLD=[(120,90,26),(176,132,40),(224,180,66),(248,224,140)]
BLUE=[(24,64,120),(40,110,180),(96,168,230),(176,220,252)]
GRN=[(20,80,40),(40,130,66),(90,180,110),(170,230,190)]
FIRE=[(120,26,10),(210,64,20),(255,130,36),(255,196,80),(255,244,170)]
SKY=[(26,34,58),(38,50,78),(54,72,104),(74,96,128)]
LEAF=[(28,58,30),(52,104,52),(84,150,78),(122,190,108)]
RUG=[(74,26,34),(120,42,54),(150,58,70),(184,96,110)]
RUGB=[(30,50,90),(46,74,120),(70,104,160)]
REDB=(150,58,58);BLUEB=(70,90,150);K=(22,15,11)

def new(w,h):return Image.new("RGBA",(w,h),(0,0,0,0))
def F(d,x,y,w,h,c):d.rectangle([x,y,x+w-1,y+h-1],fill=c)
def dither_v(d,x,y,w,h,r):
    n=len(r);b=max(1,h//n)
    for i in range(n):
        F(d,x,y+i*b,w,b+(h-b*n if i==n-1 else 0),r[i])
        if i<n-1:
            yy=y+(i+1)*b
            for xx in range(x,x+w):
                if (xx+yy)%2==0:d.point((xx,yy-1),fill=r[i+1])
def panel(d,x,y,w,h,r,outline=True,ao=True):
    m=len(r)//2;F(d,x,y,w,h,r[m]);F(d,x,y,w,2,r[-1]);F(d,x,y,2,h,r[min(len(r)-1,m+1)])
    F(d,x,y+h-2,w,2,r[0]);F(d,x+w-2,y,2,h,r[max(0,1)])
    if outline:d.rectangle([x,y,x+w-1,y+h-1],outline=K)
    if ao:F(d,x,y+h,w,1,(0,0,0,70))
def grain(d,x,y,w,h,r,step=6):
    for yy in range(y+2,y+h-1,step):
        for xx in range(x+1,x+w-1):
            if (xx+yy)%7<2:d.point((xx,yy),fill=r[0])

# ---------- sub-sprites ----------
def potion(d,x,y,r):
    F(d,x+2,y,3,2,DWOOD[1]);panel(d,x,y+2,7,9,r,ao=False);F(d,x+1,y+3,2,5,r[-1]);F(d,x+1,y+5,5,2,(255,255,255,40))
def helmet(d,x,y):
    d.pieslice([x,y,x+12,y+14],180,360,fill=METAL[1]);d.pieslice([x+1,y+1,x+11,y+13],180,360,fill=METAL[2])
    F(d,x,y+7,13,4,METAL[1]);F(d,x+3,y+8,7,2,K);F(d,x+5,y,3,4,METAL[3])
def ore(d,x,y,c):
    d.polygon([(x,y+8),(x+4,y+2),(x+9,y+3),(x+12,y+9),(x+7,y+13),(x+2,y+12)],fill=c);d.polygon([(x+4,y+2),(x+7,y+7),(x+2,y+8)],fill=METAL[3])
def ring(d,x,y):
    d.ellipse([x,y+3,x+7,y+10],outline=GOLD[2]);d.ellipse([x+1,y+4,x+6,y+9],outline=GOLD[1]);F(d,x+2,y,3,3,(79,208,200))
def barrel(d,x,y,w,h):
    panel(d,x,y,w,h,[(58,38,20),(96,62,32),(130,86,46)])
    F(d,x,y+2,w,3,METAL[1]);F(d,x,y+h-6,w,3,METAL[1])
    for xx in range(x+3,x+w-1,5):F(d,xx,y,1,h,(58,38,20))
    d.ellipse([x,y-3,x+w-1,y+5],fill=(110,74,40));d.ellipse([x+2,y-2,x+w-3,y+3],fill=(80,52,28))
def crate(d,x,y,s):
    panel(d,x,y,s,s,[(60,40,22),(100,68,38),(134,92,52)])
    d.line([x+2,y+2,x+s-3,y+s-3],fill=(60,40,22));d.line([x+s-3,y+2,x+2,y+s-3],fill=(60,40,22))
def swordhung(d,x,y,ln=30):
    panel(d,x,y,4,ln,METAL,outline=False,ao=False);F(d,x,y,2,ln,METAL[3]);F(d,x-4,y+ln,12,4,GOLD[2]);panel(d,x+1,y+ln+4,3,7,DWOOD,ao=False);d.ellipse([x,y+ln+11,x+4,y+ln+15],fill=GOLD[2])
def shieldhung(d,x,y,r):
    d.ellipse([x,y,x+r,y+int(r*1.15)],fill=METAL[1]);d.ellipse([x+2,y+2,x+r-2,y+int(r*1.15)-2],fill=METAL[2]);d.ellipse([x+r//2-3,y+r//2-2,x+r//2+3,y+r//2+4],fill=GOLD[2]);d.arc([x,y,x+r,y+int(r*1.15)],200,340,fill=METAL[3])
def exterior(d,img,x,y,w,h):
    dither_v(d,x,y,w,h,SKY)
    d.ellipse([x+w-14,y+5,x+w-6,y+13],fill=(214,222,236))     # luna
    for i in range(x+2,x+w,3):                                 # estrellas
        if (i*7)%11==0:d.point((i,y+4+(i%5)),fill=(200,210,230))
    base=y+h-9
    for hx,hh,c in ((x+3,14,SKY[2]),(x+13,20,(46,60,92)),(x+26,16,SKY[2]),(x+38,22,(42,56,88)),(x+50,15,SKY[2])):
        if hx+10>x+w:continue
        F(d,hx,base-hh,11,hh,c);d.polygon([(hx-1,base-hh),(hx+5,base-hh-6),(hx+11,base-hh)],fill=(58,48,64))
        F(d,hx+3,base-hh+4,3,3,(255,204,120))
    F(d,x+22,base-14,2,10,(40,30,26));d.ellipse([x+17,base-24,x+29,base-10],fill=(36,64,46))   # arbol
    lx=x+w-12;F(d,lx,base-16,2,14,(44,44,52));d.ellipse([lx-3,base-20,lx+5,base-12],fill=(255,200,110))  # farola
    g=new(W,H);ImageDraw.Draw(g).ellipse([lx-12,base-28,lx+14,base-2],fill=(255,200,110,46));img.alpha_composite(g)
    for yy in range(base,y+h,3):                               # empedrado
        for xx in range(x,x+w,5):F(d,xx+(yy%2)*2,yy,3,2,(56,56,64))
    F(d,x,y+h//2,w,1,DWOOD[0]);F(d,x+w//2,y,1,h,DWOOD[0])      # mullions

def window(d,img,x,y,w,h):
    panel(d,x-5,y-5,w+10,h+10,DWOOD)
    exterior(d,img,x,y,w,h)
    for yy in range(y,y+h,8):F(d,x,yy,w,1,(255,255,255,16))    # reflejos
    panel(d,x-8,y+h+3,w+16,6,DWOOD,ao=False)                   # alfeizar
    # luz calida entrando
    b=new(W,H);ImageDraw.Draw(b).polygon([(x+6,y+h),(x+w-6,y+h),(x+w+22,y+h+70),(x-22,y+h+70)],fill=(255,214,150,20));img.alpha_composite(b)

def scene():
    img=new(W,H);d=ImageDraw.Draw(img)
    dither_v(d,0,0,W,150,WALL)
    for yy in range(0,150,12):
        F(d,0,yy,W,1,WALL[0])
        for xx in range(0,W):
            if (xx+yy)%9<1:d.point((xx,yy+1),fill=WALL[3])
    panel(d,0,146,W,7,DWOOD,outline=False,ao=False)             # rodapie
    dither_v(d,0,152,W,118,FLOOR)
    for xx in range(0,W,40):F(d,xx,152,1,80,FLOOR[0])
    for yy in range(160,246,9):F(d,0,yy,W,1,FLOOR[1])

    # ---- PUERTA GRANDE (foco) ----
    dw,dh=118,196;dx=W//2-dw//2;dy=14
    panel(d,dx-9,dy-9,dw+18,dh+14,DWOOD)
    d.pieslice([dx-9,dy-30,dx+dw+9,dy+30],180,360,fill=DWOOD[1])
    F(d,dx,dy,dw,dh,(50,33,18))
    gx,gy,gw,gh=dx+9,dy+6,dw-18,120
    exterior(d,img,gx,gy,gw,gh)
    d=ImageDraw.Draw(img)
    # silueta lejana de alguien en la puerta (sugerencia)
    F(d,gx+gw//2-3,gy+gh-16,6,14,(30,40,60));d.ellipse([gx+gw//2-3,gy+gh-20,gx+gw//2+3,gy+gh-14],fill=(34,44,66))
    d.rectangle([gx,gy,gx+gw-1,gy+gh-1],outline=DWOOD[0])
    panel(d,dx+9,dy+132,dw-18,dh-138,CWOOD)                      # panel inferior
    d.rectangle([dx+18,dy+144,dx+dw-18,dy+dh-16],outline=DWOOD[0])
    d.ellipse([dx+dw-20,dy+180,dx+dw-12,dy+188],fill=GOLD[2]);d.point((dx+dw-17,dy+183),fill=GOLD[3])
    # campana
    bx=dx+dw//2;F(d,bx-1,dy-30,2,7,DWOOD[0]);d.pieslice([bx-6,dy-27,bx+6,dy-15],180,360,fill=GOLD[1]);F(d,bx-6,dy-16,12,2,GOLD[2]);F(d,bx-1,dy-14,2,3,GOLD[0])
    # alfombra de bienvenida bajo la puerta
    panel(d,dx-6,dy+dh-6,dw+12,20,RUGB,ao=False);d.rectangle([dx-2,dy+dh-2,dx+dw+2,dy+dh+11],outline=GOLD[2])

    # ---- VENTANAS (ambas al exterior) ----
    window(d,img,36,28,66,48);window(d,img,378,28,66,48);d=ImageDraw.Draw(img)

    # ---- ESTANTERIAS IZQ repletas ----
    for sy in (86,108,130):
        panel(d,10,sy,74,5,[(60,38,20),(94,60,30),(126,84,44)],ao=False);F(d,10,sy+5,74,2,DWOOD[0])
    for i,px in enumerate((14,24,34,44)):potion(d,px,74,[BLUE,GRN][i%2])   # pociones
    ore(d,56,74,STONE[2]);ore(d,66,75,GOLD[2])                              # minerales
    for i,bx in enumerate((14,18,22,26,30,34,38,42,46)):F(d,bx,97,3,10,[REDB,(40,130,66),BLUEB,(150,120,60)][i%4]);F(d,bx,97,3,1,GOLD[2])  # libros
    helmet(d,54,95);ring(d,70,99)                                          # casco, anillo
    for px in (14,26,38,50):F(d,px,120,7,9,(200,180,140));F(d,px,120,7,2,(150,130,96))  # frascos/pergaminos
    ore(d,64,120,GRN[1])

    # ---- PARED DER: armas + herbario ----
    swordhung(d,300,80);swordhung(d,318,84,26);shieldhung(d,338,80,26)
    d.polygon([(360,86),(374,80),(374,98),(360,92)],fill=METAL[2]);F(d,372,84,3,30,CWOOD[2])  # hacha
    for hx in (300,308,316):F(d,hx,120,1,10,(90,70,40));d.ellipse([hx-3,128,hx+3,136,],fill=LEAF[1])
    helmet(d,330,116)

    # ---- CHIMENEA der (con luz en el suelo) ----
    fx,fy,fw,fh=404,150,72,96;fy2=fy-58
    panel(d,fx,fy2,fw,fh+58,STONE)
    for yy in range(fy2,fy+fh,10):
        for xx in range(fx,fx+fw,16):F(d,xx+((yy//10)%2)*8,yy,15,9,STONE[1]);d.rectangle([xx+((yy//10)%2)*8,yy,xx+((yy//10)%2)*8+15,yy+9],outline=STONE[0])
    panel(d,fx-7,fy2-8,fw+14,10,STONE,ao=False)
    F(d,fx+14,fy2+22,fw-28,fh+58-30,(16,11,8))
    panel(d,fx+18,fy+fh-18,fw-36,8,DWOOD,ao=False)
    cxp=fx+fw//2
    for j,col in enumerate(FIRE[1:]):d.polygon([(cxp-14+3*j,fy+fh-12),(cxp,fy2+40+8*j),(cxp+14-3*j,fy+fh-12)],fill=col)
    for ex in (cxp-6,cxp+5,cxp):d.point((ex,fy+fh-14),fill=FIRE[3])          # brasas
    gl=new(W,H);gld=ImageDraw.Draw(gl)
    gld.ellipse([fx-16,fy2+8,fx+fw+16,fy+fh+20],fill=(255,140,50,44))         # resplandor
    gld.ellipse([fx-40,fy+fh-6,fx+fw+30,fy+fh+40],fill=(255,150,60,40))        # luz naranja en el suelo
    img.alpha_composite(gl);d=ImageDraw.Draw(img)

    # ---- PROFUNDIDAD: props entre mostrador y puerta ----
    # Mesa de exhibicion (izq-centro)
    tx,ty,tw=44,196,96
    panel(d,tx,ty,tw,10,[(60,40,22),(100,68,38),(134,92,52)]);F(d,tx+4,ty+10,6,30,DWOOD[1]);F(d,tx+tw-10,ty+10,6,30,DWOOD[1])
    potion(d,tx+10,ty-9,BLUE);potion(d,tx+20,ty-9,GRN);helmet(d,tx+36,ty-12);F(d,tx+58,ty-8,14,8,BLUEB);F(d,tx+58,ty-8,14,2,GOLD[2])  # libro
    swordhung(d,tx+82,ty-14,16)
    # Barriles (centro-izq)
    barrel(d,150,206,22,38);barrel(d,175,210,20,34);barrel(d,163,182,20,26)
    ore(d,167,178,GOLD[2])
    # Cajas apiladas (centro-der)
    crate(d,300,214,30);crate(d,332,214,28);crate(d,314,188,26)
    potion(d,323,180,GRN)
    # Vitrina de cristal con objeto legendario (der-centro)
    vx,vy,vw,vh=360,190,44,54
    panel(d,vx,vy,vw,vh,DWOOD)
    F(d,vx+3,vy+3,vw-6,vh-16,(120,180,210,90))                 # cristal
    swordhung(d,vx+vw//2-2,vy+8,24)                            # espada legendaria
    sg=new(W,H);ImageDraw.Draw(sg).ellipse([vx+4,vy+6,vx+vw-4,vy+vh-10],fill=(120,220,240,40));img.alpha_composite(sg);d=ImageDraw.Draw(img)
    panel(d,vx,vy+vh-10,vw,10,[(60,40,22),(100,68,38),(134,92,52)],ao=False)
    # Alfombra central
    rx,ry,rw,rh=196,214,96,30
    panel(d,rx,ry,rw,rh,RUG,ao=False);d.rectangle([rx+4,ry+3,rx+rw-5,ry+rh-4],outline=GOLD[2])
    d.polygon([(rx+rw//2,ry+5),(rx+rw//2+14,ry+rh//2),(rx+rw//2,ry+rh-5),(rx+rw//2-14,ry+rh//2)],fill=(63,154,144))
    for bx in range(rx,rx+rw,7):F(d,bx,ry-3,3,3,GOLD[2])

    # ---- LINTERNA colgante ----
    lx=150;F(d,lx,0,1,16,(60,60,66));panel(d,lx-5,16,11,14,DWOOD,ao=False);F(d,lx-3,19,7,8,(255,200,110))
    lg=new(W,H);ImageDraw.Draw(lg).ellipse([lx-16,8,lx+16,40],fill=(255,190,90,34));img.alpha_composite(lg);d=ImageDraw.Draw(img)

    # ---- MOSTRADOR (mas bajo) ----
    cy=248
    panel(d,0,cy,W,270-cy,CWOOD,outline=False)
    F(d,0,cy,W,4,(150,100,52));F(d,0,cy+4,W,2,(120,78,40))
    grain(d,0,cy+6,W,270-cy-6,CWOOD,step=7)
    for xx in range(0,W,50):F(d,xx,cy+5,1,270-cy-5,DWOOD[0])
    potion(d,36,cy-11,BLUE);d.ellipse([392,cy-6,404,cy+2],fill=GOLD[2]);d.ellipse([400,cy-5,410,cy+2],fill=GOLD[1])
    F(d,224,cy-14,20,14,BLUEB);F(d,224,cy-14,20,3,GOLD[2]);F(d,250,cy-16,2,16,(230,230,220))
    F(d,300,cy-12,4,12,(235,225,200));F(d,301,cy-16,2,4,FIRE[3])
    cg=new(W,H);ImageDraw.Draw(cg).ellipse([292,cy-24,312,cy+2],fill=(255,200,110,40));img.alpha_composite(cg)

    # ---- Vignette ----
    vig=new(W,H);vd=ImageDraw.Draw(vig)
    for i in range(44):vd.rectangle([i,i,W-1-i,H-1-i],outline=(16,8,4,max(0,58-i)))
    img.alpha_composite(vig)
    return img

def sign():
    w,h=300,84;img=new(w,h);d=ImageDraw.Draw(img)
    F(d,44,0,3,14,(80,80,86));F(d,w-47,0,3,14,(80,80,86))
    for cy in range(0,14,4):F(d,44,cy,3,2,(120,120,128));F(d,w-47,cy,3,2,(120,120,128))
    panel(d,10,12,w-20,h-22,[(40,26,14),(58,37,20),(78,50,27)])
    panel(d,16,18,w-32,h-34,[(70,45,24),(96,62,32),(128,86,46)]);grain(d,16,18,w-32,h-34,CWOOD,step=8)
    for cx,cy in ((18,20),(w-40,20),(18,h-32),(w-40,32)):
        panel(d,cx,cy,22,12,METAL,ao=False)
        for ox,oy in ((cx+3,cy+3),(cx+16,cy+3),(cx+3,cy+7),(cx+16,cy+7)):d.point((ox,oy),fill=(40,44,50))
    gx=w//2
    d.polygon([(gx,16),(gx+9,28),(gx,42),(gx-9,28)],fill=(79,208,200))
    d.polygon([(gx,20),(gx+4,28),(gx,36),(gx-4,28)],fill=(186,255,248));d.point((gx-2,26),fill=(255,255,255))
    gg=new(w,h);ImageDraw.Draw(gg).ellipse([gx-18,10,gx+18,46],fill=(120,240,230,50));img.alpha_composite(gg)
    dd=ImageDraw.Draw(img)
    dd.text((gx-64,51),"D U N G E O N   S H O P",fill=(120,80,40))
    dd.text((gx-64,52),"D U N G E O N   S H O P",fill=(245,224,170))
    return img

def plank(hover=False):
    w,h=150,34;img=new(w,h);d=ImageDraw.Draw(img)
    r=[(70,45,24),(110,74,40),(150,104,56)] if hover else [(52,34,18),(88,58,30),(120,80,42)]
    panel(d,0,0,w,h,r);grain(d,4,4,w-8,h-8,r,step=6)
    for cx in (8,w-14):d.ellipse([cx,h//2-3,cx+6,h//2+3],fill=(60,62,66));d.point((cx+2,h//2-1),fill=(150,150,156))
    if hover:
        gl=new(w,h);ImageDraw.Draw(gl).rectangle([2,2,w-3,h-3],fill=(255,220,120,46));img.alpha_composite(gl)
        ImageDraw.Draw(img).rectangle([1,1,w-2,h-2],outline=(255,224,140))
    return img

def npc():
    w,h=26,42;img=new(w,h);d=ImageDraw.Draw(img)
    F(d,6,32,6,8,(40,30,20))
    panel(d,5,20,16,16,[(38,62,96),(60,96,138),(90,132,178)],ao=False)
    d.polygon([(5,20),(13,16),(21,20),(21,26),(5,26)],fill=(50,80,120))
    d.ellipse([7,7,19,20],fill=(232,200,160));F(d,7,7,12,4,(60,44,30))
    d.pieslice([5,2,21,16],180,360,fill=(70,52,34))
    d.point((10,12),fill=K);d.point((15,12),fill=K)
    F(d,7,38,5,3,(30,22,14));F(d,14,38,5,3,(30,22,14))
    return img

s=scene();s.save(os.path.join(UI,"menu_bg.png"))
sign().save(os.path.join(UI,"menu_sign.png"))
plank(False).save(os.path.join(UI,"menu_plank.png"))
plank(True).save(os.path.join(UI,"menu_plank_hover.png"))
npc().save(os.path.join(UI,"menu_npc.png"))
s.resize((W*3,H*3),Image.NEAREST).save("/tmp/claude-0/-home-user-techprice/0a2fc084-10f8-5400-8cfe-9bcfc6f5e98c/scratchpad/menu_preview.png")
print("OK v3")

#ifndef __fltk_tools_bi__
#define __fltk_tools_bi__

'  FreeBASIC header file for the Fast Light Tool Kit C wrapper.
'  FLTK C wrapper copyright 2013-2019 by D.J.Peters

'  C++ library Fast Light Tool Kit (FLTK)
'  Copyright 1998-2010 by Bill Spitzak and others.
' 
'  This library is free software. Distribution and use rights are outlined in
'  the file "COPYING" which should have been included with this file.  If this
'  file is missing or damaged, see the license at:
' 
'    http://www.fltk.org/COPYING.php
' 
'  Please report all FLTK C wrapper bugs and problems on the following page:
' 
'    http://www.freebasic.net/forum/viewtopic.php?f=14&t=24547

#ifndef __FLTK_MAIN_BI__
 #include once "fltk-main.bi"
#endif

#ifdef __FB_WIN32__
const SEP = "\"
#else
const SEP = "/"
#endif

function getGUIPath as string 
  dim as zstring ptr cwd = Fl_getcwd(0,2048)
  dim as string path = *cwd : Fl_Free(cwd)
  if right(path,1)<>SEP then path &=SEP
  return path
end function

function getGUIApp as string 
  dim as string app = *flFilenameName(command(0))
  dim as string ext = *flFilenameExt(app)
  if len(ext) then app=left(app,len(app)-len(ext))
  return app
end function


sub flMessageBox(byval title as const zstring ptr,byval msg as const zstring ptr)
  if msg=0 then return
  if title then flMessageTitle(title)
  flMessage(msg)
end sub

' Draw a single pixel at the given coordinates
sub DrawPointColor(byval x as integer,byval y as integer,byval c as Fl_color)
  DrawSetColor(c):DrawPoint(x,y)
end sub
sub DrawPointRGBColor(byval x as integer,byval y as integer,byval r as ubyte,byval g as ubyte,byval b as ubyte)
  DrawSetColor(Fl_RGB_Color(r,g,b)) : DrawPoint(x,y)
end sub
' Draw a 1-pixel border inside this bounding box.
sub DrawRectRGBColor(byval x as integer,byval y as integer,byval w as integer,byval h as integer,byval r as ubyte,byval g as ubyte,byval b as ubyte)
  DrawRectColor(x,y,w,h,Fl_RGB_Color(r,g,b))
end sub
' Draws a box using given type, position, size and color. 
sub DrawBoxRGBColor(byval bt as Fl_Boxtype,byval x as integer,byval y as integer,byval w as integer,byval h as integer,byval r as ubyte,byval g as ubyte,byval b as ubyte)
  DrawBox(bt,x,y,w,h,Fl_RGB_Color(r,g,b))
end sub

function Fl_Menu_AddImageLabel(byval mnuBar    as Fl_Menu_ ptr, _
                               byval mnuPath   as const zstring ptr, _
                               byval labText   as const zstring ptr, _
                               byval imgFile   as const zstring ptr, _
                               byval shortcut  as long=0, _
                               byval cb        as Fl_Callback=0, _
                               byval imgAlign  as FL_ALIGN=0, _
                               byval txtalign  as FL_ALIGN=0) as Fl_Menu_Item ptr
  if mnuBar =NULL then return NULL
  if mnuPath=NULL then return NULL
  if labText=NULL then return NULL
  if imgFile=NULL then return NULL

  Fl_Menu_Add(mnuBar,mnuPath,shortcut,cb)

  dim as Fl_Menu_Item ptr itm = Fl_Menu_FindItemByName(mnuBar,mnuPath)
  var img = Fl_PNG_ImageNew(imgFile) 

  Fl_WindowMakeCurrent(Fl_WidgetWindow(mnuBar))

  DrawSetFont(Fl_WidgetGetLabelFont(mnuBar),Fl_WidgetGetLabelSize(mnuBar))

  dim as long w,h

  if (imgAlign and Fl_ALIGN_IMAGE_NEXT_TO_TEXT) then 
    w = DrawGetStrWidth(labText) + Fl_ImageW(img)
    h = iif(DrawGetFontHeight()>Fl_ImageH(img),DrawGetFontHeight(),Fl_ImageH(img))
  else
    h = DrawGetFontHeight() + Fl_ImageH(img)
    w = DrawGetStrWidth(labText)
    if (w < Fl_ImageW(img)) then w = Fl_ImageW(img)
  end if
  if h<32 then h= 32
  if w<100 then w=100

  DrawSetColor(Fl_BACKGROUND_COLOR) : DrawRectFill(0,0,w,h)
  DrawSetColor(Fl_WidgetGetLabelColor(mnuBar))
  DrawStrBox(labText,0,0,w,h,imgAlign or txtAlign,img,0)
  'DrawStrBox(labText,0,0,w,h,imgAlign or txtAlign or FL_ALIGN_CLIP,img,0)
  Fl_RGB_ImageDelete(img)
  var pixels=DrawReadImage(0,0,0,w,h,0)
  Fl_Menu_ItemImage(itm,Fl_RGB_ImageNew(pixels,w,h,3))
  return itm
end function


function flBox(byval b as Fl_Boxtype) as Fl_Boxtype
  return iif((b<BoxType(FL_UP_BOX) or b mod 4>1),b,(b-2))
end function

function flDown(byval b as Fl_Boxtype) as Fl_Boxtype
  return iif((b<BoxType(FL_UP_BOX)),b,(b or 1))
end function

function flFrame(byval b as Fl_Boxtype) as Fl_Boxtype
  return iif((b mod 4<2),b,(b+2))
end function


'Returns a lighter version of the specified color.
function Fl_Lighter(byval c as Fl_Color) as Fl_Color
  return Fl_Color_Average(c, FL_WHITE, .67)
end function

function Fl_LighterRGB(byval r as ubyte,byval g as ubyte,byval b as ubyte) as Fl_Color
  return Fl_Color_Average(Fl_RGB_Color(r,g,b), FL_WHITE, .67)
end function

' Returns a darker version of the specified color.
function Fl_Darker(byval c as Fl_Color) as Fl_Color
  return Fl_Color_Average(c, FL_BLACK, .67)
end function

function Fl_DarkerRGB(byval r as ubyte,byval g as ubyte,byval b as ubyte) as Fl_Color
  return Fl_Color_Average(Fl_RGB_Color(r,g,b), FL_BLACK, .67)
end function

' Draws the widget's label in an arbitrary bounding box.
sub Fl_WidgetDrawLabel2(byval wgt as Fl_Widget ptr, _
                        byval x as integer, byval y as integer, _
                        byval w as integer, byval h as integer)
  dim as Fl_Align align = Fl_WidgetGetAlign(wgt)
  if (align and Fl_ALIGN_POSITION_MASK) andalso (align and FL_ALIGN_INSIDE)=0 then return
  Fl_WidgetDrawLabel(wgt,x,y,w,h,align)
end sub

' Draws the widget's label at the defined label position.
sub Fl_WidgetDrawLabel3(byval wgt as Fl_Widget ptr)
  var bt = Fl_WidgetGetBox(wgt)
  dim as integer x = Fl_WidgetGetX(wgt)+Fl_BoxDX(bt)
  dim as integer y = Fl_WidgetGetY(wgt)+Fl_BoxDY(bt)
  dim as integer w = Fl_WidgetGetW(wgt)+Fl_BoxDW(bt)
  dim as integer h = Fl_WidgetGetH(wgt)-Fl_BoxDH(bt)
  if (w > 11) andalso (Fl_WidgetGetAlign(wgt) and (FL_ALIGN_LEFT or FL_ALIGN_RIGHT)) then
    x += 3 : w -= 6
  end if
  Fl_WidgetDrawLabel2(wgt,x,y,w,h)
end sub

' Draws a focus box for the widget at the given position and size
sub Fl_WidgetDrawFocus(byval wgt as Fl_Widget ptr, byval bt as Fl_Boxtype, _
                       byval x as integer, byval y as integer, _
                       byval w as integer, byval h as integer)
  if Fl_WidgetGetVisibleFocus(wgt)=0 then return
  select case bt
  case FL_DOWN_BOX,FL_DOWN_FRAME,FL_THIN_DOWN_BOX,FL_THIN_DOWN_FRAME
    x+=1 : y+=1
  end select
  DrawSetColor(Fl_Contrast(FL_BLACK, Fl_WidgetGetColor(wgt)))
#ifdef __FB_WIN32__
  x += Fl_BoxDX(bt)
  y += Fl_BoxDY(bt)
  w -= Fl_BoxDW(bt) + 2
  h -= Fl_BoxDH(bt) + 2
  dim as integer i=1
  dim as integer xx
  while xx<w
    if (i and 1) then DrawPoint(x+xx,y)
    xx+=1 : i+=1
  wend
  dim as integer yy
  while (yy<h)
    if (i and 1) then DrawPoint(x+w,y+yy)
    yy+=1 : i+=1
  wend
  xx=w
  while(xx>0)
    if i and 1 then DrawPoint(x+xx,y+h)
    xx-=1 : i+=1
  wend
  yy=h
  while(yy>0)
    if i and 1 then DrawPoint(x,y+yy)
    yy-=1 : i+=1
  wend
#else
  DrawSetLineStyle(FL_DOT)
  DrawRect(x + Fl_BoxDX(bt), y + Fl_BoxDY(bt), w - Fl_BoxDW(bt) - 1, h - Fl_BoxDH(bt) - 1)
  DrawSetLineStyle(FL_SOLID)
#endif
end sub

sub Fl_WidgetDrawFocus2(byval wgt as Fl_Widget ptr)
  Fl_WidgetDrawFocus(wgt,Fl_WidgetGetBox(wgt),Fl_WidgetGetX(wgt),Fl_WidgetGetY(wgt),Fl_WidgetGetW(wgt),Fl_WidgetGetH(wgt))
end sub

function RelX(byval parent as FL_Widget ptr,byval x as long) as long
  if parent=0 then return x
  if Fl_WidgetAsWindow(parent)  then return x
  if Fl_WidgetAsGroup(parent)=0 then return x
  return x+Fl_WidgetGetX(parent)
end function

function RelY(byval parent as FL_Widget ptr,byval y as long) as long
  if parent=0 then return y
  if Fl_WidgetAsWindow(parent)  then return y
  if Fl_WidgetAsGroup(parent)=0 then return y
  return y+Fl_WidgetGetY(parent)
end function

#define FL_TYPE_WINDOW        &HF0 ' < window type id all subclasses have Fl_WidgetGetType() >= this
#define FL_TYPE_DOUBLE_WINDOW &HF1 ' < double window type id

' Forces a Fl_Group child to redraw.
sub Fl_Group_DrawChild(byval wgt as Fl_Widget ptr)
  ' don`t draw if not visible
  if Fl_WidgetVisible(wgt)=0 then return
  ' don't draw if isn't a child
  if Fl_WidgetGetType(wgt)>=FL_TYPE_WINDOW then return
  ' draw it only if the child is a part of the current clip region
  if DrawNotClipped(Fl_WidgetGetX(wgt), Fl_WidgetGetY(wgt),Fl_WidgetGetW(wgt),Fl_WidgetGetH(wgt)) then
    Fl_WidgetClearDamage(wgt,FL_DAMAGE_ALL)
    Fl_WidgetDraw(wgt)
    Fl_WidgetClearDamage(wgt)
  end if
end sub

' Updates/draws a Fl_Group child only if it needs it.
' see also Fl_Group_DrawChild(byval wgt as Fl_Widget ptr)
sub Fl_Group_UpdateChild(byval wgt as Fl_Widget ptr)
  ' don't draw if isn't a child
  if Fl_WidgetGetType(wgt)>=FL_TYPE_WINDOW then return
  ' don`t draw if not visible
  if Fl_WidgetVisible(wgt)=0 then return
  ' don't draw if nothing damaged since last draw 
  if Fl_WidgetGetDamage(wgt)=0 then return
  ' draw it only if the child is a part of the current clip region
  if DrawNotClipped(Fl_WidgetGetX(wgt), Fl_WidgetGetY(wgt),Fl_WidgetGetW(wgt),Fl_WidgetGetH(wgt)) then
    Fl_WidgetDraw(wgt) : Fl_WidgetClearDamage(wgt)
  end if
end sub

function BoxtypeAsString(byval btype as integer) as const zstring ptr
  select case btype
  case FL_NO_BOX                 : return @"FL_NO_BOX"
  case FL_FLAT_BOX               : return @"FL_FLAT_BOX"
  case FL_UP_BOX                 : return @"FL_UP_BOX"
  case FL_DOWN_BOX               : return @"FL_DOWN_BOX"
  case FL_UP_FRAME               : return @"FL_UP_FRAME"
  case FL_DOWN_FRAME             : return @"FL_DOWN_FRAME"
  case FL_THIN_UP_BOX            : return @"FL_THIN_UP_BOX"
  case FL_THIN_DOWN_BOX          : return @"FL_THIN_DOWN_BOX"
  case FL_THIN_UP_FRAME          : return @"FL_THIN_UP_FRAME"
  case FL_THIN_DOWN_FRAME        : return @"FL_THIN_DOWN_FRAME"
  case FL_ENGRAVED_BOX           : return @"FL_ENGRAVED_BOX"
  case FL_EMBOSSED_BOX           : return @"FL_EMBOSSED_BOX"
  case FL_ENGRAVED_FRAME         : return @"FL_ENGRAVED_FRAME"
  case FL_EMBOSSED_FRAME         : return @"FL_EMBOSSED_FRAME"
  
  case FL_BORDER_BOX             : return @"FL_BORDER_BOX"
  case FL_SHADOW_BOX             : return @"FL_SHADOW_BOX"
  
  case FL_BORDER_FRAME           : return @"FL_BORDER_FRAME"
  case FL_SHADOW_FRAME           : return @"FL_SHADOW_FRAME"
  
  case FL_ROUNDED_BOX            : return @"FL_ROUNDED_BOX"
  case FL_RSHADOW_BOX            : return @"FL_RSHADOW_BOX"
  
  case FL_ROUNDED_FRAME          : return @"FL_ROUNDED_FRAME"
  
  case FL_RFLAT_BOX              : return @"FL_RFLAT_BOX"
  case FL_OVAL_BOX               : return @"FL_OVAL_BOX"
  case FL_OSHADOW_BOX            : return @"FL_OSHADOW_BOX"
  case FL_OVAL_FRAME             : return @"FL_OVAL_FRAME"
  case FL_OFLAT_BOX              : return @"FL_OFLAT_BOX"
  
  case FL_ROUND_UP_BOX           : return @"FL_ROUND_UP_BOX"
  case FL_ROUND_DOWN_BOX         : return @"FL_ROUND_DOWN_BOX"
  
  case FL_DIAMOND_UP_BOX         : return @"FL_DIAMOND_UP_BOX"
  case FL_DIAMOND_DOWN_BOX       : return @"FL_DIAMOND_DOWN_BOX"
  
  case FL_PLASTIC_UP_BOX         : return @"FL_PLASTIC_UP_BOX"
  case FL_PLASTIC_DOWN_BOX       : return @"FL_PLASTIC_DOWN_BOX"
  case FL_PLASTIC_UP_FRAME       : return @"FL_PLASTIC_UP_FRAME"
  case FL_PLASTIC_DOWN_FRAME     : return @"FL_PLASTIC_DOWN_FRAME"
  case FL_PLASTIC_THIN_UP_BOX    : return @"FL_PLASTIC_THIN_UP_BOX"
  case FL_PLASTIC_THIN_DOWN_BOX  : return @"FL_PLASTIC_THIN_DOWN_BOX"
  case FL_PLASTIC_ROUND_UP_BOX   : return @"FL_PLASTIC_ROUND_UP_BOX"
  case FL_PLASTIC_ROUND_DOWN_BOX : return @"FL_PLASTIC_ROUND_DOWN_BOX"
  
  case FL_GTK_UP_BOX             : return @"FL_GTK_UP_BOX"
  case FL_GTK_DOWN_BOX           : return @"FL_GTK_DOWN_BOX"
  case FL_GTK_UP_FRAME           : return @"FL_GTK_UP_FRAME"
  case FL_GTK_DOWN_FRAME         : return @"FL_GTK_DOWN_FRAME"
  case FL_GTK_THIN_UP_BOX        : return @"FL_GTK_THIN_UP_BOX"
  case FL_GTK_THIN_DOWN_BOX      : return @"FL_GTK_THIN_DOWN_BOX"
  case FL_GTK_THIN_UP_FRAME      : return @"FL_GTK_THIN_UP_FRAME"
  case FL_GTK_THIN_DOWN_FRAME    : return @"FL_GTK_THIN_DOWN_FRAME"
  case FL_GTK_ROUND_UP_BOX       : return @"FL_GTK_ROUND_UP_BOX"
  case FL_GTK_ROUND_DOWN_BOX     : return @"FL_GTK_ROUND_DOWN_BOX"
  
  case FL_GLEAM_UP_BOX           : return @"FL_GLEAM_UP_BOX"
  case FL_GLEAM_DOWN_BOX         : return @"FL_GLEAM_DOWN_BOX" 
  case FL_GLEAM_UP_FRAME         : return @"FL_GLEAM_UP_FRAME"
  case FL_GLEAM_DOWN_FRAME       : return @"FL_GLEAM_DOWN_FRAME"
  case FL_GLEAM_THIN_UP_BOX      : return @"FL_GLEAM_THIN_UP_BOX"
  case FL_GLEAM_THIN_DOWN_BOX    : return @"FL_GLEAM_THIN_DOWN_BOX"
  case FL_GLEAM_ROUND_UP_BOX     : return @"FL_GLEAM_ROUND_UP_BOX"
  case FL_GLEAM_ROUND_DOWN_BOX   : return @"FL_GLEAM_ROUND_DOWN_BOX"
  case else                      : return @"UNKNOW BOX TYPE"
  end select
end function

function EventAsString(byval event as Fl_Event) as const zstring ptr
  select case as const event
  case FL_EVENT_PUSH           : return @"FL_EVENT_PUSH (1)"
  case FL_EVENT_RELEASE        : return @"FL_EVENT_RELEASE (2)"
  case FL_EVENT_ENTER          : return @"FL_EVENT_ENTER (3)"
  case FL_EVENT_LEAVE          : return @"FL_EVENT_LEAVE (4)"
  case FL_EVENT_DRAG           : return @"FL_EVENT_DRAG (5)"
  case FL_EVENT_FOCUS          : return @"FL_EVENT_FOCUS (6)"
  case FL_EVENT_UNFOCUS        : return @"FL_EVENT_UNFOCUS (7)"
  case FL_EVENT_KEYDOWN        : return @"FL_EVENT_KEYDOWN (8)"
  case FL_EVENT_KEYUP          : return @"FL_EVENT_KEYUP (9)"
  case FL_EVENT_CLOSE          : return @"FL_EVENT_CLOSE (10)"
  case FL_EVENT_MOVE           : return @"FL_EVENT_MOVE (11)"
  case FL_EVENT_SHORTCUT       : return @"FL_EVENT_SHORTCUT (12)"
  case FL_EVENT_DEACTIVATE     : return @"FL_EVENT_DEACTIVATE (13)"
  case FL_EVENT_ACTIVATE       : return @"FL_EVENT_ACTIVATE (14)"
  case FL_EVENT_HIDE           : return @"FL_EVENT_HIDE (15)"
  case FL_EVENT_SHOW           : return @"FL_EVENT_SHOW (16)"
  case FL_EVENT_PASTE          : return @"FL_EVENT_PASTE (17)"
  case FL_EVENT_SELECTIONCLEAR : return @"FL_EVENT_SELECTIONCLEAR (18)"
  case FL_EVENT_MOUSEWHEEL     : return @"FL_EVENT_MOUSEWHEEL (19)"
  case FL_EVENT_DND_ENTER      : return @"FL_EVENT_DND_ENTER (20)"
  case FL_EVENT_DND_DRAG       : return @"FL_EVENT_DND_DRAG (21)"
  case FL_EVENT_DND_LEAVE      : return @"FL_EVENT_DND_LEAVE (22)"
  case FL_EVENT_DND_RELEASE    : return @"FL_EVENT_DND_RELEASE (23)"
  case FL_EVENT_SCREEN_CONFIGURATION_CHANGED : return @"FL_EVENT_SCREEN_CONFIGURATION_CHANGED (24)"
  case FL_EVENT_FULLSCREEN     : return @"FL_EVENT_FULLSCREEN (25)"
  case else                    : return @"FL_EVENT UNKNOW !"
  end select
end function


#endif ' __fltk_tools_bi__

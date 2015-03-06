
#include "hbmemvar.ch"
#include "hdroidgui.ch"

#define HISTORY_SIZE_MAX   32

FUNCTION HDroidMain( lFirst )

   LOCAL oActivity, oFont, oLayV, oLayH1, oBtn1, oBtn2, oBtn3, oEdit1, oText0
   PUBLIC aHistory, nHistLen, nHistCurr

   IF lFirst
      aHistory := Array( HISTORY_SIZE_MAX )
      nHistLen := 0
      nHistCurr := 1
   ENDIF

   PREPARE FONT oFont HEIGHT 12
   INIT WINDOW oActivity TITLE "Calculator"

   MENU
      MENUITEM "Version" ACTION hd_MsgInfo(hd_Version()+Chr(10)+hb_Version())
      MENUITEM "Help" ACTION FHelp()
      MENUITEM "Exit" ACTION hd_MsgYesNo( "Really exit?", {|o|FExit(o)} )
   ENDMENU

   BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

      EDITBOX oEdit1 HINT "Input an expression" ON KEYDOWN {|n|onKey(n,oEdit1,oText0)}
            
      BEGIN LAYOUT oLayH1 HORIZONTAL SIZE MATCH_PARENT,32

      BUTTON oBtn2 TEXT " < " TEXTCOLOR 255 SIZE WRAP_CONTENT,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnHist(.T.,oEdit1)}
      BUTTON oBtn1 TEXT "Ok" TEXTCOLOR 255 SIZE 0,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnCalc(oEdit1,oText0)}
      BUTTON oBtn3 TEXT " > " TEXTCOLOR 255 SIZE WRAP_CONTENT,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnHist(.F.,oEdit1)}

      END LAYOUT oLayH1

      TEXTVIEW oText0 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL

   END LAYOUT oLayV

   ACTIVATE WINDOW oActivity

   RETURN Nil

STATIC Function OnBtnHist( lBack, oEdit1 )

   IF lBack
      IF nHistCurr >= 2
         oEdit1:SetText( aHistory[--nHistCurr] )
      ENDIF
   ELSE
      IF nHistCurr < nHistLen
         oEdit1:SetText( aHistory[++nHistCurr] )
      ELSE
         nHistCurr := nHistLen + 1
         oEdit1:SetText( "" )
      ENDIF
   ENDIF

   RETURN "1"

STATIC Function OnBtnCalc( oEdit1, oText1 )
   LOCAL s, xRez, bOldError, lRes := .T., n, i, cname, cType
   STATIC aVars := Nil

   IF !Empty( aVars )
      FOR i := 1 to Len( aVars )
         __mvPublic( aVars[i,1] )
         __mvPut( aVars[i,1], aVars[i,2] )
      NEXT
      aVars := Nil
   ENDIF

   s := Alltrim( oEdit1:GetText() )
   IF Empty( s )
      RETURN "0"
   ENDIF

   bOldError := ErrorBlock( { |e|break( e ) } )
   BEGIN SEQUENCE
      xRez := &s
   RECOVER
      xRez := "Error..."
      lRes := .F.
   END SEQUENCE
   ErrorBlock( bOldError )

   oText1:SetText( Iif( xRez == Nil, "Nil", Iif( (cType:=Valtype(xRez))=="A", "Array", ;
         Iif( cType == "O", "Object", ;
         Transform( xRez, "@B" ) ) + Chr(10)+Chr(13) + oText1:GetText() ) ) )

   IF lRes
      IF nHistLen < HISTORY_SIZE_MAX
         aHistory[++nHistLen] := s
      ELSE
         Adel( aHistory, 1 )
         aHistory[nHistLen] := s
      ENDIF
      nHistCurr := nHistLen + 1
      IF ( n := __mvDbgInfo( HB_MV_PRIVATE_LOCAL ) ) > 0
         aVars := {}
         FOR i := 1 to n
            xRez := __mvDbgInfo( HB_MV_PRIVATE_LOCAL, i, @cname )
            Aadd( aVars, { cname, xRez } )
         NEXT
      ENDIF
   ENDIF

   RETURN "1"

STATIC Function OnKey( nKey, oEdit1, oText1 )

   IF nKey == 66
      RETURN OnBtnCalc( oEdit1, oText1 )
   ENDIF

   RETURN "0"

STATIC Function FHelp()
   Local oWnd, oLayV, oText1
   Local s := "Calculator help" + Chr(10) + Chr(10) + ;
      "Use '<' and '>' buttons to navigate via calculations history." + Chr(10) + Chr(10) + ;
      "You may create variables, assigning values to them, and then use in expressions:"+ Chr(10) + ;
      "   arr := Directory()" + Chr(10) + ;
      "   Len(arr)"

   INIT WINDOW oWnd TITLE "Help" ON INIT {||oText1:SetText(s)}

   MENU
      MENUITEM "Test" ACTION FHelp2()
      MENUITEM "Exit" ACTION hd_calljava_s_v( "exit:")
   ENDMENU

   BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

      TEXTVIEW oText1 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN "1"

STATIC Function FHelp2()
   Local oWnd, oLayV, oText1
   Local s := "Just a test!"

   INIT WINDOW oWnd TITLE "Test"

   BEGIN LAYOUT oLayV BACKCOLOR 8706030 SIZE MATCH_PARENT,MATCH_PARENT

      TEXTVIEW oText1 TEXT s TEXTCOLOR 0 BACKCOLOR 8706030 SIZE MATCH_PARENT,MATCH_PARENT SCROLL

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN "1"

STATIC Function FExit( oDlg )

   IF oDlg:nres == 1
      hd_calljava_s_v( "exit:")
   ENDIF

   RETURN "1"

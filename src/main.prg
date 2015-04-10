
#include "hbmemvar.ch"
#include "hdroidgui.ch"

#define HISTORY_SIZE_MAX   32

Memvar aHistory, nHistLen, nHistCurr

FUNCTION HDroidMain( lFirst )

   LOCAL oActivity, oFont, oLayV, oLayH1, oEdit1, oText0
   LOCAL oBtn1, oBtn2, oBtn3, oBtn4, oBtn5, oBtn6, oBtn7, oBtn8, oBtn9, oBtn10, oBtn11
   LOCAL oStyleN, oStyleP, oStyleText, oStyleEdi, cWhite := "#FFFFFF"
   PUBLIC aHistory, nHistLen, nHistCurr

   IF lFirst
      aHistory := Array( HISTORY_SIZE_MAX )
      nHistLen := 0
      nHistCurr := 1
   ENDIF

   PREPARE FONT oFont HEIGHT 12
   INIT STYLE oStyleN COLORS 0xff255779,0xff3e7492,0xffa6c0cd ORIENT 1 CORNERS 8
   INIT STYLE oStyleP COLORS 0xff255779,0xff3e7492,0xffa6c0cd ORIENT 6 CORNERS 8
   INIT STYLE oStyleText COLORS 0xff3e7492,0xffa6c0cd ORIENT 1

   INIT WINDOW oActivity TITLE "Calculator" //"$$name1"
   //oActivity:oStyleHead := oStyleText

   MENU
      MENUITEM "Version" ACTION Version()
      MENUITEM "Help" ACTION FHelp()
      MENUITEM "Exit" ACTION hd_MsgYesNo( "Really exit?", {|o|FExit(o)} )
   ENDMENU

   BEGIN LAYOUT oLayV BACKCOLOR 10928333 SIZE MATCH_PARENT,MATCH_PARENT

      EDITBOX oEdit1 HINT "Input an expression" TEXTCOLOR 0 BACKCOLOR 10928333 ;
         ON KEYDOWN {|n|onKey(n,oEdit1,oText0)}
            
      BEGIN LAYOUT oLayH1 HORIZONTAL SIZE MATCH_PARENT,28

      BUTTON oBtn2 TEXT "<<" TEXTCOLOR cWhite SIZE 32,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnHist(.T.,oEdit1)}
      BUTTON oBtn4 TEXT "+" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("+",oEdit1)}
      BUTTON oBtn5 TEXT "-" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("-",oEdit1)}
      BUTTON oBtn6 TEXT "*" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("*",oEdit1)}
      BUTTON oBtn7 TEXT "/" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("/",oEdit1)}
      BUTTON oBtn1 TEXT "=" TEXTCOLOR cWhite SIZE 0,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnCalc(oEdit1,oText0)}
      BUTTON oBtn8 TEXT "(" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("(",oEdit1)}
      BUTTON oBtn9 TEXT ")" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb(")",oEdit1)}
      BUTTON oBtn10 TEXT "[" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("[",oEdit1)}
      BUTTON oBtn11 TEXT "]" TEXTCOLOR cWhite SIZE 26,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnSymb("]",oEdit1)}
      BUTTON oBtn3 TEXT ">>" TEXTCOLOR cWhite SIZE 32,MATCH_PARENT FONT oFont ;
            ON CLICK {||onBtnHist(.F.,oEdit1)}

      oBtn2:oStyle := oBtn4:oStyle := oBtn5:oStyle := oBtn6:oStyle := oBtn7:oStyle := ;
         oBtn1:oStyle := oBtn8:oStyle := oBtn9:oStyle := oBtn10:oStyle := oBtn11:oStyle := ;
         oBtn3:oStyle := { oStyleN,,oStyleP }
      oBtn2:nMarginL := oBtn2:nMarginR := oBtn4:nMarginL := oBtn4:nMarginR := ;
         oBtn5:nMarginL := oBtn5:nMarginR := oBtn6:nMarginL := oBtn6:nMarginR := ;
         oBtn7:nMarginL := oBtn7:nMarginR := oBtn1:nMarginL := oBtn1:nMarginR := ;
         oBtn8:nMarginL := oBtn8:nMarginR := oBtn19nMarginL := oBtn9:nMarginR := ;
         oBtn10:nMarginL := oBtn10:nMarginR := oBtn11:nMarginL := oBtn11:nMarginR := ;
         oBtn3:nMarginL := oBtn3:nMarginR := 1

       hd_setPadding( oBtn2, 8,2 ) ; hd_setPadding( oBtn4, 8,2 ) ; hd_setPadding( oBtn5, 8,2 )
       hd_setPadding( oBtn6, 8,2 ) ; hd_setPadding( oBtn7, 8,2 ) ; hd_setPadding( oBtn1, 8,2 )
       hd_setPadding( oBtn8, 8,2 ) ; hd_setPadding( oBtn9, 8,2 ) ; hd_setPadding( oBtn10, 8,2 )
       hd_setPadding( oBtn11, 8,2 ) ; hd_setPadding( oBtn3, 8,2 )

      END LAYOUT oLayH1

      TEXTVIEW oText0 TEXTCOLOR 0 SIZE MATCH_PARENT,MATCH_PARENT VSCROLL
      oText0:oStyle := oStyleText

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

STATIC Function OnBtnSymb( cSymb, oEdit1 )

   LOCAL nPos := oEdit1:GetCursorPos(), cText := oEdit1:GetText()

   oEdit1:SetText( hb_utf8Left( cText,nPos ) + cSymb + hb_utf8Substr( cText,nPos+1 ) )
   oEdit1:SetCursorPos( nPos+1 )

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
   Local oWnd, oLayV, oText1, oNote
   Local s := "Calculator help" + Chr(10) + Chr(10) + ;
      "Use '<' and '>' buttons to navigate via calculations history." + Chr(10) + Chr(10) + ;
      "You may create variables, assigning values to them, and then use in expressions:"+ Chr(10) + ;
      "   arr := Directory()" + Chr(10) + ;
      "   Len(arr)"

   // INIT NOTIFICATION oNote TITLE "Test" TEXT "Notification test"
   // oNote:Run()

   INIT WINDOW oWnd TITLE "Help" ON INIT {||oText1:SetText(s)}

   MENU
      MENUITEM "Test" ACTION FHelp2()
      MENUITEM "Exit" ACTION hd_calljava_s_v( "exit:")
   ENDMENU

   BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

      TEXTVIEW oText1 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT VSCROLL

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN "1"

STATIC Function FHelp2()
   Local oWnd, oLayV, oText1
   Local s := "Just a test!"

   INIT WINDOW oWnd TITLE "Test"

   BEGIN LAYOUT oLayV BACKCOLOR 8706030 SIZE MATCH_PARENT,MATCH_PARENT

      TEXTVIEW oText1 TEXT s TEXTCOLOR 0 BACKCOLOR 8706030 SIZE MATCH_PARENT,MATCH_PARENT

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN "1"

STATIC Function FExit( o )

   IF o:nres == 1
      hd_calljava_s_v( "exit:")
   ENDIF
   RETURN "1"

STATIC FUNCTION VERSION()

   LOCAL oTimer

   SET TIMER oTimer VALUE 1000 ACTION {||Ftm()}
   hd_MsgInfo(hd_Version()+Chr(10)+hb_Version(),{||oTimer:End()})

   RETURN Nil

STATIC FUNCTION Ftm()
   hd_wrlog( str(seconds()) )
   RETURN Nil

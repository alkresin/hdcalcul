
#include "hbmemvar.ch"
#include "hdroidgui.ch"

#define HISTORY_SIZE_MAX   32

FUNCTION HDroidMain

   LOCAL oActivity, oFont, oLayV, oLayH1, oBtn1, oBtn2, oBtn3, oEdit1, oText1
   PUBLIC aHistory, nHistLen, nHistCurr

   IF Valtype( aHistory ) != "A"
      aHistory := Array( HISTORY_SIZE_MAX )
      nHistLen := 0
      nHistCurr := 1
   ENDIF

   PREPARE FONT oFont HEIGHT 12
   INIT WINDOW oActivity TITLE "Calculator"

   MENU
      MENUITEM "Version" ACTION hd_MsgInfo(hb_Version())
      MENUITEM "Help" ACTION FHelp()
      MENUITEM "Exit" ACTION hd_calljava_s_v( "exit:")
   ENDMENU
      BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

         EDITBOX oEdit1 HINT "Input an expression" ON KEYDOWN {|n|onKey(n,oEdit1,oText1)}
               
         BEGIN LAYOUT oLayH1 HORIZONTAL SIZE MATCH_PARENT,32

         BUTTON oBtn2 TEXT " < " TEXTCOLOR 255 SIZE WRAP_CONTENT,MATCH_PARENT FONT oFont ;
               ON CLICK {||onBtnHist(.T.,oEdit1)}
         BUTTON oBtn1 TEXT "Ok" TEXTCOLOR 255 SIZE 0,MATCH_PARENT FONT oFont ;
               ON CLICK {||onBtnCalc(oEdit1,oText1)}
         BUTTON oBtn3 TEXT " > " TEXTCOLOR 255 SIZE WRAP_CONTENT,MATCH_PARENT FONT oFont ;
               ON CLICK {||onBtnHist(.F.,oEdit1)}

         END LAYOUT oLayH1

         TEXTVIEW oText1 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL
   
      END LAYOUT oLayV

   RETURN oActivity

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

   hd_wrlog( "OnBtnCalc-1" )
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

   INIT WINDOW oWnd TITLE "Help"

      BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

         TEXTVIEW oText1 TEXT "Calculator help" TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL
   
      END LAYOUT oLayV

   hd_calljava_s_v( oWnd:ToString(), "activ" )
   RETURN "1"

package su.harbour.hdcalcul;

import android.app.Application;
import su.harbour.hDroidGUI.Harbour;

public class MainApp extends Application {

   public static Harbour harb;

   @Override
   public void onCreate() {
      super.onCreate();

      harb = new Harbour( this );

      harb.Init( false );

   }
}

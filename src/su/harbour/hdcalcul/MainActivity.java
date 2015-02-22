package su.harbour.hdcalcul;

import android.app.Activity;
import android.os.Bundle;
import android.os.Bundle;
import android.view.View;
import su.harbour.hDroidGUI.Harbour;

public class MainActivity extends Activity {

   @Override
   public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);

      setContentView( MainApp.harb.hrbMain( this ) );
   }
}

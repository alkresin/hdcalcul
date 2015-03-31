package su.harbour.hdcalcul;

import android.os.Bundle;
import su.harbour.hDroidGUI.*;

public class MainActivity extends HDActivity {

   @Override
   public void onCreate(Bundle savedInstanceState) {

      bMain = true;
      MainApp.harb.setDopClass( DopActivity.class );
      super.onCreate(savedInstanceState);
   }

}

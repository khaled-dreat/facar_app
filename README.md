# facar_app
e-commerce app
The app issue where the app was unable to access WhatsApp messages to order products was resolved by adding any URL schemes passed to canLaunchUrl as <queries> entries in the app's AndroidManifest.xml file.
<action android:name="android.intent.action.VIEW" />
     <data android:scheme="sms" />

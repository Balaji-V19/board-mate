# BoardMate — first-time setup

This is a one-time setup to wire your local Flutter app to a real Firebase
project. After this, normal development is just `flutter run`.

> **Note**: the repo currently ships a placeholder `lib/firebase_options.dart`.
> The app will boot but Firebase calls (sign-in, Firestore) will fail until you
> finish step 4.

---

## 1. Install the FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
firebase login          # opens a browser
```

If `flutterfire` isn't on your PATH after activation, add
`$HOME/.pub-cache/bin` (or the path the previous command prints).

## 2. Create a Firebase project

In the [Firebase console](https://console.firebase.google.com):

1. **Add project** → name it `boardmate-app` (or anything you like).
2. **Build → Authentication → Sign-in method → Google** → enable. Set a support
   email. Save.
3. **Build → Firestore Database → Create database** → choose a region close to
   your users → start in **Production mode** (we ship strict rules in step 5).

## 3. Configure FlutterFire for this project

From the project root:

```bash
flutterfire configure --project=<your-firebase-project-id>
```

When prompted, pick at least **android** and **ios**. This will:

- Overwrite `lib/firebase_options.dart` with real values.
- Drop `android/app/google-services.json`.
- Drop `ios/Runner/GoogleService-Info.plist`.

## 4. Platform extras for Google Sign-In

### Android — add the debug SHA-1 fingerprint

```bash
cd android && ./gradlew signingReport
```

Find the `Variant: debug` block and copy the **SHA-1** value (colon-separated,
like `AA:BB:CC:…`). In Firebase console → **Project settings → Your apps →
your Android app → Add fingerprint** → paste → save.

Now refresh the local `google-services.json` so it picks up the new OAuth
client tied to your fingerprint. `flutterfire configure` will only rewrite the
file if it detects a change, so delete it first to force a refresh:

```bash
rm android/app/google-services.json
flutterfire configure --project=<your-firebase-project-id>
```

**Verifying it worked.** Open `android/app/google-services.json`. The SHA-1 is
stored as `certificate_hash` (no colons, lowercase) inside an `oauth_client`
entry with `"client_type": 1`. There should ALSO be an entry with
`"client_type": 3` — that's the Web OAuth client Google Sign-In uses on
Android. If both are present, you're done. Example:

```json
"oauth_client": [
  { "client_id": "…apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.board.game.boardmate",
      "certificate_hash": "e12815ebf578d70ad79a904ff1fe90fcca5a055f"
    } },
  { "client_id": "…apps.googleusercontent.com", "client_type": 3 }
]
```

> If you only see one `oauth_client` entry (no `client_type: 3`), go back to
> the Firebase console → **Authentication → Sign-in method → Google** and make
> sure the provider is enabled. The Web client is created automatically when
> you enable Google sign-in.

### iOS — add the reversed client ID URL scheme

`flutterfire configure` does **not** print `REVERSED_CLIENT_ID`. It's a field
inside the generated `ios/Runner/GoogleService-Info.plist`:

```bash
grep -A 1 REVERSED_CLIENT_ID ios/Runner/GoogleService-Info.plist
```

That value (something like
`com.googleusercontent.apps.4337…-7nv19iai…`) goes into
`ios/Runner/Info.plist` as a URL scheme so Google Sign-In can redirect back
into the app. The block looks like this:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

For this project, the block has already been added to `ios/Runner/Info.plist`
using the value from your generated plist. If you regenerate the Firebase iOS
app, copy the new `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` and
replace the string inside `CFBundleURLSchemes`. Skip the iOS section entirely
if you're only running on Android for now.

## 5. Deploy Firestore rules + indexes (optional but recommended)

```bash
firebase init firestore   # accept defaults, pick the same project
firebase deploy --only firestore:rules,firestore:indexes
```

The shipped `firestore.rules` keep the catalogue read-only for everyone and
make `/users/{uid}/**` private to the signed-in user.

## 6. Seed the sample games

The strict rules block any write to `/games` from the app, so seeding needs a
one-time relaxation:

1. In the console → **Firestore → Rules**, temporarily replace the `games`
   match block with:

   ```text
   match /games/{gameId} {
     allow read, write: if request.auth != null;
     match /guide/{doc} {
       allow read, write: if request.auth != null;
     }
   }
   ```

2. Run the app (`flutter run`), sign in with Google, open **Settings → Seed
   games to Firestore** (the option only appears in debug builds). Wait for the
   snackbar to confirm. You should see 6 games appear in the Firestore console
   under `/games`.
3. Restore the stricter rules by running:

   ```bash
   firebase deploy --only firestore:rules
   ```

## 7. Run the app

```bash
flutter pub get
flutter run
```

If you change any `@freezed` state class, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Troubleshooting

- **"firebase_options.dart has not been generated yet"** — you skipped step 3.
- **`flutterfire configure` says everything is up to date and doesn't rewrite
  files** — it only rewrites when it detects changes. After adding a SHA-1 in
  the Firebase console, delete `android/app/google-services.json` first, then
  re-run configure.
- **My SHA-1 isn't in `google-services.json`** — check for `certificate_hash`
  inside an `oauth_client` block (no colons, lowercased). That IS the SHA-1.
- **There's no Web OAuth client (`client_type: 3`) in
  `google-services.json`** — Google Sign-In on Android needs it. Enable
  **Authentication → Sign-in method → Google** in the Firebase console, then
  re-run `flutterfire configure`.
- **Can't find `REVERSED_CLIENT_ID` in CLI output** — it's not printed; read
  it from `ios/Runner/GoogleService-Info.plist` (search for the
  `REVERSED_CLIENT_ID` key).
- **Google Sign-In on Android closes the picker immediately / returns
  `ApiException 10`** — the running debug build's SHA-1 doesn't match what's
  registered in Firebase, or the Google provider isn't enabled.
- **Firestore "PERMISSION_DENIED" while seeding** — you're still on strict
  rules; revisit step 6.
- **Bottom nav covers content** — confirm the scroll view sets
  `padding: ... AppSpacing.bottomNavSafePadding` at the bottom.

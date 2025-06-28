# Adding Test Target to Xcode Project

Since the test file was created in the wrong location, you need to add a proper test target to your Xcode project. Here's how to do it:

## Step 1: Open Xcode Project

1. Open `FilotoTXT.xcodeproj` in Xcode
2. Make sure you're in the Project Navigator (⌘+1)

## Step 2: Add Test Target

1. Click on the **FilotoTXT** project (top-level item) in the navigator
2. Click the **+** button at the bottom of the targets list
3. Select **iOS** → **Unit Testing Bundle**
4. Name it **FilotoTXTTests**
5. Make sure **Target to be Tested** is set to **FilotoTXT**
6. Click **Finish**

## Step 3: Add Test Files

1. Right-click on the **FilotoTXTTests** folder in the navigator
2. Select **Add Files to "FilotoTXTTests"**
3. Navigate to the `FilotoTXTTests` folder in your project directory
4. Select `FileConverterViewModelTests.swift`
5. Make sure **Add to target** has **FilotoTXTTests** checked
6. Click **Add**

## Step 4: Verify Test Target

1. Select the **FilotoTXTTests** target
2. Go to **Build Phases** tab
3. Make sure `FileConverterViewModelTests.swift` is listed under **Compile Sources**

## Step 5: Run Tests

1. Press **⌘+U** to run tests
2. Or go to **Product** → **Test**

## Alternative: Command Line

If you prefer command line, you can also run:

```bash
# From the project directory
xcodebuild test -project FilotoTXT.xcodeproj -scheme FilotoTXT -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Structure

The test file is now properly located at:
```
FilotoTXTTests/
└── FileConverterViewModelTests.swift
```

This follows the standard iOS project structure where test targets are separate from the main app target.

## What the Tests Cover

The test suite includes:
- ✅ Initial state validation
- ✅ File selection logic
- ✅ Conversion state management
- ✅ Error handling
- ✅ UI state updates
- ✅ Button state logic

## Running Individual Tests

You can run individual tests by:
1. Clicking the diamond icon next to any test method
2. Using the Test Navigator (⌘+6)
3. Right-clicking on specific test methods

## Troubleshooting

If you still see "No such module 'XCTest'" error:
1. Make sure the test file is added to the **FilotoTXTTests** target
2. Clean the build folder (⇧+⌘+K)
3. Rebuild the project
4. Make sure you're running tests, not building the main app 
# TestKeychainBug

rdar://24237713

Summary:
SecItemCopyMatching with queries containing match limit other than kSecMatchLimitAll will return incorrect results 
after device passcode was turned on & off. Looks like old items which are not accessible anymore aren't deleted from
internal storage but only marked as unavailable, but they are still participating in creating result set.

Steps to Reproduce:
Precodition: Device with passcode turned on

Attached Sample project demonstrates the issue. 
Launch the app, than turn off/on device passcode and launch again. Observe console output for results.

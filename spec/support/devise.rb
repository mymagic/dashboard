# reduce the complexity of Devise encryption to make Devise faster in Tests
# (Hashed passwords are less secure, but we don't care in tests)
Devise.stretches = 1
